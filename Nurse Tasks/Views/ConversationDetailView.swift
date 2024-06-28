//
//  ConversationDetailView.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/26/24.
//

import SwiftUI

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(message.sender.fullname) // Display sender's first name
                    .font(.headline)
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.black)
            }
            Spacer()
            Text("\(message.timestamp, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct ConversationDetailView: View {
    var conversationID: String
    @Binding var conversation: Conversation
    @StateObject var webSocketManager: WebSocketManager
    @State private var newMessageContent: String = ""
    @State private var isCalling: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showRingingView: Bool = false

    var body: some View {
        VStack {
            List {
                    ForEach(conversation.messages, id: \.id) { message in
                        // Display messages
                        MessageRow(message: message)
                }
            }

            HStack {
                TextField("Enter your message", text: $newMessageContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                }
                .disabled(newMessageContent.isEmpty)
            }
            .padding()

            if webSocketManager.isIncomingCall {
                HStack {
                    Button("Answer Call") {
                        if let participant = findTaskUser(for: conversation.participants[0].id) {
                            webSocketManager.answerCall(from: participant)
                        } else {
                            print("Participant not found or invalid")
                        }
                    }
                    Button("Decline") {
                        webSocketManager.endCall()
                    }
                }
                .padding()
            } else {
                Button("Call") {
                    if let participant = findTaskUser(for: conversation.participants[0].id) {
                        webSocketManager.startCall(with: participant)
                        showRingingView = true
                    } else {
                        print("Participant not found or invalid")
                    }
                }
                .padding()
            }
        }
        .navigationTitle(conversation.participants.first { $0.id != authViewModel.userSession?.uid }?.fullname ?? "Conversation")
        .fullScreenCover(isPresented: $showRingingView) {
            if let participant = conversation.participants.first(where: { $0.id != authViewModel.userSession?.uid }) {
                RingingView(participant: participant, webSocketManager: webSocketManager)
                    .onDisappear {
                        showRingingView = false // Dismiss the RingingView
                    }
            }
        }
        .onChange(of: webSocketManager.dismissRingingView) { shouldDismiss in
            if shouldDismiss {
                showRingingView = false
            }
        }
    }

    private func sendMessage() {
        guard let selectedUser = conversation.participants.first(where: { $0.id != authViewModel.userSession?.uid }) else {
            print("Recipient not found")
            return
        }
        
        let sender = TaskUser(id: authViewModel.userSession?.uid ?? "",
                              fullname: authViewModel.taskUser?.fullname ?? "",
                              email: authViewModel.userSession?.email ?? "",
                              userLat: "",
                              userLong: "")
        
        let messageContent = newMessageContent
        
        let newMessage = Message(sender: sender, recipient: selectedUser, content: messageContent)
        
        // Sends messages via WebSocketManager
        webSocketManager.sendMessage(newMessage, to: conversation.id, sender: sender, recipient: selectedUser)
        
        // Update conversation messages
        var updatedConversation = conversation
        updatedConversation.messages.append(newMessage)
        conversation = updatedConversation
        
        // Reset message content
        newMessageContent = ""
    }

    private func conversationTitle() -> String {
        // Assume the first participant is the sender
        return conversation.participants.first { $0.id != authViewModel.userSession?.uid }?.fullname ?? "Conversation"
    }

    private func findTaskUser(for participantID: String) -> TaskUser? {
        // Can be used for finding specific user's chat history
        return conversation.participants.first { $0.id == participantID }
    }
}
