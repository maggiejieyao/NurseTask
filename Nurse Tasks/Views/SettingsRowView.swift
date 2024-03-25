//
//  SettingsRowView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-03-01.
//

import SwiftUI

struct SettingsRowView: View {
    let imageName : String
    let title : String
    let tintColor : Color
    
    var body: some View {
        HStack(spacing:12){
            Image(systemName: imageName)
                .imageScale(.small)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

struct SettingsRowView_Previews: PreviewProvider{
    static var previews: some View{
    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: Color(.systemRed))
    }
}
