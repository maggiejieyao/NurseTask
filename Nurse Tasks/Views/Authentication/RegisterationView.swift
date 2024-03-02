//
//  RegisterationView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-02-29.
//

import SwiftUI

struct RegisterationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var confirmedPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack{
            //image
            Image(.nurse)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 100)
                .padding(.vertical, 40)
            
            //form fields
            VStack(spacing: 24){
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                
                InputView(text: $fullname, title: "Full Name", placeholder: "Enter your full name")
                
                InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                
                InputView(text: $confirmedPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                
            }
            
            Button{
                Task{
                    try await authViewModel.createUser(withEmail:email, password:password, fullname:fullname)
                }
            }label: {
                HStack{
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width:UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            Button{
                dismiss()
            }label: {
                HStack{
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    
                }
                .font(.system(size: 16))
                
            }
        }.padding(.horizontal, 20)
        

    }
}

#Preview {
    RegisterationView()
}
