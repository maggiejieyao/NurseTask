//
//  Conversation.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/25/24.
//

import Foundation

struct Conversation: Identifiable, Codable {
    let id: String
    var participants: [TaskUser]
    var messages: [Message]
    
    var lastMessage: Message? {
        return messages.sorted { $0.timestamp < $1.timestamp }.last
    }

    init(id: String, participants: [TaskUser], messages: [Message] = []) {
        self.id = id
        self.participants = participants
        self.messages = messages
    }
}
