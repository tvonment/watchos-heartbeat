//
//  HeartBeatManager.swift
//  WatchApp01 Watch App
//
//  Created by Thomas von Mentlen on 18.09.22.
//

import Foundation
import HealthKit

class HeartBeatManager: NSObject, ObservableObject {
    
    let healthStore = HKHealthStore()
        
    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            //HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            //HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            //HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            //HKObjectType.activitySummaryType()
        ]
        
        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
            // Handle error.
        }
    }
    
    var timer : Timer?

    func latestHarteRate() {
        guard timer == nil else { return }
        timer =  Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFired() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]){(sample,result,error) in guard error == nil else{
            return
        }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latestHr = data.quantity.doubleValue(for: unit)
            print("Latest Hr\(latestHr) BPM")
            DispatchQueue.main.async {
                self.heartRate = latestHr
                self.sendData(heartRate: String(latestHr))
            }
        }
        healthStore.execute(query)
    }
    
    func sendData(heartRate: String) {
        let uuid = UUID().uuidString
        let params = ["heartRate": heartRate, "id": uuid]
        var request = URLRequest(url: URL(string: "https://heartratesreceiver.azurewebsites.net/api/PostHeartrates?code=Yw3YpOiEGlobAFOhOy9-RKlywaSe1R-H9kCINwH55_LmAzFulaL0GA==")!)
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
            } catch {
                print("error")
            }
        })
        task.resume()
    }
}

