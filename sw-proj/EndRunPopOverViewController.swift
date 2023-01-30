//
//  EndRunPopOverViewController.swift
//  sw-proj
//
//  Created by Zorana Jevtic on 29.01.23.
//

import Foundation
import UIKit
import CoreData

class EndRunPopOverViewController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var sadButton: UIButton!
    @IBOutlet weak var scepticButton: UIButton!
    @IBOutlet weak var smileButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!

    var distance: Double = 0.0
    var rating: Int = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.layer.cornerRadius = 15.0
        distanceLabel.text = "Distance: \(Int(distance))m"
    }
    
    
    @IBAction func sadClicked(_ sender: Any) {
        calculateTheRating(smiley: "sad")
    }
    
    @IBAction func scepticClicked(_ sender: Any) {
        calculateTheRating(smiley: "sceptic")
    }
    
    @IBAction func smileClicked(_ sender: Any) {
        calculateTheRating(smiley: "smile")
    }
    
    
    func calculateTheRating(smiley: String) {
        switch smiley {
        case "sad":
            sadButton.setImage(UIImage(named: "sad.png"), for: .normal)
            scepticButton.setImage(UIImage(named: "sceptic-fade.png"), for: .normal)
            smileButton.setImage(UIImage(named: "smile-fade.png"), for: .normal)
            rating = 1
        case "sceptic":
            sadButton.setImage(UIImage(named: "sad-fade.png"), for: .normal)
            scepticButton.setImage(UIImage(named: "sceptic.png"), for: .normal)
            smileButton.setImage(UIImage(named: "smile-fade.png"), for: .normal)
            rating = 2
        case "smile":
            sadButton.setImage(UIImage(named: "sad-fade.png"), for: .normal)
            scepticButton.setImage(UIImage(named: "sceptic-fade.png"), for: .normal)
            smileButton.setImage(UIImage(named: "smile.png"), for: .normal)
            rating = 3
        default:
            print("no rating clicked")
        }
    }
    
    @IBAction func confirmClicked(_ sender: Any) {
        saveData()
        dismiss(animated: true)
    }
    
    func saveData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Route", in: context)
        
        if entity != nil {
            let newRoute = Route(entity: entity!, insertInto: context)
            newRoute.distance = Int16(Int(self.distance))
            newRoute.rating = Int16(self.rating)
            newRoute.dateAdded = Date.now
            
            
            do {
                try context.save()
            }
            catch {
                print("CONTEXT SAVE ERROR")
            }
        }
        
    }
}
