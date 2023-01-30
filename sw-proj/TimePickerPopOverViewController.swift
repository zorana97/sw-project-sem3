//
//  TimePickerPopOverViewController.swift
//  sw-proj
//
//  Created by Zorana Jevtic on 29.01.23.
//

import Foundation
import UIKit
import CoreData


protocol TimePickerPopOverViewControllerDelegate: AnyObject {
    func didSelectTime(hour: Int, minutes: Int)
    
}

class TimePickerPopOverViewController: UIViewController {
    
    
    weak var delegate: TimePickerPopOverViewControllerDelegate?
    @IBOutlet weak var hoursTextBox: UITextField!
    @IBOutlet weak var minutesTextBox: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var selectedHour: Int = 19
    var selectedMinutes: Int = 15
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.layer.cornerRadius = 15.0
        
        hoursTextBox.keyboardType = .numberPad
        minutesTextBox.keyboardType = .numberPad
        
       // getNotificationTime()
        
        setStoredTimeInTextBox()
        
        print("Selected hour: ")
        print(selectedHour)
        
        print("Selected minutes: ")
        print(selectedMinutes)
        
    
    }
    
    func setStoredTimeInTextBox() {
        
        hoursTextBox.text = String(selectedHour)
        minutesTextBox.text = String(selectedMinutes)
        
    }
    
    
   
    @IBAction func dismissPopover(_ sender: Any) {
    
        
        
        let hourToString = hoursTextBox.text!
        let minutesToString = minutesTextBox.text!
        
        
        
        if Int(hourToString) != nil && Int(minutesToString) != nil{
            
              selectedHour = Int(hourToString)!
              selectedMinutes = Int(minutesToString)!
        }
       
        
        
        delegate?.didSelectTime(hour: self.selectedHour, minutes: self.selectedMinutes)
        
        print("Dismiss Ok Button clicked...")
        dismiss(animated: true, completion: nil)
    }
    
    func getNotificationTime() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationTime")
        do {
            let results:NSArray =  try context.fetch(request) as NSArray
            
            
            print("PRINTING RESULTS COUNT: ...")
            print(results.count)
            
            if results.count < 1 {
                self.selectedHour = 18
                self.selectedMinutes = 30
            }
            
            else {
                
                let result = results[0]
                let time = result as! NotificationTime
                
                self.selectedHour = Int(time.hour)
                self.selectedMinutes = Int(time.minutes)
            }
        } catch {
            print("Fetching Data from DB Failed")
            
        }
    }
}
