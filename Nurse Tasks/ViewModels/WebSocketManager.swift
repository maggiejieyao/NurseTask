//
//  WebSocketManager.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/26/24.
//

import Foundation
import Combine
import FirebaseDatabase
import FirebaseAuth

enum CallSignalType: String, Codable {
    case offer
    case answer
    case endCall
}

struct CallSignal: Codable {
    let type: CallSignalType
    let recipient: TaskUser? // User receiving the signal
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case recipient
        case data
    }
}

enum TaskSignalType: String, Codable {
    case add
    case update
    case delete
}

struct TaskSignal: Codable {
    let type: TaskSignalType
    let task: TaskModel?
    
    enum CodingKeys: String, CodingKey {
        case type
        case task
    }
}

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private var cancellables = Set<AnyCancellable>()
    private var dbRef: DatabaseReference!
    @Published var messages: [Message] = []
    @Published var isCalling = false
    @Published var isIncomingCall = false
    @Published var currentUser: User?
    var currentConversationID: String?
    
    @Published var dismissRingingView: Bool = false
    
    init(url: URL) {
        self.urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: url)
        self.dbRef = Database.database().reference()
        self.connect()
        self.currentUser = Auth.auth().currentUser
    }
    
    private func connect() {
        webSocketTask?.resume()
        receiveMessage()
        receiveCallSignal()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleReceivedMessage(text)
                default:
                    break
                }
            case .failure(let error):
                print("Failed to receive message: \(error)")
            }
            self?.receiveMessage() // Continue listening for more messages
        }
    }
    
    func generateConversationID(participants: [String]) -> String {
        let sortedParticipants = participants.sorted()
        return sortedParticipants.joined(separator: "_")
    }

    func createConversation(participants: [TaskUser], completion: @escaping (String) -> Void) {
        let conversationID = ConversationHelper.generateConversationID(participants: participants)
        
        // Check if the conversation already exists
        dbRef.child("conversations").child(conversationID).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                // If conversation doesn't exist, create it
                var participantsDict: [[String: Any]] = []
                for participant in participants {
                    participantsDict.append(["id": participant.id, "fullname": participant.fullname])
                }
                self.dbRef.child("conversations").child(conversationID).setValue(["participants": participantsDict])
            }
            completion(conversationID)
        }
    }

    func sendMessage(_ message: Message, to conversationID: String, sender: TaskUser, recipient: TaskUser) {
        // Convert messageData to JSON data
        let encoder = JSONEncoder()
        guard let messageData = try? encoder.encode(message),
              let messageString = String(data: messageData, encoding: .utf8) else {
            print("Failed to encode or convert message data")
            return
        }
        
        // Create WebSocket message
        let webSocketMessage = URLSessionWebSocketTask.Message.string(messageString)
        
        // Send message over WebSocket
        webSocketTask?.send(webSocketMessage) { [weak self] error in
            if let error = error {
                print("Failed to send message over WebSocket: \(error)")
            } else {
                print("Message sent over WebSocket successfully")
                
                // Save message to Firebase database
                self?.saveMessageToFirebase(message, conversationID: conversationID, sender: sender, recipient: recipient)
            }
        }
    }

    private func handleReceivedMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: data) else {
            print("Failed to decode incoming message")
            return
        }
        
        // Assuming your Message struct includes sender and recipient information
        let sender = message.sender
        let recipient = message.recipient
        
        DispatchQueue.main.async {
            self.messages.append(message)
            
            // Save received message to Firebase
            if let conversationID = self.currentConversationID {
                self.saveMessageToFirebase(message, conversationID: conversationID, sender: sender, recipient: recipient)
            }
        }
    }

    func saveMessageToFirebase(_ message: Message, conversationID: String, sender: TaskUser, recipient: TaskUser) {
        let messageRef = dbRef.child("conversations").child(conversationID).child("messages").childByAutoId()
        
        // Prepare message data for Firebase
        let messageData: [String: Any] = [
            "senderID": sender.id,
            "senderName": sender.fullname,
            "recipientID": recipient.id,
            "recipientName": recipient.fullname,
            "content": message.content,
            "timestamp": message.timestamp.timeIntervalSince1970
        ]
        
        // Save message to Firebase
        messageRef.setValue(messageData) { error, _ in
            if let error = error {
                print("Failed to save message to Firebase: \(error)")
            } else {
                print("Message saved to Firebase successfully")
            }
        }
    }

    
    func fetchConversations(completion: @escaping ([Conversation]) -> Void) {
        guard let currentUserID = currentUser?.uid else {
            print("No current user")
            completion([])
            return
        }

        dbRef.child("conversations").observeSingleEvent(of: .value, with: { snapshot in
            var conversations: [Conversation] = []

            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                      let dict = childSnapshot.value as? [String: Any],
                      let participantsDict = dict["participants"] as? [[String: Any]],
                      let messagesDict = dict["messages"] as? [String: [String: Any]] else {
                    continue
                }

                var participants: [TaskUser] = []
                for participantDict in participantsDict {
                    if let participantID = participantDict["id"] as? String,
                       let participantName = participantDict["fullname"] as? String {
                        let participant = TaskUser(id: participantID, fullname: participantName, email: "", userLat: "", userLong: "")
                        participants.append(participant)
                    }
                }

                var messages: [Message] = []
                for (messageID, messageData) in messagesDict {
                    // Handle empty senderName
                    var senderName = ""
                    if let senderNameValue = messageData["senderName"] as? String {
                        senderName = senderNameValue
                    }

                    let senderID = messageData["senderID"] as? String ?? ""
                    let recipientID = messageData["recipientID"] as? String ?? ""
                    let recipientName = messageData["recipientName"] as? String ?? ""
                    let content = messageData["content"] as? String ?? ""
                    let timestamp = messageData["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970

                    // Create Message object
                    let sender = TaskUser(id: senderID, fullname: senderName, email: "", userLat: "", userLong: "")
                    let recipient = TaskUser(id: recipientID, fullname: recipientName, email: "", userLat: "", userLong: "")
                    let message = Message(id: messageID, sender: sender, recipient: recipient, content: content, timestamp: Date(timeIntervalSince1970: timestamp))
                    messages.append(message)
                }
                
                //Sort messages by timestamp
                messages.sort {$0.timestamp < $1.timestamp}

                let conversationID = childSnapshot.key
                let conversation = Conversation(id: conversationID, participants: participants, messages: messages)

                if participants.contains(where: { $0.id == currentUserID }) {
                    conversations.append(conversation)
                }
            }

            print("Fetched conversations: \(conversations)")
            completion(conversations)
        }, withCancel: { error in
            print("Failed to fetch conversations: \(error)")
            completion([])
        })
    }

    private func receiveCallSignal() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleCallSignal(text)
                default:
                    break
                }
            case .failure(let error):
                print("Failed to receive call signal: \(error)")
            }
        }
    }
    
    
    func sendCallSignal(_ signal: CallSignal) {
        guard let signalData = try? JSONEncoder().encode(signal),
              let signalString = String(data: signalData, encoding: .utf8) else {
            return
        }
        let webSocketMessage = URLSessionWebSocketTask.Message.string(signalString)
        webSocketTask?.send(webSocketMessage) { error in
            if let error = error {
                print("Failed to send call signal: \(error)")
            }
        }
    }
    
    func startCall(with user: TaskUser) {
        // Initiate a call with another user
        let callSignal = CallSignal(type: .offer, recipient: user, data: nil)
        sendCallSignal(callSignal)
        isCalling = true
    }

    func answerCall(from user: TaskUser) {
        // Answer an incoming call
        let callSignal = CallSignal(type: .answer, recipient: user, data: nil)
        sendCallSignal(callSignal)
        isIncomingCall = false
        isCalling = true
    }

    func endCall() {
        // End an ongoing call
        let callSignal = CallSignal(type: .endCall, recipient: nil, data: nil)
        sendCallSignal(callSignal)
        isCalling = false
        isIncomingCall = false
        dismissRingingView = true
    }
    
    private func handleCallSignal(_ text: String) {
            guard let data = text.data(using: .utf8),
                  let signal = try? JSONDecoder().decode(CallSignal.self, from: data) else {
                return
            }
            DispatchQueue.main.async {
                switch signal.type {
                case .offer:
                    // Handle incoming call
                    self.handleIncomingCall(signal)
                case .answer:
                    // Handle answered call
                    self.handleAnsweredCall(signal)
                case .endCall:
                    // Handle call termination
                    self.handleEndCall(signal)
                }
            }
    }
    private func handleIncomingCall(_ signal: CallSignal) {
        isIncomingCall = true
    }

    private func handleAnsweredCall(_ signal: CallSignal) {
        isIncomingCall = false
        isCalling = true
    }

    private func handleEndCall(_ signal: CallSignal) {
        isCalling = false
        isIncomingCall = false
    }
    
    //Sending tasks
    func sendTaskSignal(_ signal: TaskSignal) {
        guard let signalData = try? JSONEncoder().encode(signal),
              let signalString = String(data: signalData, encoding: .utf8) else {
            return
        }
        let webSocketMessage = URLSessionWebSocketTask.Message.string(signalString)
        webSocketTask?.send(webSocketMessage) { error in
            if let error = error {
                print("Failed to send task signal: \(error)")
            } else {
                print("Task signal sent successfully")
            }
        }
    }

    private func handleReceivedTaskSignal(_ text: String) {
        guard let data = text.data(using: .utf8),
              let signal = try? JSONDecoder().decode(TaskSignal.self, from: data),
              let currentUserID = currentUser?.uid else {
            return
        }
        DispatchQueue.main.async {
            // Handle received task signal
            switch signal.type {
            case .add:
                if let task = signal.task {
                    // Save task under currentUserID in Firebase
                    self.saveTaskToFirebase(task, userID: currentUserID)
                }
            case .update:
                if let task = signal.task {
                    // Update task under currentUserID in Firebase
                    self.updateTaskInFirebase(task, userID: currentUserID)
                }
            case .delete:
                if let task = signal.task {
                    // Delete task under currentUserID in Firebase
                    self.deleteTaskFromFirebase(task, userID: currentUserID)
                }
            }
        }
    }
    
    func saveTaskToFirebase(_ task: TaskModel, userID: String) {
        let taskRef = dbRef.child("tasks").child(userID).childByAutoId()
        let taskData: [String: Any] = [
            "assignedTo": task.assignedTo,
            "clientName": task.clientName,
            "endTime": task.endTime,
            "id": task.id,
            "location": task.location,
            "notes": task.notes,
            "reminderEnabled": task.reminderEnabled,
            "startTime": task.startTime,
            "status": task.status,
            "taskTitle": task.taskTitle,
            "type": task.type,
            "userId": userID
        ]
        taskRef.setValue(taskData) { error, _ in
            if let error = error {
                print("Failed to save task to Firebase: \(error)")
            } else {
                print("Task saved to Firebase successfully")
            }
        }
    }

    func updateTaskInFirebase(_ task: TaskModel, userID: String) {
        
    }

    func deleteTaskFromFirebase(_ task: TaskModel, userID: String) {
      
    }


    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
