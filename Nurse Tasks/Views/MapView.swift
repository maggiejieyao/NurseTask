//
//  MapView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-06-26.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let manager = CLLocationManager()
    var body: some View {
        Map(position: $locationManager.region){
            UserAnnotation()
        }
        .mapControls{
            MapUserLocationButton()
        }
        .onAppear{
            updateUserLocation()
        }
    }
    
    func updateUserLocation(){
        if let coordinate = locationManager.lastKnownLocation {
            let latText:String = "\(coordinate.latitude)"
            let longText:String = "\(coordinate.longitude)"
            authViewModel.taskUser?.setUserLat(userLat: latText)
            authViewModel.taskUser?.setUserLong(userLong: longText)
            print("location:\(latText), \(longText)")
        }
    }
}



struct MapView_Previews:
    PreviewProvider{
    static var previews: some View{
        MapView()
            .environmentObject(AuthViewModel())
            
    }
    
}
