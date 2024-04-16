//
//  ContentView.swift
//  NetworkStatus
//
//  Created by Federico G. Ramos on 16.04.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .needsInternet() /// Makes this View react to network changes
    }
}

#Preview {
    ContentView()
}
