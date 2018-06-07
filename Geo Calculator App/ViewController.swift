//
//  ViewController.swift
//  Geo Calculator App
//
//  Created by Edric Lin on 5/17/18.
//  Created by Dimitri Haring on 5/17/18.
//
//  Copyright © 2018 GVSU. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class ViewController: UIViewController, SettingsViewControllerDelegate, HistoryTableViewControllerDelagate {
    
    @IBOutlet weak var p1LatField: DecimalMinusTextField!
    @IBOutlet weak var p2LatField: DecimalMinusTextField!
    @IBOutlet weak var p1LongField: DecimalMinusTextField!
    @IBOutlet weak var p2LongField: DecimalMinusTextField!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bearingLabel: UILabel!
    
    @IBOutlet weak var calculateButton: UIButton!
    
    var distanceUnits: String = "Kilometers"
    var bearingUnits: String = "Degrees"
    
    fileprivate var ref : DatabaseReference?
    
    //var entries : [LocationLookup] = []
    var entries : [LocationLookup] = [
        LocationLookup(origLat: 90.0, origLng: 0.0, destLat: -90.0, destLng: 0.0, timestamp: Date.distantPast),
        LocationLookup(origLat: -90.0, origLng: 0.0, destLat: 90.0, destLng: 0.0, timestamp: Date.distantFuture)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // firebase
        self.ref = Database.database().reference()
        self.registerForFireBaseUpdates()
        
        // set background color to BACKGORUND_COLOR
        self.view.backgroundColor = BACKGROUND_COLOR
        
        // dismiss keyboard when tapping outside oftext fields
        let detectTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*    // protocol from settings view
     func applyDistanceUnitsSelection(distanceUnits: String) {
     self.distanceUnits = distanceUnits
     calculateButton.sendActions(for: .touchUpInside)
     }
     
     // protocol from settings view
     func applyBearingUnitsSelection(bearingUnits: String) {
     self.bearingUnits = bearingUnits
     calculateButton.sendActions(for: .touchUpInside)
     } */
    
    // protocol from settings view
    func settingsChanged(distanceUnits: String, bearingUnits: String) {
        self.distanceUnits = distanceUnits
        self.bearingUnits = bearingUnits
        calculateButton.sendActions(for: .touchUpInside)
    }
    
    // protocol from history view
    func selectEntry(entry: LocationLookup) {
        self.p1LatField.text = "\(entry.origLat)"
        self.p1LongField.text = "\(entry.origLng)"
        self.p2LatField.text = "\(entry.destLat)"
        self.p2LongField.text = "\(entry.destLng)"
        
        calculateButton.sendActions(for: .touchUpInside)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //print(segue.identifier!)
        
        // if segue to settings view controller
        if segue.identifier == "settingsSegue" {
            if let settingsVC = segue.destination as? SettingsViewController {
                settingsVC.delegate = self
                settingsVC.distanceUnits = self.distanceUnits
                settingsVC.bearingUnits = self.bearingUnits
                //print("hello")
            }
        }
        
        // if seugue to history table view controller
        if segue.identifier == "historySegue" {
            if let historyTableVC = segue.destination as? HistoryTableViewController  {
                entries.forEach { entry in
                    historyTableVC.entries.append(entry)
                }
                historyTableVC.historyDelegate = self
            }
        }
        
        // if suegue to location search view controller
        if segue.identifier == "searchSegue" {
            if let dest = segue.destination as? LocationSearchViewController {
                dest.delegate = self
            }
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        
        // dismiss keyboard when button pressed
        self.dismissKeyboard()
        
        // used to check for valid points
        var pointsOk: Bool = false
        
        // if optionals not nil
        if let p1Lat = self.p1LatField.text, let p1Long = self.p1LongField.text, let p2Lat = self.p2LatField.text, let p2Long = self.p2LongField.text {
            
            // if text fields not empty strings
            if p1Lat != "", p1Long != "", p2Lat != "", p2Long != "" {
                
                // all points valid
                pointsOk = true
            }
        }
        
        // if all points valid
        if pointsOk {
            
            // convert fields to doubles
            let p1Lat: Double = Double(self.p1LatField.text!)!
            let p1Long: Double = Double(self.p1LongField.text!)!
            let p2Lat: Double = Double(self.p2LatField.text!)!
            let p2Long: Double = Double(self.p2LongField.text!)!
            
            
            // create CLLocation (points) from latitudes and longitudes
            let p1: CLLocation = CLLocation(latitude: p1Lat, longitude: p1Long)
            let p2: CLLocation = CLLocation(latitude: p2Lat, longitude: p2Long)
            
            // calculate distance between p1 and p2 in km. round to 2 decimal places
            var distance: Double = p1.distance(from: p2) / 1000
            distance = (distance * 100).rounded() / 100
            
            // convert distance to miles if distance units is miles
            if distanceUnits == "Miles" {
                distance = (distance * 0.621371 * 100).rounded() / 100
            }
            
            // set distance label
            self.distanceLabel.text = "Distance: \(distance) " + distanceUnits
            
            // calculate and set bearing between p1 and p2 in decimal degrees
            var bearing: Double = p1.bearingToPoint(point: p2)
            bearing = (bearing * 100).rounded() / 100
            
            // convert degrees to mils if bearing units is mils
            if bearingUnits == "Mils" {
                bearing = (bearing * 17.777777777778 * 100).rounded() / 100
            }
            
            // set bearing label
            self.bearingLabel.text = "Bearing: \(bearing) " + bearingUnits
            
            // log calculation history
            //entries.append(LocationLookup(origLat: p1Lat, origLng: p1Long, destLat: p2Lat, destLng: p2Long, timestamp: Date()))
            
            // save history to firebase
            let entry = LocationLookup(origLat: p1Lat, origLng: p1Long, destLat: p2Lat, destLng: p2Long, timestamp: Date())
            let newChild = self.ref?.child("history").childByAutoId()
            newChild?.setValue(self.toDictionary(vals: entry))
            
        } else {
            self.distanceLabel.text = "Distance:"
            self.bearingLabel.text = "Bearing:"            
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        
        // dismiss keyboard when button pressed
        self.dismissKeyboard()
        
        p1LatField.text = ""
        p2LatField.text = ""
        p1LongField.text = ""
        p2LongField.text = ""
        
        distanceLabel.text = "Distance:"
        bearingLabel.text = "Bearing:"
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
    }
    
    fileprivate func registerForFireBaseUpdates() {
        self.ref!.child("history").observe(.value, with: { snapshot in
            if let postDict = snapshot.value as? [String : AnyObject] {
                var tmpItems = [LocationLookup]()
                for (_,val) in postDict.enumerated() {
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    let timestamp = entry["timestamp"] as! String?
                    let origLat = entry["origLat"] as! Double?
                    let origLng = entry["origLng"] as! Double?
                    let destLat = entry["destLat"] as! Double?
                    let destLng = entry["destLng"] as! Double?
                    tmpItems.append(LocationLookup(origLat: origLat!,
                                                   origLng: origLng!, destLat: destLat!,
                                                   destLng: destLng!,
                                                   timestamp: (timestamp?.dateFromISO8601)!))
                }
                self.entries = tmpItems
            }
        })
    }
    
    func toDictionary(vals: LocationLookup) -> NSDictionary {
        return [
            "timestamp": NSString(string: (vals.timestamp.iso8601)),
            "origLat" : NSNumber(value: vals.origLat),
            "origLng" : NSNumber(value: vals.origLng),
            "destLat" : NSNumber(value: vals.destLat),
            "destLng" : NSNumber(value: vals.destLng),
        ]
    }
}

extension ViewController: LocationSearchDelegate {
    func set(calculationData: LocationLookup)
    {
        self.p1LatField.text = "\(calculationData.origLat)"
        self.p1LongField.text = "\(calculationData.origLng)"
        self.p2LatField.text = "\(calculationData.destLat)"
        self.p2LongField.text = "\(calculationData.destLng)"
        self.calculateButton.sendActions(for: .touchUpInside)
    }
}

extension Date {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"
            return formatter
        }()
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
    }
    var short: String {
        return Formatter.short.string(from: self)
    }
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
}

