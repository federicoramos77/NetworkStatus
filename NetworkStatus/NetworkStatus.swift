//
//  NetworkStatus.swift
//  NetworkStatus
//
//  Created by Federico G. Ramos on 16.04.24.
//

import Foundation
import Network
import SwiftUI

actor NetworkStatus {
    static let shared = NetworkStatus()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkStatusMonitor")
    
    private init() {
        monitor.start(queue: queue)
    }
    
    func networkUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.monitor.pathUpdateHandler = { path in
                let isConnected = path.status == .satisfied
                continuation.yield(isConnected)
            }
            continuation.onTermination = { _ in
                self.monitor.cancel()
            }
        }
    }
}

// ViewModifier
struct ObserveNetworkStatus: ViewModifier {
    
    @State private var isConnected: Bool = true
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
            
            if !isConnected {
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                ContentUnavailableView(
                    "No Internet Connection",
                    systemImage: "network.slash",
                    description: Text("This app requieres an active internet connection.")
                )
            }
        }
        .animation(.easeInOut, value: isConnected)
        .task {
            for await status in await NetworkStatus.shared.networkUpdates() {
                isConnected = status
            }
        }
    }
}

extension View {
    func needsInternet() -> some View {
        self.modifier(ObserveNetworkStatus())
    }
}
