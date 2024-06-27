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
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var profileImage: Image?
    @State private var confirmedPassword = ""
    @State private var showNetworkAlert = false
    @StateObject var monitor = Monitor()
    
    var body: some View {
        
        if authViewModel.userIsLoggedIn{
            TabView(){
                TaskProfileView()
                    .tabItem{
                        Image(systemName: "doc.badge.plus")
                    }
                
                profile
                    .tabItem{
                        Image(systemName: "person.crop.circle")
                    }
                MapView()
                    .tabItem {
                        Image(systemName: "map.fill")
                    }
                 
            }
            
        }else{
            contentLogin
        }
        
    }
    
    var profile : some View{
        
        return List{
            Section{
                HStack{
                    if(monitor.status == .connected){
                        AsyncImage(url: authViewModel.taskUser?.profileUrl){image in
                            image.resizable()
                            
                        }placeholder: {
                            ProgressView()
                        }
                        .frame(width: 44, height: 44)
                        
                        VStack(alignment:.leading, spacing: 4){
                            Text(authViewModel.taskUser?.fullname ?? "")
                                .font(.headline)
                                .fontWeight(.medium)
                                .accentColor(.gray)
                            
                            
                            Text(authViewModel.taskUser?.getEmail() ?? "")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                            
                        }.padding(10)
                    }else{
                        Section{
                            HStack{
                                Image(.profile)
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                
                                VStack(alignment:.leading, spacing: 4){
                                    Text("Test a")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .accentColor(.gray)
                                    
                                    
                                    Text("test@test.com")
                                        .font(.footnote)
                                        .foregroundColor(Color.gray)
                                    
                                }.padding(10)
                            }
                        }
                        
                    }
                        
                    
                }
            }
            
            Section("Account"){
                Button{
                    //signout()
                    authViewModel.signOut()
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
                       //login()
                       authViewModel.login(withEmail:email, password:password)
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
                    /*
                    Auth.auth().addStateDidChangeListener{auth, user in
                        if user != nil{
                            userIsLoggedIn.toggle()
                        }
                        
                    }*/
                    authViewModel.listenToAuthState()
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
                //register()
                authViewModel.register(withEmail: email, password: password, fullname: fullname)
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
        .onAppear{
            authViewModel.listenToAuthState()
        }
        
        
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
            //userIsLoggedIn = true

    }
    
    func signout(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        //userIsLoggedIn = false
    }
    
    func register(){
        Auth.auth().createUser(withEmail: email, password: password){result, error in
            if error != nil{
                print("Sign up failed \(error!.localizedDescription)")
            }
            
        }
        
        //userIsLoggedIn = true
    }
    
    
}
                

        
struct ContentView_Previews:
    PreviewProvider{
    static var previews: some View{
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(TaskViewModel())
            
    }
    
}
