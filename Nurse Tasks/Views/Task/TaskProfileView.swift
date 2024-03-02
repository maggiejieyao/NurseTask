//
//  TaskProfileView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-03-01.
//

import SwiftUI
import SwiftData
enum TaskFilter: String{
    static var allFilters: [TaskFilter]
    {
        return [.All,.Personal,.Work,.DueToday,.DueNextHour]
    }
    case All = "All"
    case Personal = "Personal"
    case Work = "Work"
    case DueNextHour = "DueNextHour"
    case DueToday = "DueToday"
}


struct TaskProfileView: View {
    @EnvironmentObject var taskViewModel:TaskViewModel
    @State private var searchTerm = ""
    @State var selectedFilter = TaskFilter.Personal
    @State var stringDate:StringDate = StringDate(date: Date())
    
    var filteredTasks : [TaskModel] {
        guard !searchTerm.isEmpty else{return taskViewModel.tasks}
        return taskViewModel.tasks.filter{
            $0.clientName.localizedStandardContains(searchTerm) ||
            $0.location.city.localizedStandardContains(searchTerm) ||
            $0.location.street.localizedStandardContains(searchTerm)
        }
    }
    /*@State var tasks:[TaskModel] = [
        TaskModel(clientName: "client1", assignedTo: "nurse1", street: "ABC St", city: "Burnaby", startTime: StringDate(date: Date()), endTime: StringDate(date: Date()), taskTitle: "task1", notes: "some notes..", reminderEnable: true, status: false, type: false)
    ]*/
    
    var body: some View {
        
            NavigationView{
                List{
                    ForEach(filteredTaskItems(), id:\.id){task in NavigationLink(destination: DetailTaskView(task: task)){
                        HStack{
                            VStack(alignment: .leading, content: {
                                Text("\(task.taskTitle)").bold().font(.title2)
                                Text("\(task.assignedTo)").font(.title3).foregroundStyle(.gray)
                            })
                        }
                        }.padding(6)
                    }
                    .onDelete(perform: taskViewModel.deleteTask)
                    
                }.navigationTitle("Tasks")
                .listStyle(GroupedListStyle())
                .searchable(text: $searchTerm, prompt: "Search")
                
                .toolbar{
                    ToolbarItem(placement:.topBarLeading){
                        Button(action: {
                            
                        }, label: {
                            NavigationLink(destination: AddTaskView()) {
                                Text("Add")
                            }
                            
                        })
                    }
                    
                    ToolbarItem(placement: .confirmationAction){
                        Picker("", selection: $selectedFilter.animation()){
                            ForEach(TaskFilter.allFilters, id:\.self){
                                filter in
                                Text(filter.rawValue)
                            }
                        }
                    }
                
                }
                
            }
                
                
        
        
    }
    func filteredTaskItems()->[TaskModel]{
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date) + 1
        let day = calendar.component(.day, from: date)
        
        if selectedFilter == TaskFilter.Personal{
            return filteredTasks.filter{
                $0.type == true
            }
        }
        if selectedFilter == TaskFilter.Work{
            return filteredTasks.filter{
                $0.type == false
            }
        }
        if selectedFilter == TaskFilter.DueToday{
            return filteredTasks.filter{
                $0.endTime.day == String(day)
            }
        }
        
        if selectedFilter == TaskFilter.DueNextHour{
            return filteredTasks.filter{
                $0.endTime.hour == String(hour)
            }
        }
        return filteredTasks
    }
}

struct TaskProfileView_Previews:
    PreviewProvider{
    static var previews: some View{
        TaskProfileView()
        .environmentObject(TaskViewModel())
        .environmentObject(AuthViewModel())
    }
    
}
