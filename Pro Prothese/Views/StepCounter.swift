//
//  StepCounter.swift
//  Pro Prothese
//
//  Created by Frederik Kohler on 23.04.23.
//

import SwiftUI
import Charts

struct StepCounter: View {
    @EnvironmentObject var healthStorage: HealthStorage
    @EnvironmentObject var stepCounterManager: StepCounterManager
    @AppStorage("Days") var fetchDays:Int = 7
    @Namespace private var MoodAnimationCounter
    @Namespace var bottomID
    
    var body: some View {
        VStack{
            GeometryReader{ proxy in
                HStack{
                    Spacer()
                    Text("Hello, World!")
                    Spacer()
                }
                .onAppear{
                    stepCounterManager.devideSizeWidth = proxy.size.width
                }
            }
           
            
            Spacer()
            
            HStack(spacing: 5) {
                chooseDayButton(7)
                
                chooseDayButton(30)
                
                chooseDayButton(90)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            

            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false){
                    HStack {
                        Chart() {
                            RuleMark(y: .value("Durchschnitt", stepCounterManager.avgSteps(steps: healthStorage.Steps) ) )
                                .foregroundStyle(AppConfig().foreground.opacity(0.5))
                           
                            ForEach(Array(healthStorage.Steps.enumerated()), id: \.offset) { index, step in
                                LineMark(
                                    x: .value("Dates", step.date),
                                    y: .value("Steps", (step.count))
                                )
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(
                                     .linearGradient(
                                        colors: [
                                            Color(red: 32/255, green: 40/255, blue: 63/255),
                                            .white.opacity(0.5)
                                        ],
                                     startPoint: .bottom,
                                     endPoint: .top)
                                 )
                                .lineStyle(.init(lineWidth: 5))
                                .symbol {
                                   ZStack{
                                       Circle()
                                           .fill(.white)
                                           .frame(width: 10)
                                           .shadow(radius: 2)
                                       
                                       Circle()
                                           .fill(.white.opacity(0.3))
                                           .frame(width: 20)
                                           .shadow(radius: 2)
                                          
                                   }
                                }
                                
                                
                            }
                        }
                        .frame(width: stepCounterManager.calcChartItemSize())
                        .chartYAxis {
                            let steps = healthStorage.Steps.map { $0.count }
                            let min = steps.min() ?? 1000
                            let max = steps.max() ?? 20000
                            let consumptionStride = Array(stride(from: min, through: max, by: (max - min)/3))
                            AxisMarks(position: .trailing, values: consumptionStride) { axis in
                                let value = consumptionStride[axis.index]
                                AxisValueLabel("\(value)", centered: true)
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 2,
                                                                 lineCap: .butt,
                                                                 lineJoin: .bevel,
                                                                 miterLimit: 3,
                                                                 dash: [5],
                                                                 dashPhase: 1))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: 1)) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                                if value.count > 7 {
                                    AxisValueLabel(format: .dateTime.day().month())
                                } else {
                                    AxisValueLabel(format: .dateTime.weekday())
                                }
                                
                                
                            }
                        }
                        Text("").id(bottomID)
                    }
                    
                }
                .onChange(of: fetchDays){ new in
                    withAnimation(.easeIn(duration: 0.8)){
                        value.scrollTo(bottomID)
                    }
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        withAnimation(.easeInOut(duration: 1)){
                            value.scrollTo(bottomID)
                        }
                    }
                }
           }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .padding(.bottom)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    @ViewBuilder
    func chooseDayButton(_ day: Int) -> some View {
        HStack{
            Button("\(day) Tage"){
                healthStorage.fetchDays = day
            }
        }
        .frame(maxWidth: .infinity)
        .padding(5)
        .background(AppConfig().backgroundLabel)
        .overlay(
               RoundedRectangle(cornerRadius: 10)
               .stroke(lineWidth: 2)
               .stroke(AppConfig().backgroundLabel)
       )
        .cornerRadius(10)
    }

}

struct StepCounter_Previews: PreviewProvider {
    static var previews: some View {
        StepCounter()
    }
}
