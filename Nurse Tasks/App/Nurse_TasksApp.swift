//
//  Nurse_TasksApp.swift
//  Nurse Tasks
//
//  Created by Ryan Draper on 2023-11-08.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct Nurse_TasksApp: App {
    
    @StateObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var taskViewModel:TaskViewModel
    
    init(){
        RemindManager.instance.requestAuthorization()
        FirebaseApp.configure()
        
        let userSession = FirebaseAuth.Auth.auth().currentUser
        
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(userSession: userSession))
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskViewModel)
                .environmentObject(authViewModel)
        }
    }
}
