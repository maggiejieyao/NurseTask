//
//  AccountView2.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-03-02.
//

import SwiftUI

struct AccountView2: View {
    @EnvironmentObject var authViewModel:AuthViewModel
    
    var body: some View {
        
        if let user = authViewModel.currentUser{
            List{
                Section{
                    HStack{
                        Text(user.initials)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment:.leading, spacing: 4){
                            Text(user.fullname)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                        
                    }
                    
                }
                
                Section("Account"){
                    Button{
                        authViewModel.signout()
                    }label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button{
                        print("delete user")
                        
                        Task{
                            //await authViewModel.deleteAccount()
                        }
                    }label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                }
            }
        }
    }
}

#Preview {
    AccountView2()
}

