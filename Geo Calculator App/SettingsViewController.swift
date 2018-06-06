//
//  SettingsViewController.swift
//  Geo Calculator App
//
//  Created by Edric Lin on 5/17/18.
//  Created by Dimitri Haring on 5/17/18.
//
//  Copyright © 2018 GVSU. All rights reserved.
//

import UIKit

internal protocol SettingsViewControllerDelegate {
    //func applyDistanceUnitsSelection(distanceUnits: String)
    //func applyBearingUnitsSelection(bearingUnits: String)
    func settingsChanged(distanceUnits: String, bearingUnits: String)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var distanceUnitsLabel: UILabel!
    @IBOutlet weak var bearingUnitsLabel: UILabel!
    @IBOutlet weak var unitsPickerView: UIPickerView!
    
    var distanceUnits: String = ""
    var bearingUnits: String = ""
    
    var pickerData: [String] = [String]()
    var selection : String = "hello"
    var delegate : SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // open uipickerview for distance when distance label clicked
        let detectDistanceTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.showDistanceUnitsPickerView))
        self.distanceUnitsLabel.addGestureRecognizer(detectDistanceTouch)
        
        // open uipickerview for bearing when bearing label clicked
        let detectBearingTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.showBearingUnitsPickerView))
        self.bearingUnitsLabel.addGestureRecognizer(detectBearingTouch)
        
        self.unitsPickerView.delegate = self
        self.unitsPickerView.dataSource = self
        
        // dismiss pickerview when tapping outside of picker
        let detectTouch = UITapGestureRecognizer(target: self, action:
            #selector(self.dismissPickerView))
        self.view.addGestureRecognizer(detectTouch)
        
        self.distanceUnitsLabel.text = self.distanceUnits
        self.bearingUnitsLabel.text = self.bearingUnits
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showDistanceUnitsPickerView() {
        
        // show picker and load distance data
        self.unitsPickerView.isHidden = false
        self.pickerData = ["Kilometers", "Miles"]
        
        // reload picker with bearing components
        self.unitsPickerView.reloadAllComponents()
        
        // start picker view with current distance selection
        self.selection = self.distanceUnitsLabel.text!
        
        //print(self.selection + self.distanceUnitsLabel.text!)
        if let row: Int = self.pickerData.index(of: self.selection) {
            self.unitsPickerView.selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    @objc func showBearingUnitsPickerView() {
        
        // show picker and load bearing data
        self.unitsPickerView.isHidden = false
        self.pickerData = ["Degrees", "Mils"]
        
        // reload picker with bearing components
        self.unitsPickerView.reloadAllComponents()
        
        // start picker with curretn bearing selection
        self.selection = self.bearingUnitsLabel.text!
        if let row: Int = self.pickerData.index(of: self.selection) {
            self.unitsPickerView.selectRow(row, inComponent: 0, animated: false)
        }
    }
    
    @objc func dismissPickerView() {
        self.unitsPickerView.isHidden = true
        
/*        // set distance units label if picker was selecting distance units
        if self.selection == "Kilometers" || selection == "Miles" {
            self.distanceUnitsLabel.text = selection
        }
        
        // else set bearing units label
        if selection == "Degrees" || selection == "Mils" {
            self.bearingUnitsLabel.text = selection
        }
 */
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if let d = self.delegate {
            //d.applyDistanceUnitsSelection(distanceUnits: distanceUnitsLabel.text!)
            //d.applyBearingUnitsSelection(bearingUnits: bearingUnitsLabel.text!)
            d.settingsChanged(distanceUnits: distanceUnitsLabel.text!, bearingUnits: bearingUnitsLabel.text!)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    // The number of columns of data
    func numberOfComponents(in: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.selection = self.pickerData[row]
        
        // set distance units label if picker was selecting distance units
        if self.selection == "Kilometers" || selection == "Miles" {
            self.distanceUnitsLabel.text = selection
        }
        
        // else set bearing units label
        if selection == "Degrees" || selection == "Mils" {
            self.bearingUnitsLabel.text = selection
        }
    }
}
