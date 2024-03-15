//
//  ContentView.swift
//  Nurse Tasks
//
//  Created by Ryan Draper on 2023-11-08.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        
        Group{
            if authViewModel.userSession != nil {
                ProfileView()
            }else{
                LoginView()
            }
        }
    }
}
                

        
struct ContentView_Previews:
    PreviewProvider{
    static var previews: some View{
        let authViewModel = AuthViewModel()
        let taskViewModel = TaskViewModel(userSession: authViewModel.userSession)
        ContentView()
            .environmentObject(taskViewModel)
            .environmentObject(authViewModel)
    }
    
}

      
