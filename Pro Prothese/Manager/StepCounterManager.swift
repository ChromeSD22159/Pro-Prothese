//
//  StepCounterManager.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 24.04.23.
//

import SwiftUI
import HealthKit

class StepCounterManager: ObservableObject {
    
    @Published var activeChartCirle: Int = 0
    @Published var devideSizeWidth: CGFloat = 0
    
    @AppStorage("Days") var fetchDays:Int = 7
    
    func calcChartItemSize() -> CGFloat {
        let days = fetchDays
        let itemSize = (devideSizeWidth / 7)
        return itemSize * CGFloat(days)
    }
    
    func maxSteps(steps: [Step]) -> Int {
        let max = steps.max(by: { (a, b) -> Bool in
            return a.count < b.count
        })
        return max?.count ?? 0
    }
    
    func avgSteps(steps: [Step]) -> Int {
        let days = fetchDays
        let avg = (totalSteps(steps: steps) / days)
        
        return avg
    }
    
    func totalSteps(steps: [Step]) -> Int {
       return steps.map { $0.count }.reduce(0,+)
   }
}
