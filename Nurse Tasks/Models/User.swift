//
//  User.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-03-01.
//

import Foundation

struct TaskUser:Identifiable, Codable, Hashable{
    let id: String
    var fullname: String
    var email: String
    var profileUrl: URL
    var userLat: String
    var userLong: String
    
    private var DEFAULT_PROFILE_URL = URL(string:"https://drive.usercontent.google.com/download?id=1_0I3TaBVBCGIkjHXhm5bd9hn3ZzU_8AA")
    
    init(id: String, fullname: String, email: String, userLat: String, userLong: String) {
        self.id = id
        self.fullname = fullname
        self.email = email
        self.profileUrl = DEFAULT_PROFILE_URL ?? URL(string: "")!
        self.userLat = userLat
        self.userLong = userLong
    }
    
    var initials: String{
        let formatter  = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    func getEmail()->String{
        return email
    }
    
    func getUrl()->URL{
        return profileUrl
    }
    
    func getFullname()->String{
        return fullname
    }
    
    func getUserLat()->String{
        return userLat
    }
    
    func getUserLong()->String{
        return userLong
    }
    
    mutating func setUrl(profileUrl:String){
        self.profileUrl = URL(string:profileUrl) ?? DEFAULT_PROFILE_URL!
    }
    
    mutating func setEmail(email: String){
        self.email = email
    }
    
    mutating func setFullname(fullname: String){
        self.fullname = fullname
    }
    
    mutating func setUserLat(userLat: String){
        self.userLat = userLat
    }
    
    mutating func setUserLong(userLong: String){
        self.userLong = userLong
    }
}

extension TaskUser{
    static var MOCK_USER = TaskUser(id: NSUUID().uuidString, fullname: "Test a", email: "test@test.com", userLat: "", userLong: "")
    
}
