//
//  jsonAPI.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2023-11-16.
//

import Foundation
struct TaskModel:Identifiable,Codable,Equatable{
    static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id:String
    var userId: String
    var clientName: String
    var assignedTo : String
    var location: Address
    var startTime, endTime: StringDate
    var taskTitle, notes: String //type for either personal or work task
    var reminderEnabled, status, type: Bool //whether the task is completed, status true means completed, type true means personal
    
    static let allTasks:[TaskModel] = Bundle.main.decode(file: "data.json")
    //static let allLocations:[Address] = Bundle.main.decode(file: <#T##String#>)
    static let sampleTask : TaskModel = allTasks[0]
    
    
    init(){
        id = UUID().uuidString
        userId = ""
        clientName = ""
        assignedTo = ""
        location = Address()
        taskTitle = ""
        notes = ""
        type = false
        status = false
        reminderEnabled = true
        let currentdate = Date()
        startTime = StringDate(date:currentdate)
        endTime = StringDate(date:currentdate)
    }
    
    init(userId:String, clientName:String, assignedTo:String,street: String,city:String,startTime:StringDate,endTime:StringDate,taskTitle:String,notes:String,reminderEnable:Bool,status:Bool,type:Bool){
        id = UUID().uuidString
        self.userId = userId
        self.clientName = clientName
        self.assignedTo = assignedTo
        location = Address(street: street, city:city)
        self.taskTitle = taskTitle
        self.notes = notes
        self.type = type
        self.status = status
        self.reminderEnabled = reminderEnable
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init(id:String = UUID().uuidString, userId:String, clientName:String, assignedTo:String,street: String,city:String,startTime:StringDate,endTime:StringDate,taskTitle:String,notes:String,reminderEnable:Bool,status:Bool,type:Bool){
        self.id = id
        self.userId = userId
        self.clientName = clientName
        self.assignedTo = assignedTo
        location = Address(street: street, city:city)
        self.taskTitle = taskTitle
        self.notes = notes
        self.type = type
        self.status = status
        self.reminderEnabled = reminderEnable
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func updateCompleted() -> TaskModel{
        if(!reminderEnabled){
            RemindManager.instance.cancelReminderWithIdentifier(identifier: id)
        }else{
            
        }
        return TaskModel(id: id, userId: userId, clientName: clientName, assignedTo: assignedTo, street:location.street, city: location.city, startTime: startTime, endTime: endTime, taskTitle: taskTitle, notes: notes, reminderEnable: reminderEnabled, status: status, type: type)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, clientName, assignedTo, location, taskTitle, notes, type, status, reminderEnabled, startTime, endTime
    }
}

public struct Address:Codable{
    var street, city: String
    init (){
        street = ""
        city = ""
    }
    init(street:String,city:String){
        self.city = city
        self.street = street
    }
}


public struct StringDate:Codable{
    var year, month, day, hour, mintue: String
    
    init(date:Date){
       let calender = Calendar.current
       year = "\(calender.component(.year, from: date))"
       month = "\(calender.component(.month, from: date))"
       day = "\(calender.component(.day, from: date))"
       hour = "\(calender.component(.hour, from: date))"
       mintue = "\(calender.component(.minute, from: date))"
    }

}

public struct ErrorData : Codable {
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}

public struct Tasks: Codable{
    var message: String
    var tasks: [TaskModel]
    
    enum CodingKeys: String, CodingKey {
        case message
        case tasks
    }
}

extension Bundle{
    func decode<T:Decodable> (file:String)->T{
        guard let url = self.url(forResource: file, withExtension:nil) else{
            fatalError("Could not find \(file) in the project!")
        }
        
        guard let data = try? Data(contentsOf: url)else{
            fatalError("Could not load \(file) in the project!")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedData = try? decoder.decode(T.self, from: data)else{
            fatalError("Could not decode \(file) in the project!")
        }
        
        return loadedData
    }
}

