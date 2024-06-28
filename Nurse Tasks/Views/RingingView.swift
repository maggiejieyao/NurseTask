//
//  RingingView.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/26/24.
//

import Foundation
import SwiftUI

struct RingingView: View {
    let participant: TaskUser
    @ObservedObject var webSocketManager: WebSocketManager

    var body: some View {
        VStack {
            Text("Calling \(participant.fullname)...")
                .font(.title)
                .padding()

            HStack {
                Button("End Call") {
                    webSocketManager.endCall()
                }
                .padding()
            }
            .onDisappear {
                webSocketManager.dismissRingingView = false
            }
        }
    }
}
