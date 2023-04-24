//
//  Pro_ProtheseApp.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI
import HealthKit

@main
struct Pro_ProtheseApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    let healthStorage = HealthStorage()
    let stepCounterManager = StepCounterManager()
    var healthStore: HealthStore?
    
    @AppStorage("Days") var fetchDays:Int = 7
    
    init() {
        healthStore = HealthStore()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(AppConfig())
                .environmentObject(TabManager())
                .environmentObject(healthStorage)
                .environmentObject(stepCounterManager)
            
                .onChange(of: scenePhase) { newPhase in
                   if newPhase == .active {
                       // APP is in Foreground / Active
                       loadData(days: healthStorage.fetchDays)
                   } else if newPhase == .inactive {
                       // APP is in Foreground / Active
                       //print("APP is Inactive")
                   } else if newPhase == .background {
                       // APP is in Foreground / Active
                       print("APP changed to Background")
                   }
                }
                .onChange(of: fetchDays){ new in
                    loadData(days: new)
                }
                
                
        }
    }
    
    func loadData(days: Int) {

            if let healthStore = healthStore {
                healthStore.requestAuthorization { success in
                    if success {
                        
                        healthStore.getDistance { statisticsCollection in
                           let startDate =  Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -(days-1), to: Date())!)
                            
                            var arr = [Double]()
                            var distances = [Double]()
                           
                            if let statisticsCollection = statisticsCollection {
                                
                                statisticsCollection.enumerateStatistics(from: startDate, to: Date()) { (statistics, stop) in
                                    let count = statistics.sumQuantity()?.doubleValue(for: HKUnit.meter())
                                    arr.append(count ?? 0)
                                    distances.append(count ?? 0)
                                }
                                
                            }
                            
                            DispatchQueue.main.async {
                                healthStorage.showDistance = distances.last! // Update APPStorage for distance in HomeTabView
                                healthStorage.Distances = distances
                            }
                            
                        }
       
                        healthStore.calculateSteps { statisticsCollection in
                            if let statisticsCollection = statisticsCollection {
                                // update the UI
                                let startDateNew =  Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -(days-1), to: Date())!)
                                let endDateNew = Date()
                                var StepsData: [Step] = [Step]()
                                statisticsCollection.enumerateStatistics(from: startDateNew, to: endDateNew) { (statistics, stop) in
                                    let count = statistics.sumQuantity()?.doubleValue(for: .count())
                                    let step = Step(count: Int(count ?? 0), date: statistics.startDate)
                                    StepsData.append(step)
                                }

                                
                                DispatchQueue.main.async {
                                    healthStorage.showStep = StepsData.last?.count ?? 0 // Update APPStorage for Circle in HomeTabView
                                    healthStorage.Steps = StepsData
                                    healthStorage.StepCount = StepsData.count
                                    healthStorage.showDate = Date()
                                }
                               
                                
                            }
                        }
                        
                       
                    }
                }
            }
        }
    
}
