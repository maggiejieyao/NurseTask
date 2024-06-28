//
//  FirestoreService.swift
//  Nurse Tasks
//
//  Created by Benson Wang on 6/26/24.
//

import Foundation
import FirebaseFirestore
import Combine
import CoreLocation

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func updateUserLocation(user: TaskUser) -> AnyPublisher<Void, Error> {
        let userRef = db.collection("users").document(user.id)
        return Future<Void, Error> { promise in
            userRef.setData([
                "fullname": user.fullname,
                "email": user.email,
                "profileUrl": user.profileUrl.absoluteString,
                "userLat": user.userLat,
                "userLong": user.userLong
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchNearbyUsers(location: CLLocationCoordinate2D, radius: Double) -> AnyPublisher<[TaskUser], Error> {
        return Future<[TaskUser], Error> { promise in
            self.db.collection("users").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let users = snapshot?.documents.compactMap { document -> TaskUser? in
                        let data = document.data()
                        guard let id = document.documentID as String?,
                              let fullname = data["fullname"] as? String,
                              let email = data["email"] as? String,
                              let profileUrlString = data["profileUrl"] as? String,
                              let userLat = data["userLat"] as? String,
                              let userLong = data["userLong"] as? String,
                              let profileUrl = URL(string: profileUrlString) else {
                            return nil
                        }
                        let userLocation = CLLocation(latitude: Double(userLat) ?? 0.0, longitude: Double(userLong) ?? 0.0)
                        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                        let distance = currentLocation.distance(from: userLocation)
                        return distance <= radius ? TaskUser(id: id, fullname: fullname, email: email, userLat: userLat, userLong: userLong) : nil
                    } ?? []
                    promise(.success(users))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
