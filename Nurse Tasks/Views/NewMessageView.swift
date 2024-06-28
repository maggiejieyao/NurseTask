//
//  NewMessageView.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/26/24.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var conversations: [Conversation]
    @State private var selectedUser: TaskUser?
    @State private var messageContent: String = ""
    @ObservedObject var locationManager = LocationManager()
    @State private var nearbyUsers: [TaskUser] = []
    @EnvironmentObject var webSocketManager: WebSocketManager // Retrieve WebSocketManager from environment
    @State private var isLoading = true
    
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            Form {
                if isLoading {
                    Section {
                        ProgressView("Fetching nearby users...")
                    }
                } else {
                    Section(header: Text("Recipient")) {
                        Picker("Select a nearby user: ", selection: $selectedUser) {
                            ForEach(nearbyUsers, id: \.id) { user in
                                Text(user.fullname).tag(user as TaskUser?)
                            }
                        }
                    }
                    
                    Section(header: Text("Message")) {
                        TextField("Enter your message", text: $messageContent)
                    }
                    
                    Button(action: {
                        guard let selectedUser = selectedUser else {
                            print("Errr selecting user")
                            return
                        }
                        
                        let sender = TaskUser(id: authViewModel.userSession?.uid ?? "",
                                              fullname: authViewModel.taskUser?.fullname ?? "",
                                              email: authViewModel.userSession?.email ?? "",
                                              userLat: "",
                                              userLong: "")
                        
                        let participants = [sender, selectedUser]
                        
                        // Create or get existing conversation
                        webSocketManager.createConversation(participants: participants) { conversationID in
                            let newMessage = Message(sender: sender, recipient: selectedUser, content: messageContent)
                            webSocketManager.sendMessage(newMessage, to: conversationID, sender:sender, recipient:selectedUser)
                            
                            if let index = conversations.firstIndex(where: { $0.id == conversationID }) {
                                conversations[index].messages.append(newMessage)
                            } else {
                                let newConversation = Conversation(id: conversationID, participants: participants, messages: [newMessage])
                                conversations.append(newConversation)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Send")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(selectedUser == nil || messageContent.isEmpty)

                }
            }
            .navigationTitle("New Message")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                fetchNearbyUsers()
            }
        }
    }
    
    private func fetchNearbyUsers() {
        print("Fetching nearby users...")
        locationManager.fetchNearbyUsers { users in
            DispatchQueue.main.async {
                self.nearbyUsers = users
                self.isLoading = false
            }
        }
    }
}
