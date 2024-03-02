//
//  ProfileView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-02-29.
//

import SwiftUI

struct ProfileView: View {
    
    var body: some View {
        
        TabView{
            TaskProfileView()
                .tabItem{
                    Image(systemName: "doc.badge.plus")
                }
            
            AccountView()
                .tabItem{
                    Image(systemName: "person.crop.circle")
                }
             
             
        }
        
    }
    
}


struct ProfileView_Previews:
    PreviewProvider{
    static var previews: some View{
        ProfileView()
            .environmentObject(TaskViewModel())
            .environmentObject(AuthViewModel())
            
    }
    
}
