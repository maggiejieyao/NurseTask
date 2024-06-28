//
//  LocationManager.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-06-23.
//

import MapKit
import _MapKit_SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift


final class LocationManager: NSObject, ObservableObject{
    private var locationManager = CLLocationManager()
    private var db = Firestore.firestore()
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
    
    func fetchNearbyUsers(completion: @escaping ([TaskUser]) -> Void) {
        guard let currentLocation = lastKnownLocation else {
            completion([])
            return
        }
        
        // Define the radius (in meters) to search for nearby users
        let radius: Double = 5000 // 5 km
        
        let nearbyQuery = db.collection("users")
            .whereField("userLat", isGreaterThanOrEqualTo: currentLocation.latitude - radius / 111000)
            .whereField("userLat", isLessThanOrEqualTo: currentLocation.latitude + radius / 111000)
            .whereField("userLong", isGreaterThanOrEqualTo: currentLocation.longitude - radius / 111000)
            .whereField("userLong", isLessThanOrEqualTo: currentLocation.longitude + radius / 111000)
        
        nearbyQuery.getDocuments { snapshot, error in
            if let error = error {
                print("Failed to fetch nearby users: \(error)")
                completion([])
                return
            }
            
            var users = snapshot?.documents.compactMap { doc -> TaskUser? in
                try? doc.data(as: TaskUser.self)
            } ?? []
            
            //Manually add a specific user:
            let testUser = TaskUser(
                id: "i9538gg8EadwCoHYpjGUMCMilIk1",
                fullname: "test",
                email: "test@test.com",
                userLat: "49.248859",
                userLong: "-123.015991"
            )
            users.append(testUser)
            
            completion(users)
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
