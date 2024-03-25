//
//  ContentView.swift
//  Nurse Tasks
//
//  Created by Ryan Draper on 2023-11-08.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    //@EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var confirmedPassword = ""
    @State private var userIsLoggedIn = false
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        
        if userIsLoggedIn{
            TabView{
                TaskProfileView()
                    .tabItem{
                        Image(systemName: "doc.badge.plus")
                    }
                
                profile
                    .tabItem{
                        Image(systemName: "person.crop.circle")
                    }
                 
            }
        }else{
            contentLogin
        }
        
    }
    
    var profile : some View{
        return List{
            Section{
                VStack(alignment:.leading, spacing: 4){
                    Text(email)
                        .font(.footnote)
                        .accentColor(.gray)
                }
                
            }
            Section("Account"){
                Button{
                    signout()
                }label: {
                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                }
            }
        }
    }
    var contentLogin : some View {
        
        return NavigationStack{
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
                       login()
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
                NavigationLink(destination: contentRegister){
                    HStack{
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        
                    }
                }
            }.padding(.horizontal, 20)
                .onAppear{
                    Auth.auth().addStateDidChangeListener{auth, user in
                        if user != nil{
                            userIsLoggedIn.toggle()
                        }
                        
                    }
                }
        }
    }
    
    var contentRegister : some View{
        
        return VStack{
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
                register()
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
            
        }
        .padding(.horizontal, 20)
        
        
    }
        /*
        Group{
            if authViewModel.userSession != nil {
                ProfileView()
            }else{
                LoginView()
            }
        }*/
    
    func login(){
        
            Auth.auth().signIn(withEmail: email, password: password){result, error in
                if error != nil{
                    print("Login failed \(error!.localizedDescription)")
                }
                
            }
            userIsLoggedIn = true

    }
    
    func signout(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        userIsLoggedIn = false
    }
    
    func register(){
        Auth.auth().createUser(withEmail: email, password: password){result, error in
            if error != nil{
                print("Sign up failed \(error!.localizedDescription)")
            }
            
        }
        userIsLoggedIn = true
    }
    
    
}
                

        
struct ContentView_Previews:
    PreviewProvider{
    static var previews: some View{
        ContentView()
            .environmentObject(TaskViewModel())
            //.environmentObject(AuthViewModel())
    }
    
}

      
