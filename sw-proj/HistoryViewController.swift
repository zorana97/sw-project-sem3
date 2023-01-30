//
//  HistoryViewController.swift
//  sw-proj
//
//  Created by Zorana Jevtic on 29.01.23.
//

import Foundation
import UIKit
import CoreData


var routeList = [Route]()

class HistoryViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        
        navigationController?.navigationBar.isHidden = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Route")
        do {
            let results:NSArray =  try context.fetch(request) as NSArray
            for result in results {
                //code for deleting all entries
                //  context.delete(result as! NSManagedObject)
               let route = result as! Route
                routeList.append(route)
            }
            //code for deleting all entries
            //try  context.save()
        } catch {
            print("Fetching Data from DB Failed")
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let routeCell = tableView.dequeueReusableCell(withIdentifier: "RouteCellID", for: indexPath) as! RouteCell
        
        let thisRoute: Route = routeList[indexPath.row]
        
        routeCell.distanceLabel.text = "Distance: \(String(thisRoute.distance))m"
        
        routeCell.ratingLabel.text = "Rating: \(String(thisRoute.rating))/3"
        
        routeCell.timeLabel.text = thisRoute.dateAdded?.formatted()
        
        return routeCell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return routeList.count
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
}
