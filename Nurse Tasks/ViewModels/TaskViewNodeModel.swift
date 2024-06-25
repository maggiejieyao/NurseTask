//
//  TaskViewNodeModel.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-06-15.
//

import Foundation

/*
class TaskViewNodeModel:ObservableObject{
    @Published var tasks:[TaskModel] = []
    
    func getTasks() async throws{
        let url = URL(string: "http://localhosy:8000/task/tasks")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            let errorData = try JSONDecoder().decode(ErrorData.self, from: data).message
            print("Error \(errorData)")
            throw URLError(.cannotParseResponse)
        }
        
        let jsonData = try JSONDecoder().decode(TaskModel.self, from: data)
        self.tasks.append(jsonData)
        
    }
}*/
