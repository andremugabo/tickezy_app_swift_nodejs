//
//  ContentView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        Group {
            if auth.currentUser != nil {
                // Authenticated → show MainTabView
                MainTabView()
            } else {
                // Not authenticated → show UseScreenView
                UseScreenView()
            }
        }
        .animation(.easeInOut, value: auth.currentUser != nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
}


