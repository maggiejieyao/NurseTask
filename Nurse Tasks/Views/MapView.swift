//
//  MapView.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-06-26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @ObservedObject var locationManager = LocationManager()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        Map(position: $locationManager.region){
            ForEach(authViewModel.getLocation()){an in
                Marker("user", coordinate: an)
            }
            UserAnnotation()
        }
        .mapControls{
            MapUserLocationButton()
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
