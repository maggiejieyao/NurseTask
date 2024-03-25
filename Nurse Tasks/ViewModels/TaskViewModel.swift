//
//  TaskViewModel.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2023-11-23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@MainActor
class TaskViewModel: ObservableObject{
    
    @Published var tasks:[TaskModel] = []{
        didSet{
            //saveTasks()
        }
    }
    
    var userId:String = ""
    private var ref: DatabaseReference!
    private var handle : AuthStateDidChangeListenerHandle?
    let taskKey: String = "data.json"
    
    init(){
        self.ref = Database.database().reference()
        
        //self.userId = Auth.auth().currentUser?.uid ?? ""
        //print("user1\(userId)")
        listen()
    
        
        
    }
    func listen(){
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
                    if let user = user {
                        self.userId = user.uid
                        self.tasks = []
                        self.getTasks()
                        
                    } else {
                        self.userId = ""
                        self.tasks = []
                    }
                })
    }
    func getTasks(){
        /*
        guard let data = UserDefaults.standard.data(forKey: taskKey),
              let savedTasks = try? JSONDecoder().decode([TaskModel].self, from: data)
        else{
            return
        }
        self.tasks = savedTasks
         */
        self.userId = Auth.auth().currentUser?.uid ?? ""
        print("userId2:\(userId)")
        //checkIfUserHasTask()
        
        ref.child("tasks").child(userId).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChildren(){
                for child in snapshot.children{
                    print(child)
                    guard let snap = child as? DataSnapshot else { return }
                    guard let value = snap.value as? [String: Any] else { return }
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        //print("jsonData\(jsonData)")
                        let taskArr = try JSONDecoder().decode(TaskModel.self, from: jsonData)
                        self.tasks.append(taskArr)
                        //print("tasks\(self.tasks)")
                    }catch{
                        print(error)
                    }
                }
            }else{
                print("no task yet")
            }
            
            
        })
    
        
        
        
    }
    
    func addTask(id: String, clientName: String, assignedTo: String, street:String,city:String, startTime: Date, endTime: Date, taskTitle: String, notes: String, reminderEnable: Bool, status: Bool, type: Bool){
        let sT = StringDate(date: startTime)
        let eT = StringDate(date: endTime)
        let newTask = TaskModel(id: id, userId: userId, clientName: clientName, assignedTo: assignedTo, street: street, city: city, startTime: sT, endTime: eT, taskTitle: taskTitle, notes: notes, reminderEnable: reminderEnable, status: status, type: type)
        tasks.append(newTask)
        ref.child("tasks").child(userId).child(id).setValue(newTask.toDictionnary)
    }
    
    func deleteTask(atOffsets indexSet: IndexSet){
        //tasks.remove(atOffsets: indexSet)
        let taskModels = indexSet.lazy.map{self.tasks[$0]}
        taskModels.forEach{taskModel in
            ref.child("tasks").child(userId).child(taskModel.id).removeValue()
        }
    }
    
    func updateTask(task: TaskModel){
        if let index =  tasks.firstIndex(where: {$0.id == task.id}){
            tasks[index] = task.updateCompleted()
        }
    }
    
    func saveTasks(){
        if let encodeData = try? JSONEncoder().encode(tasks){
            UserDefaults.standard.set(encodeData, forKey: taskKey)
        }
    }
    
    /*
    func updateTask(task: TaskModel){
        if let index =  tasks.firstIndex(where: {$0.id == task.id}){
            tasks[index] = task.updateCompleted()
        }
    }
    
    func saveTasks(){
        if let encodeData = try? JSONEncoder().encode(tasks){
            UserDefaults.standard.set(encodeData, forKey: taskKey)
        }
    }*/
    
}
extension Encodable {
    var toDictionnary: [String : Any]? {
        guard let data =  try? JSONEncoder().encode(self) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
}
