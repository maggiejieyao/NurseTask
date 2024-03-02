//
//  AddTaskView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2023-11-16.
//

import SwiftUI

struct AddTaskView: View {
    @State private var startT: Date = Date()
    @State private var endT: Date = Date()
    @State private var taskTitle: String = ""
    @State private var assignedTo: String = ""
    @State private var clientName: String = ""
    @State private var city: String = ""
    @State private var street: String = ""
    @State private var notes: String = ""
    @State private var type: Bool = false
    @State private var status: Bool = false
    @State private var reminderEnabled: Bool = true
    @EnvironmentObject var taskViewModel:TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var id:String = UUID().uuidString
    
    //false -> not complete, true-> completed
    // false-> work task, true-> personal task
    
    
    var body: some View {
        VStack{
            Form{
                Section {
                    TextField("Title:", text: $taskTitle)
                    TextField("Client Name:", text: $clientName)
                    TextField("Nurse Name:", text: $assignedTo)
                    TextField("City:", text:$city)
                    TextField("Street:", text:$street)
                }
                Section{
                    Toggle("Personal Task", isOn: $type)
                    Toggle("Alert", isOn:$reminderEnabled)
                }
                Section {
                    DatePicker("Start from", selection: $startT)
                                                    .padding(.horizontal)
                    DatePicker("End by", selection: $endT)
                                                    .padding(.horizontal)
                }
                Section{
                    TextField("Notes", text: $notes,  axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            Button(action: {
                saveBtnPressed()
                if(reminderEnabled){
                    RemindManager.instance.scheduleNotification(title: taskTitle, subtitle:"is due", date: endT, id: id)
                }
            }, label: {
                Text("Save")
            })
            .onAppear{
                let notificationContent = UNMutableNotificationContent()
                notificationContent.badge = 0
            }
        }
    }
    
    func addNewTask(){
        //ContentView(newtask: task)
        /*newTask = Task(clientName: task.clientName, assignedTo: task.assignedTo, street:task.location.street,city:task.location.city, startTime: StringDate(date: startT), endTime: StringDate(date: endT), taskTitle: task.taskTitle, notes: task.notes, reminderEnable: task.reminderEnabled, status: task.status, type: task.type)
        tasks.append(newTask)*/
    }
    func writeJSON(tasks: [TaskModel]) {
        do {
            let fileURL = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("data.json")

            let encoder = JSONEncoder()
            try encoder.encode(tasks).write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    func saveBtnPressed(){
        
        taskViewModel.addTask(id:id, clientName: clientName, assignedTo: assignedTo, street: street, city: city, startTime: startT, endTime: endT, taskTitle: taskTitle, notes: notes, reminderEnable: reminderEnabled, status: status, type: type)
        
        presentationMode.wrappedValue.dismiss()
    }
}


#Preview {
    AddTaskView()
}



