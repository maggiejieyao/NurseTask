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
    
    @StateObject var taskViewModel:TaskViewModel = TaskViewModel()
    @StateObject var authViewModel: AuthViewModel = AuthViewModel()
    
    init(){
        RemindManager.instance.requestAuthorization()
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskViewModel)
                .environmentObject(authViewModel)
        }
    }
}
