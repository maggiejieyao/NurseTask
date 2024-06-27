//
//  AuthViewModel.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-04-21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore

class AuthViewModel: ObservableObject{
    @Published var userSession: User?
    @Published var didAuthenticateUser = false
    private var tempUserSession: User?
    private var ref: DatabaseReference!
    @Published var userIsLoggedIn = false
    private var fullname = ""
    private var email = ""
    private var profileUrl = ""
    private var userLat = ""
    private var userLong = ""
    @Published var taskUser: TaskUser?
    private var DEFAULT_PROFILE_URL = "https://drive.usercontent.google.com/download?id=1_0I3TaBVBCGIkjHXhm5bd9hn3ZzU_8AA"
    
    init(){
        
        taskUser = TaskUser(id: "", fullname: fullname, email: email, userLat: "", userLong: "")
        
        self.userSession = Auth.auth().currentUser
        print("DEBUG: User session is \(String(describing: self.userSession?.uid))")
        print()
        ref = Database.database().reference()
        if(userSession?.uid != nil){
            ref.child("users").child(userSession?.uid ?? "").observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                self.fullname = value?["fullname"] as? String ?? ""
                self.email = value?["email"] as? String ?? ""
                self.profileUrl = value?["profileUrl"] as? String ?? ""
                
                self.taskUser?.setEmail(email: self.email)
                self.taskUser?.setFullname(fullname: self.fullname)
                self.taskUser?.setUrl(profileUrl: self.profileUrl)
                
            }){error in
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{auth, user in
            if user != nil{
                self.userIsLoggedIn.toggle()
            }
            
        }
    }
    func login(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in if let error = error {
            print("DEBUG: Failed to register with error \(error.localizedDescription)")
            return
            }
            guard let user = result?.user else { return }
            self.userSession = user
            self.userIsLoggedIn = true
            print("DEBUG: Did log user in...")
            self.taskUser = TaskUser(id: user.uid, fullname: self.fullname, email: email, userLat: self.userLat, userLong: self.userLong)
            self.userIsLoggedIn = true
            
        }
        
    }
    
    func register(withEmail email: String, password: String, fullname: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to register with error \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else { return }
            self.tempUserSession = user

            print("DEBUG: Registered user successfully")
            print("DEBUG: User is \(String(describing: self.userSession))")
            
            self.taskUser = TaskUser(id: user.uid, fullname: fullname, email: email, userLat: "", userLong: "")
            let data = [
                        "userId": user.uid,
                        "email": email,
                        "fullname": fullname,
                        "profileUrl": self.DEFAULT_PROFILE_URL,
                        "userLat": "",
                        "userLong": ""
            ]
            
            self.ref.child("users").child(user.uid).setValue(data)
            self.userIsLoggedIn = true
        }
    }

    func signOut() {
        //sets user session to nil so we show login view
        userSession = nil
        tempUserSession = nil
        didAuthenticateUser = false
        taskUser = nil

        //signs user out on server(backend)
        try? Auth.auth().signOut()
        self.userIsLoggedIn = false
    }
    
    func uploadProfileImage(profileUrl: URL){
        taskUser?.setUrl(profileUrl: profileUrl.absoluteString)
        guard let uid = tempUserSession?.uid else { return }
        let url = URLComponents(string: profileUrl.absoluteString)
        let queryDictionary = url?.queryItems?.queryDictionary ?? [:]
        self.ref.child("users").child(uid).child("profileUrl").updateChildValues(queryDictionary)
    }
    
    
    
}

extension Array where Element == URLQueryItem {
    var queryDictionary: [String: String] {
        self.reduce(into: [:]) { $0[$1.name] = $1.value }
    }
}


