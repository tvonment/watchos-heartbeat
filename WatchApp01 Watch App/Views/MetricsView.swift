//
//  SessionView.swift
//  WatchApp01 Watch App
//
//  Created by Thomas von Mentlen on 18.09.22.
//

import SwiftUI
import HealthKit

struct MetricsView: View {
    @EnvironmentObject var heartbeatManager: HeartBeatManager
    var body: some View {
        TimelineView(MetricsTimelineSchedule(from: heartbeatManager.builder?.startDate ?? Date())) { context in
            VStack(alignment: .leading) {
                ElapsedTimeView(elapsedTime: heartbeatManager.builder?.elapsedTime ?? 0, showSubseconds: context.cadence == .live)
                    .foregroundStyle(.blue)
                Text(heartbeatManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                Text(heartbeatManager.averageHeartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
            }
            .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
            .onAppear {
                heartbeatManager.startWorkout()
            }
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView().environmentObject(HeartBeatManager())
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
    }
}

