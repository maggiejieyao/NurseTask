//
//  LoginView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-02-29.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
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
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                }
                //sign in button
                
                Button{
                    Task{
                        try await authViewModel.signIn(withEmail: email, password: password)
                    }
                }label: {
                    HStack{
                        Text("SIGN IN")
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
                //sign up button
                NavigationLink(destination: RegisterationView().navigationBarBackButtonHidden(true)){
                    HStack{
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        
                    }
                }
            }.padding(.horizontal, 20)
            
        }
        
    }
}

#Preview {
    LoginView()
}
