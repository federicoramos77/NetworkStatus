//
//  NetworkStatus.swift
//  NetworkStatus
//
//  Created by Federico G. Ramos on 16.04.24.
//

import Foundation
import Network
import SwiftUI

class NetworkStatus {
    static let shared = NetworkStatus()
    
    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue.global(qos: .background)
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor = NWPathMonitor()
        monitor?.start(queue: queue)
    }
    
    func networkUpdates() -> AsyncStream<Bool> {
        return AsyncStream { continuation in
                        
            self.monitor?.pathUpdateHandler = { path in
                let isConnected = path.status == .satisfied
                continuation.yield(isConnected)
            }
            
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.stopMonitoring()
            }
        }
    }
    
    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
    
    deinit {
        stopMonitoring()
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
            for await status in NetworkStatus.shared.networkUpdates() {
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
