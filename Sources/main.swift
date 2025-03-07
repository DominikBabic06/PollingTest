
import Foundation

let MinSpeed: Float = 0.0 
let pollingInterval: Float = 0.001
let totalDistance: Float = 4000 
let numRuns = 1000 

var totalTimeSum: Float = 0
var averagedPolling: [(Iteration: Int, MeasuredDistance: Float, Percentage: Float, PercentageAbs: Float)] = []


for runIndex in 1...numRuns {
    print(runIndex)
    
    var totalTime: Float = 0
    var car = Car()
    var Values: [(time: Float, speed: Float , distance: Float)] = []
    var Iterator: Int = 1
    var Polling: [(Iteration: Int, MeasuredDistance: Float, Percentage: Float, PercentageAbs: Float)] = []

    while car.distanceCovered < totalDistance {
        Update(car: &car, pollingInterval: pollingInterval, totalTime: totalTime) 
        totalTime += pollingInterval
        Values.append((time: totalTime, speed: car.speed, distance: car.distanceCovered)) 
    }
    totalTimeSum += totalTime
    Polling.append((Iteration: 1, MeasuredDistance: 0, Percentage: 0, PercentageAbs: 0))
    while Iterator != 20001 {    
        var j = 0
        while Polling[Iterator-1].MeasuredDistance < totalDistance {
            if j < Values.count {
                Polling[Iterator-1].MeasuredDistance += Values[j].speed * pollingInterval * Float(Iterator)
                j += Iterator
            } else {
                Polling[Iterator-1].MeasuredDistance += Values[Values.count-1].speed * pollingInterval * Float(Iterator)
            }
        }
        Polling[Iterator-1].Percentage = (Polling[Iterator-1].MeasuredDistance * 100) / totalDistance
        Polling[Iterator-1].PercentageAbs = abs(Polling[Iterator-1].Percentage - 100)
        Iterator += 1
        Polling.append((Iteration: Iterator, MeasuredDistance: 0, Percentage: 0, PercentageAbs: 0))
    }
    Polling.remove(at: Polling.count-1)

    if averagedPolling.isEmpty {
        averagedPolling = Array(repeating: (Iteration: 0, MeasuredDistance: 0, Percentage: 0, PercentageAbs: 0), count: Polling.count)
    }

    for i in 0..<Polling.count {
        averagedPolling[i].Iteration = Polling[i].Iteration
        averagedPolling[i].MeasuredDistance += Polling[i].MeasuredDistance
        averagedPolling[i].Percentage += Polling[i].Percentage
        averagedPolling[i].PercentageAbs += Polling[i].PercentageAbs
    }

    if runIndex == numRuns {  
        for i in 0..<Polling.count {
            averagedPolling[i].MeasuredDistance /= Float(numRuns)
            averagedPolling[i].Percentage /= Float(numRuns)
            averagedPolling[i].PercentageAbs /= Float(numRuns)
        }
    }
}

let averageTotalTime = totalTimeSum / Float(numRuns)
print("Average total time: \(averageTotalTime)")
writePollingRes(averagedPolling)

/*
var averagedIteration: [(Iteration: Int, MeasuredDistance: Float, Percentage: Float, PercentageAbs: Float)] = []
var i = 0
while averagedIteration.count != averagedPolling.count/10{
    averagedIteration.append((Iteration: i+1, MeasuredDistance: 0, Percentage: 0, PercentageAbs: 0))
    for j in 0...9 {
        averagedIteration[i].MeasuredDistance += averagedPolling[j+(i*10)].MeasuredDistance
        averagedIteration[i].Percentage += averagedPolling[j+(i*10)].Percentage
        averagedIteration[i].PercentageAbs += averagedPolling[j+(i*10)].PercentageAbs
    }  
    averagedIteration[i].MeasuredDistance = averagedIteration[i].MeasuredDistance/10
    averagedIteration[i].Percentage = averagedIteration[i].Percentage/10
    averagedIteration[i].PercentageAbs = averagedIteration[i].PercentageAbs/10
    i += 1
}

writeAvgRes(averagedIteration)
*/

struct Car {
    var speed: Float = 0; 
    var distanceCovered: Float = 0; 
    var acceleration: Float = 0;
    var counter: Int = 0; 
    var accelerationduration: Int = 1000; 
}

func Update(car: inout Car,  pollingInterval: Float, totalTime: Float){
    
    if(  car.counter == car.accelerationduration){
        car.acceleration = Float.random(in: 0...3)
        if Bool.random(){
            car.acceleration = -car.acceleration
        }
        car.accelerationduration = Int.random(in: 1000...10000)
        car.counter = 0
    }
    car.counter += 1
    car.speed = max(car.speed+car.acceleration*pollingInterval, MinSpeed)
    car.distanceCovered += car.speed * pollingInterval 
}

func writeAvgRes(_ Polling: [(Iteration: Int, MeasuredDistance: Float, Percentage: Float, PercentageAbs: Float)]){
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let filenameURL = currentDirectoryURL.appendingPathComponent("AvgResults_Averaged.csv")

    var content = "Iteration,MeasuredDistance(m),Percent(%),PercentageAbs(%)\n"
    for value in Polling {
        content += "\(value.Iteration),\(value.MeasuredDistance),\(value.Percentage),\(value.PercentageAbs)\n"
    }

    do {
        try content.write(to: filenameURL, atomically: true, encoding: .utf8)
        print("Averaged results saved: \(filenameURL.path)")
    } catch {
        print("Error writing file: \(error)")
    }
}

func writePollingRes(_ Polling: [(Iteration: Int, MeasuredDistance: Float, Percentage: Float, PercentageAbs: Float)]){
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let filenameURL = currentDirectoryURL.appendingPathComponent("PollingResults_Averaged.csv")

    var content = "Iteration,MeasuredDistance(m),Percent(%),PercentageAbs(%)\n"
    for value in Polling {
        content += "\(value.Iteration),\(value.MeasuredDistance),\(value.Percentage),\(value.PercentageAbs)\n"
    }

    do {
        try content.write(to: filenameURL, atomically: true, encoding: .utf8)
        print("Averaged results saved: \(filenameURL.path)")
    } catch {
        print("Error writing file: \(error)")
    }
}

func writeData(_ Values: [(time: Float, speed: Float , distance: Float)] ){
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let filenameURL = currentDirectoryURL.appendingPathComponent("PollingData.csv")
    var content = "Time,Speed,Distance\n"
    for value in Values {
        content += "\(value.time),\(value.speed),\(value.distance)\n"
    }

    do {
        try content.write(to: filenameURL, atomically: true, encoding: .utf8)
        print("Averaged results saved: \(filenameURL.path)")
    } catch {
        print("Error writing file: \(error)")
    }
}


