//
//  StartView.swift
//  WatchApp01 Watch App
//
//  Created by Thomas von Mentlen on 18.09.22.
//

import SwiftUI
import HealthKit
import WatchKit

struct StartView: View {
    @EnvironmentObject var heartbeatManager: HeartBeatManager

    var body: some View {
        NavigationLink("Start", destination: MetricsView())
        .padding()
        .navigationBarTitle("Heartbeat")
        .onAppear {
            heartbeatManager.requestAuthorization()
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(HeartBeatManager())
    }
}
