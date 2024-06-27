//
//  LocationManager.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-06-23.
//

import MapKit
import _MapKit_SwiftUI


final class LocationManager: NSObject, ObservableObject{
    private var locationManager = CLLocationManager()
    @Published var region:MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var annotations:[CLLocationCoordinate2D] = []
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }
    
    
    private func setup() {
      switch locationManager.authorizationStatus {
      //If we are authorized then we request location just once,
      // to center the map
      case .authorizedWhenInUse:
        locationManager.requestLocation()
      //If we don´t, we request authorization
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
      default:
        break
      }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        lastKnownLocation = locations.first?.coordinate
        //AuthViewModel().updateLocation(coordinate: lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        locations.last.map {
                region = MapCameraPosition.region(MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}
