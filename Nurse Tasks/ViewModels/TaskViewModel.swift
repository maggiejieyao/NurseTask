//
//  TaskViewModel.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2023-11-23.
//

import Foundation
import Firebase

class TaskViewModel: ObservableObject{
    @Published var tasks:[TaskModel] = []{
        didSet{
            saveTasks()
        }
    }
    let taskKey: String = "data.json"
    // let authViewModel: AuthViewModel // Property to instance of AuthViewModel
    
    init(){
        getTasks()
    }
    //    int(authViewModel: AuthViewModel) {
    //        getTasks()
    //        self.authViewModel = authViewModel
    //    }
        
    //    func getTasks(){
    //        /*
    //        let existingTasks:[TaskModel] = TaskModel.allTasks
    //        tasks.append(contentsOf: existingTasks)*/
    //        guard let data = UserDefaults.standard.data(forKey: taskKey),
    //              let savedTasks = try? JSONDecoder().decode([TaskModel].self, from: data)
    //        else{
    //            return
    //        }
    //        self.tasks = savedTasks
    //
    //    }
        
    func getTasks() {
        Firestore.firestore().collection("tasks")
            .whereField("email", isEqualTo: "ben@gmail.com")
            .addSnapshotListener
        { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var tasks: [TaskModel] = []
                
                for document in snapshot!.documents {
                    do {
                        if let task = try? Firestore.Decoder().decode(TaskModel.self, from: document.data()) {
                            tasks.append(task)
                        }
                    } catch {
                        print("Error decoding task: \(error.localizedDescription)")
                    }
                }
                // Update the tasks array
                self.tasks = tasks
            }
        }
    }
    func deleteTask(at offsets: IndexSet){
        tasks.remove(atOffsets: offsets)
    }
    
    func addTask(id: String, clientName: String, assignedTo: String, street:String,city:String, startTime: Date, endTime: Date, taskTitle: String, notes: String, reminderEnable: Bool, status: Bool, type: Bool) async{
        let sT = StringDate(date: startTime)
        let eT = StringDate(date: endTime)
        
        do {
            
            let newTask = TaskModel(id: id, email: "ben@gmail.com", clientName: clientName, assignedTo: assignedTo, street: street, city: city, startTime: sT, endTime: eT, taskTitle: taskTitle, notes: notes, reminderEnable: reminderEnable, status: status, type: type)
            
            if(reminderEnable){
                //RemindManager.instance.scheduleNotification(title: "first", subtitle: "test")
            }
            do {
                let encodeTask = try Firestore.Encoder().encode(newTask)
                try await Firestore.firestore().collection("tasks").document(newTask.id).setData(encodeTask)
            }
            //        tasks.append(newTask)
        } catch {
            print("Error getting user email: \(error.localizedDescription)")
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
    
}
