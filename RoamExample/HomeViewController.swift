//
//  HomeViewController.swift
//  RoamExample
//
//  Created by GeoSpark on 05/08/22.
//

import UIKit
import Roam
import CoreLocation

class HomeViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var trackingLabel: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var stopTrackingBtn: UIButton!
    @IBOutlet weak var startTrackingBtn: UIButton!
    
    @IBOutlet weak var customTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let str = UserDefaults.standard.object(forKey: "trackingMode") as? String
        let trackingStarted = UserDefaults.standard.object(forKey: "TrackingStarted") as? Bool
        self.updateLabel(str ?? "Tracking not started", trackingStarted ?? true)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        Roam.logoutUser()
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        self.resetData()
    }
    
    func resetData(){
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    @IBAction func stopTrackingAction(_ sender: Any) {
        Roam.stopTracking()
        self.updateLabel("Tracking not started", true)

    }
    
    @IBAction func startTractionAction(_ sender: Any) {
        self.updateTracking()
    }
    
    func updateTracking(){
        
        let alert = UIAlertController(title: "Choose Tracking options", message: nil  , preferredStyle: .alert)
       
        
        let powerSaver = UIAlertAction(title: "Passive", style: .default) { (alert) in
            Roam.startTracking(.passive)
            self.updateLabel("Passive", false)
            self.saveStr("Passive")

        }
        let balanced = UIAlertAction(title: "Active", style: .default) { (alert) in
            Roam.startTracking(.active)
            self.updateLabel("Active", false)
            self.saveStr("Active")
        }
        let highPerformance = UIAlertAction(title: "Balanced", style: .default) { (alert) in
            Roam.startTracking(.balanced)
            self.updateLabel("Balanced", false)
            self.saveStr("Balanced")

        }
        let distance = UIAlertAction(title: "Custom Distance", style: .default) { (alert) in
            self.updateCustom(true)
        }
    
        let time = UIAlertAction(title: "Custom time", style: .default) { (alert) in
            self.updateCustom(false)
        }
    
        let cance = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(powerSaver)
        alert.addAction(balanced)
        alert.addAction(highPerformance)
        alert.addAction(distance)
        alert.addAction(time)
        alert.addAction(cance)

        self.present(alert, animated: true, completion: nil)
        
    }

    func updateCustom(_ isDistance:Bool){
        
        guard let valueText = customTextfield.text, valueText.isEmpty == false else {
            Alert.alertController(title: "Enter custom Value", message: "Custom tracking value", viewController: self)
            return
        }
        
        let trackingMethod = RoamTrackingCustomMethods()
        trackingMethod.allowBackgroundLocationUpdates = true
        trackingMethod.pausesLocationUpdatesAutomatically = false
        trackingMethod.showsBackgroundLocationIndicator = true
        trackingMethod.desiredAccuracy = .kCLLocationAccuracyBestForNavigation
        trackingMethod.activityType = .fitness
        trackingMethod.useVisits = true
        trackingMethod.useSignificant = true
        trackingMethod.useStandardLocationServices = false
        trackingMethod.useRegionMonitoring  = true
        if isDistance{
            self.updateLabel("Custom Distacne", false)
            self.saveStr("Custom Distacne")

            trackingMethod.distanceFilter = CLLocationDistance(valueText)
        }else{
            self.updateLabel("Custom Time", false)
            self.saveStr("Custom Time")
            trackingMethod.updateInterval = Int(valueText)
        }
        Roam.startTracking(.custom, options: trackingMethod)
    }
    
    func updateLabel( _ str:String,_ isTracking: Bool){
        DispatchQueue.main.async {
            self.trackingLabel.text = str
            self.startTrackingBtn.isHidden = !isTracking
            self.stopTrackingBtn.isHidden = isTracking
        }
    }
    
    func saveStr(_ str:String){
        UserDefaults.standard.set(str, forKey: "trackingMode")
        UserDefaults.standard.set(true, forKey: "TrackingStarted")
        UserDefaults.standard.synchronize()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

