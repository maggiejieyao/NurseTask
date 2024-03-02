//
//  DetailTaskView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2023-11-16.
//

import SwiftUI

struct DetailTaskView: View {
    @EnvironmentObject var taskViewModel:TaskViewModel
    @State var task:TaskModel
    @State private var startT: Date = Date()
    @State private var endT: Date = Date()
    @State private var showSaveAlert = false
    
    
    var body: some View {
        
        let startTime = Binding<Date>(get: {
            convertDate(stringDate: task.startTime)
        }, set: { _ in})
        
        let endTime = Binding<Date>(get: {
            convertDate(stringDate: task.endTime)
        }, set: { _ in})
        
        VStack(spacing: 10){
            Form{
                Section{
                    Text("Task Name: \(task.taskTitle)")
                    Text("Assign To: \(task.assignedTo)")
                    Text("Client Name: \(task.clientName)")
                    Text("Type: \(convertTaskType(type: task.type))")
                    TextField("Notes", text: $task.notes,  axis: .vertical)
                        .lineLimit(2...3)
                }
                Section{
                    TextField("City:", text:$task.location.city)
                    TextField("Street:",text:$task.location.street)
                    Toggle("Alert", isOn:$task.reminderEnabled)
                    Toggle("Completed", isOn: $task.status)
                }header: {
                    Text("Editable Part")
                }
                
                Section{
                    DatePicker("Start from", selection: startTime)
                    DatePicker("End To", selection: endTime)
                }
            }
            Button(action: {
                taskViewModel.updateTask(task: task)
                showSaveAlert = true
            }, label: {
                Text("Save")
            }).alert("Update Sucessfully",isPresented:$showSaveAlert){
                
            }
            
            
            /*
            ("\(task.taskTitle)").bold()
            Text("\(task.assignedTo)").bold()
            Text("\(task.location.city), \(task.location.street)")
            Text("\(convertTaskType(type: task.type))")
            Text("\(convertStatusType(status:task.status))")
            Text("from \(task.startTime.month)/\(task.startTime.day)/\(task.startTime.year) \(task.startTime.hour):\(task.startTime.mintue)")
            Text("to \(task.endTime.month)/\(task.endTime.day)/\(task.endTime.year) \(task.endTime.hour):\(task.endTime.mintue)")
            Text("\(task.notes)")
        */
        }
        /*.navigationBarItems(trailing:
            Button(action: {
            
        }, label: {
            Text("Edit")
        }).padding(.trailing, 6)
        )*/
    }
    func convertTaskType(type:Bool)->String {
        var result = ""
        if(type == true){
            result = "Personal"
        }else{
            result = "Work"
        }
        return result
    }

    func convertStatusType(status:Bool)->String {
        var result = ""
        if(status == true){
            return "Completed"
        }else{
            result = "Not Complete"
        }
        return result
    }
    
    
    func convertDate(stringDate:StringDate)->Date{
        var components = DateComponents()
        components.year = Int(stringDate.year)
        components.month = Int(stringDate.month)
        components.day = Int(stringDate.day)
        components.hour = Int(stringDate.hour)
        components.minute = Int(stringDate.mintue)
        guard let date = Calendar.current.date(from: components) else { return Date() }
        return date
    }
}

struct DetailTaskView_Previews:PreviewProvider{
    static var previews: some View{
        DetailTaskView(task: TaskModel.sampleTask)
            .environmentObject(TaskViewModel())
            .environmentObject(AuthViewModel())
    }
}


