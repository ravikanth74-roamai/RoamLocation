//
//  ViewController.swift
//  RoamExample
//
//  Created by GeoSpark on 04/08/22.
//

import UIKit
import Roam

class ViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var userIdTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

    }
    
    @IBAction func createUserAction(_ sender: Any) {
        Roam.createUser("", [:]) { user, error in
            print(user?.userId)
        }
    }
    
    @IBAction func getUserAction(_ sender: Any) {
        
        guard let userId = userIdTextfield.text , userId.isEmpty == false else {
            Alert.alertController(title: "Enter UserId", message: "user id cannot be empty", viewController: self)
            return
        }
        self.showHud()
        Roam.getUser(userId) { user, error in
            self.dismissHud()
            if error == nil {
                UserDefaults.standard.set(true, forKey: "kFirstTime")
                UserDefaults.standard.synchronize()
                Roam.toggleListener(Events: true, Locations: true) { user, error in
                    if error == nil {
                        Roam.publishSave()
                        Roam.subscribe(.Location, userId)
                        Roam.subscribe(.Events, userId)
                    }
                    self.rootViewController()

                }
            }else{
                Alert.alertController(title: "Get user Error ", message: "\(String(describing: error?.message))", viewController: self)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func rootViewController(){
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let  navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            navigationController.viewControllers = [rootViewController] as [UIViewController]
            navigationController.modalPresentationStyle = .fullScreen
            UIApplication.topViewController()?.present(navigationController, animated: true, completion: nil)
        }
    }
}


