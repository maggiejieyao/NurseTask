//
//  ContentView.swift
//  Nurse Tasks
//
//  Created by Ryan Draper on 2023-11-08.
//

import SwiftUI
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
        ContentView()
            .environmentObject(TaskViewModel())
            .environmentObject(AuthViewModel())
    }
    
}

      
