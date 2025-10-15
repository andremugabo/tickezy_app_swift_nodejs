//
//  TICKEZYApp.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

@main
struct TICKEZYApp: App {
    @StateObject private var auth = AuthService.shared
    
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(auth)
        }
    }
}
