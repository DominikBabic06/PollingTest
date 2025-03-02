
import Foundation

let MinSpeed: Float = 0.5 
let pollingInterval: Float = 0.001
let totalDistance: Float = 4000 
let numRuns = 10000

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
        Update(car: &car, pollingInterval: pollingInterval) 
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

struct Car {
    var speed: Float = 0; 
    var distanceCovered: Float = 0; 
}

func Update(car: inout Car, pollingInterval: Float){
    car.speed = sin(Float(car.distanceCovered / 400)) * 5
    car.speed += cos(Float(car.distanceCovered / 40)) / 2 
    car.speed += cos(Float(car.distanceCovered / 13)) / 27 
    car.speed += sin(Float(car.distanceCovered / 2000)) * 32
    var r = min(Float.random(in: 0...1), car.speed / 10)
    if Bool.random() {
        r = -r
    }
    car.speed = max(MinSpeed, car.speed + r)
    car.distanceCovered += car.speed * pollingInterval 
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

