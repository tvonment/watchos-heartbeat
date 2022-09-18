//
//  WatchApp01App.swift
//  WatchApp01 Watch App
//
//  Created by Thomas von Mentlen on 18.09.22.
//

import SwiftUI

@main
struct WatchApp01_Watch_AppApp: App {
    @StateObject private var heartBeatManager = HeartBeatManager()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .environmentObject(heartBeatManager)
        }
    }
}
