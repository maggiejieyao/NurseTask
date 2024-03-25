//
//  AuthViewModel.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-03-02.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAnalytics



class AuthViewModel: ObservableObject{
    /*
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
            print("got user info")
        }
    }
    func signIn(withEmail email: String, password: String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("signed in")
        }catch{
            print("DEBUG: Failed to log in with errror \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else{
            return
        }
        
        self.currentUser = try? snapshot.data(as: User.self)
        print("Current user \(self.userSession?.uid)")
    }
    /*
    
    
    init(){
        //Firestore.firestore().clearPersistence()
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        }catch{
            print("DEBUG: Failed to log in with errror \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodeUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodeUser)
            await fetchUser()
        }catch{
            print("DEBUG: Failed to create user with errror \(error.localizedDescription)")
        }
    }
    
    func signout(){
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }catch{
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    
    func deleteAccount(){
        /*
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        try? await Firestore.firestore().collection("users").document(uid).delete()
        self.userSession = nil
        self.currentUser = nil
         */
    }
    
    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else{
            return 
        }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else{
            return
        }
        
        self.currentUser = try? snapshot.data(as: User.self)
    }*/
    */
}
