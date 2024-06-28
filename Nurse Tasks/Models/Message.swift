//
//  Message.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/25/24.
//

import Foundation

struct Message: Codable {
    let id: String?
    let sender: TaskUser
    let recipient: TaskUser
    let content: String
    let timestamp: Date

    // Initialize Message
    init(id: String? = nil, sender: TaskUser, recipient: TaskUser, content: String, timestamp: Date = Date()) {
        self.id = id ?? UUID().uuidString // Ensure id is either provided or generated
        self.sender = sender
        self.recipient = recipient
        self.content = content
        self.timestamp = timestamp
    }

    // Convert Message to dictionary for Firebase
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["senderID"] = sender.id
        dict["senderName"] = sender.fullname
        dict["recipientID"] = recipient.id
        dict["recipientName"] = recipient.fullname
        dict["content"] = content
        dict["timestamp"] = timestamp.timeIntervalSince1970 // Convert timestamp to TimeInterval for Firebase
        return dict
    }
}
