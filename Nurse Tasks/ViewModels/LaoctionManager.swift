//
//  LocationManager.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-06-23.
//

import MapKit

final class LocationManager: NSObject, ObservableObject{
    private var locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    
    override init() {
        super.init()
        
        checkLocationServicesEnabled()
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    func checkLocationServicesEnabled() {
        self.locationManager = CLLocationManager() // initialise location manager if location services is enabled
        self.locationManager.delegate = self // force unwrap since created location manager on line above so not much of a way this can go wrong
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch self.locationManager.authorizationStatus { // check authorizationStatus instead of locationServicesEnabled()
        case .notDetermined, .authorizedWhenInUse:
            self.locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("ALERT: no location services access")
        case .authorizedAlways:
            break
            
        @unknown default:
            fatalError()
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
        locations.last.map {
                region = MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

