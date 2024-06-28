//
//  ConversationsView.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/26/24.
//

import SwiftUI

struct ConversationsView: View {
    @State private var conversations: [Conversation] = []
    @State private var showingNewMessageView = false
    @StateObject var webSocketManager = WebSocketManager(url: URL(string: "ws://localhost:8080")!)

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($conversations) { $conversation in
                        NavigationLink(destination: ConversationDetailView(conversationID: conversation.id, conversation: $conversation, webSocketManager: webSocketManager)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    if let recipientUser = conversation.participants.first(where: { $0.id != "You" }) {
                                        Text(recipientUser.fullname)
                                            .font(.headline)
                                    }
                                    if let lastMessage = conversation.lastMessage {
                                        Text(lastMessage.content)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                Button(action: {
                    showingNewMessageView = true
                }) {
                    Text("Create New Message")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $showingNewMessageView) {
                    NewMessageView(conversations: $conversations)
                        .environmentObject(webSocketManager)
                }
            }
            .navigationTitle("Conversations")
            .onAppear(perform: fetchConversations)
        }
    }
    
    private func fetchConversations() {
        webSocketManager.fetchConversations { fetchedConversations in
            print("Fetching")
            DispatchQueue.main.async {
                self.conversations = fetchedConversations
            }
            
            print("Fetched successfully")
            
        }
    }
}
