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
import CoreLocation

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
    private var locations:[CLLocationCoordinate2D] = []
    
    init(){
        
        taskUser = TaskUser(id: "", fullname: fullname, email: email, userLat: userLat, userLong: userLong)
        
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
                self.userLat = value?["userLat"] as? String ?? ""
                self.userLong = value?["userLong"] as? String ?? ""
                
                self.taskUser?.setEmail(email: self.email)
                self.taskUser?.setFullname(fullname: self.fullname)
                self.taskUser?.setUrl(profileUrl: self.profileUrl)
                self.taskUser?.setUserLat(userLat: self.userLat)
                self.taskUser?.setUserLong(userLong: self.userLong)
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
            print("User session: \(user)")
            self.userIsLoggedIn = true
            print("DEBUG: Did log user in...")
            self.userIsLoggedIn = true
            self.fetchUserProfileData(for: user.uid)
            
            print("task user session: \(String(describing: self.taskUser))")
        }
        
    }
    
    // Fixes proper retrieval of fields like fullname when a user logs out
    func fetchUserProfileData(for userID: String) {
        ref.child("users").child(userID).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else {
                print("self is nil")
                return
            }
            if let value = snapshot.value as? [String: Any] {
                print("Fetched user data: \(value)")
                self.fullname = value["fullname"] as? String ?? ""
                self.email = value["email"] as? String ?? ""
                self.profileUrl = value["profileUrl"] as? String ?? ""
                self.userLat = value["userLat"] as? String ?? ""
                self.userLong = value["userLong"] as? String ?? ""

                // Update taskUser with fetched profile data
                self.taskUser = TaskUser(id: userID, fullname: self.fullname, email: self.email, userLat: self.userLat, userLong: self.userLong)
                print("Updated taskUser: \(String(describing: self.taskUser))")
            } else {
                print("snapshot value is nil or not a dictionary")
            }
        } withCancel: { error in
            print("Error fetching user data: \(error.localizedDescription)")
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
                        "id": user.uid,
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
        
        // Clear user profile data
        fullname = ""
        email = ""
        profileUrl = ""
        userLat = ""
        userLong = ""

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
    
    
    func updateLocation(coordinate:CLLocationCoordinate2D){
        if(userSession?.uid != nil){
            let userLat:String = "\(coordinate.latitude)"
            let userLong:String = "\(coordinate.longitude)"
            
            ref.child("users").child(userSession?.uid ?? "").child("userLat").setValue(userLat)
            ref.child("users").child(userSession?.uid ?? "").child("userLong").setValue(userLong)
        }
    }
    
    func getLocation()->[CLLocationCoordinate2D]{
        let userRef = self.ref.child("users")
        userRef.observeSingleEvent(of:.value, with: { snapshot in
            for child in snapshot.children{
                print(child)
                guard let snap = child as? DataSnapshot else { return }
                guard let value = snap.value as? [String: Any] else { return }
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    //print("jsonData\(jsonData)")
                    let userArr = try JSONDecoder().decode(TaskUser.self, from: jsonData)
                    let userLat = Double(userArr.userLat)
                    let userLong = Double(userArr.userLong)
                    let coordinates = CLLocationCoordinate2D(latitude: userLat! , longitude: userLong!)
                    self.locations.append(coordinates)
                    print("locations\(self.locations)")
                }catch{
                    print(error)
                }
            }
        })
        return locations
    }
    
}

extension Array where Element == URLQueryItem {
    var queryDictionary: [String: String] {
        self.reduce(into: [:]) { $0[$1.name] = $1.value }
    }
}
