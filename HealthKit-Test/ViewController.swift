//
//  ViewController.swift
//  HealthKit-Test
//
//  Created by Steve on 24/06/2017.
//  Copyright © 2017 Steve. All rights reserved.
//

import UIKit
import HealthKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let healthStore = HKHealthStore()
    let cal = Calendar.current
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return healthKitManager.historyDays
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        
        let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
        let dayData = healthKitManager.workoutData.filter { cal.isDate($0.startDate, inSameDayAs: day!)}
        
        return dayData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = cal.date(byAdding: .day, value: -indexPath.section, to: cal.startOfDay(for: Date()))
        let dayData = healthKitManager.workoutData.filter { cal.isDate($0.startDate, inSameDayAs: day!)}
        
        let workout = dayData[indexPath.row]
        
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.unitsStyle = .positional
        timeFormatter.allowedUnits = [ .hour, .minute ]
        timeFormatter.zeroFormattingBehavior = [ .dropLeading ]
        
        let components1 = cal.dateComponents( [.hour, .minute], from: workout.startDate)
        var timeString = timeFormatter.string(from: components1)!
        
        let components2 = cal.dateComponents( [.hour, .minute], from: workout.endDate)
        timeString = timeString + " - " + timeFormatter.string(from: components2)!
        
        let timeFormatter2 = DateComponentsFormatter()
        timeFormatter2.unitsStyle = .abbreviated
        timeFormatter2.allowedUnits = [ .hour, .minute ]
        timeFormatter2.zeroFormattingBehavior = [ .dropLeading ]
        let durationString = timeFormatter2.string(from: workout.duration)!
        
        let energyFormatter = EnergyFormatter()
        energyFormatter.numberFormatter.maximumFractionDigits = 0
        energyFormatter.unitStyle = .medium
        let energy = workout.totalEnergyBurned?.doubleValue(for: HKUnit.largeCalorie())
        let energyString = energyFormatter.string(fromValue: energy!, unit: .calorie)
        
        let distance = Measurement(value: (workout.totalDistance?.doubleValue(for: HKUnit.mile()))!, unit: UnitLength.miles)
        let distanceFormatter = MeasurementFormatter()
        distanceFormatter.unitStyle = .medium
        distanceFormatter.numberFormatter.maximumFractionDigits = 1
        distanceFormatter.numberFormatter.minimumFractionDigits = 1
        let distanceString = distanceFormatter.string(from: distance)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIDwalking")! as! CustomTableViewCell
        cell.energyLabel.text = energyString
        cell.durationLabel.text = durationString
        cell.timeLabel.text = timeString
        cell.distanceLabel.text = distanceString
        cell.activityLabel.text = healthKitManager.workoutTypeString(workout.workoutActivityType)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = cal.date(byAdding: .day, value: -section, to: cal.startOfDay(for: Date()))
        
        if section == 0 {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            return formatter.string (from: day!)
        }
    }
    
    
    func getData () {
        healthKitManager.getWorkouts (completion: { (x) in
            print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
        
    }
    
    
    @IBAction func screenTappedTriggered(sender: AnyObject) {
        print (NSURL (fileURLWithPath: "\(#file)").lastPathComponent!, "\(#function)")
        getData()
    }
}
