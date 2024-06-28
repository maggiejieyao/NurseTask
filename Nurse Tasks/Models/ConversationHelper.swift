//
//  ConversationHelper.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/25/24.
//

import Foundation

class ConversationHelper {
    static func generateConversationID(participants: [TaskUser]) -> String {
        let sortedParticipantsIDs = participants.map {$0.id}.sorted()
        return sortedParticipantsIDs.joined(separator: "_")
    }
}
