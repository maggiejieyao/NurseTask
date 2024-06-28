//
//  ShareTaskConfirmationView.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/27/24.
//

import Foundation
import SwiftUI

struct ShareTaskConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    var task: TaskModel
    
    var body: some View {
        VStack {
            Text("Do you want to share this task?")
                .font(.title)
                .padding()
            
            Text(task.taskTitle)
                .font(.headline)
                .padding()
            
            Button("Yes, Share") {
                // Implement sending logic here
                // Example: Use WebSocketManager to send task to recipient
                // Example: self.webSocketManager.sendTask(task)
                
                // Dismiss the confirmation view
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            
            Button("Cancel") {
                // Dismiss the confirmation view
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}
