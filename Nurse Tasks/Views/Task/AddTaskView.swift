//
//  AddTaskView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2023-11-16.
//

import SwiftUI
import AVFoundation

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
    @StateObject var speechRecognizer = SpeechHelper()
    @State private var isRecording = false
    @State private var recordedNotes: String = ""
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    //false -> not complete, true-> completed
    // false-> work task, true-> personal task
    
    var isFormValid: Bool{
        !$taskTitle.wrappedValue.isEmpty && !$clientName.wrappedValue.isEmpty && !$assignedTo.wrappedValue.isEmpty && $endT.wrappedValue > $startT.wrappedValue
    }
    
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
                    
                    VStack {
                        Text(speechRecognizer.transcript)
                                        .padding()
                        
                        Button(action: {
                                        if !isRecording {
                                            speechRecognizer.transcribe()
                                        } else {
                                            speechRecognizer.stopTranscribing()
                                        }
                                        
                                        isRecording.toggle()
                                    }){
                                        Text(isRecording ? "Stop" : "Record")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(isRecording ? Color.red : Color.blue)
                                            .cornerRadius(10)
                                    }
                            }
                    
                    }
            }
            Button(action: {
                if(!isFormValid){
                    showingAlert.toggle()
                }else{
                    saveBtnPressed()
                    if(reminderEnabled){
                        RemindManager.instance.scheduleNotification(title: taskTitle, subtitle:"is due", date: endT, id: id)
                    }
                }
            }, label: {
                Text("Save")
            })
            .onAppear{
                let notificationContent = UNMutableNotificationContent()
                notificationContent.badge = 0
            }
            .alert(isPresented: $showingAlert){
                Alert(title: Text("Message"), message: errorMessgeAlert())
            }
            
        }
    }
    func errorMessgeAlert()-> Text{
        if $taskTitle.wrappedValue.isEmpty{
            return Text("Task title is empty")
        }else if $clientName.wrappedValue.isEmpty{
            return Text("Client name is empty")
        }else if $assignedTo.wrappedValue.isEmpty{
            return Text("Nurse name is empty")
        }else if $endT.wrappedValue <= $startT.wrappedValue{
            return Text("End time need larger than start time")
        }
        return Text("")
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
        notes = notes + speechRecognizer.transcript
        Task{
            do{
                try await taskViewModel.addTask(id:id, clientName: clientName, assignedTo: assignedTo, street: street, city: city, startTime: startT, endTime: endT, taskTitle: taskTitle, notes: notes, reminderEnable: reminderEnabled, status: status, type: type)
                presentationMode.wrappedValue.dismiss()
                print("task added!")
            }catch{
                print(error)
            }
        }

    }
}


#Preview {
    AddTaskView()
}



