//
//  NetworkMonitor.swift
//  Nurse Tasks
//
//  Created by Wu Maggie on 2024-04-22.
//

import Foundation
import Network

// An enum to handle the network status
enum NetworkStatus: String {
    case connected
    case lowdata
    case disconnected
}

class Monitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    @Published var status: NetworkStatus = .connected

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            // Monitor runs on a background thread so we need to publish
            // on the main thread
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("Network connected!")
                    self.status = .connected

                }else if path.isConstrained{
                    print("Low data mode")
                    self.status = .lowdata
                    
                }else {
                    print("No connection.")
                    self.status = .disconnected
                }
            }
        }
        monitor.start(queue: queue)
    }
}
