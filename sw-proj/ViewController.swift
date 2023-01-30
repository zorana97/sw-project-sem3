//
//  ViewController.swift
//  sw-proj
//
//  Created by Zorana Jevtic on 28.01.23.
//

import UIKit
import MapKit
import Combine
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, TimePickerPopOverViewControllerDelegate {
    
    
    func didSelectTime(hour: Int, minutes: Int) {
        
        print("DID SELECT TIME DELEGATE CALLED")
        self.hour = hour
        self.minutes = minutes
        saveNotificationTime()
        dispatchNotification()
    }
    
    
    @IBOutlet weak var videoButton: UIButton!

    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var pushNotificationButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var cancellables = [AnyCancellable]()
    let locationPublisher = LocationPublisher()
    var userCoordinates = [CLLocationCoordinate2D]()
    var isWalking: Bool = false
    var polyline: MKPolyline?
    var distance: Double = 0.0
    
    var hour: Int = 18
    var minutes: Int = 30
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        navigationController?.navigationBar.isHidden = true
        videoButton.layer.cornerRadius = 10
        historyButton.layer.cornerRadius = 10
        pushNotificationButton.layer.cornerRadius = 10
        startStopButton.layer.cornerRadius = 10
        
        mapView.delegate = self
        setStartCoordinates()
        mapView.tintColor = UIColor.orange
        mapView.showsUserLocation = true
        locationPublisher.sink(receiveValue: locationReceived).store(in: &cancellables)
        
        checkForPermissions()
        
       getNotificationTime()
  
    }
    
    
    func checkForPermissions() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
                
            case .notDetermined:
                let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]
                notificationCenter.requestAuthorization(options: authorizationOptions) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        }
        
    }
    
    func dispatchNotification () {
        let title = "Time for a run!"
        let identifier = "First push"
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        
        var calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = self.hour
        dateComponents.minute = self.minutes
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    
    func setStartCoordinates() {
        var startCoordinate: CLLocationCoordinate2D
        let publischerCoordinate = locationPublisher.getLocation()
           
        if publischerCoordinate != nil {
            startCoordinate = CLLocationCoordinate2D(latitude: publischerCoordinate!.latitude, longitude: publischerCoordinate!.longitude)
        }
            
        else {
                startCoordinate = CLLocationCoordinate2D(latitude: 48.20817, longitude: 16.373932)
        }
            
        let region = MKCoordinateRegion(center: startCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            
        mapView.setRegion(region, animated: true)
    }
    
    func locationReceived(location: (longitude: Double, latitude: Double)) {
        if isWalking {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            userCoordinates.append(coordinate)
            print("Location count: ")
            print(userCoordinates.count)
            
           addPolyLineToMap()
        }
    }
    
    func addPolyLineToMap()
        {
            if polyline != nil {
                self.mapView.removeOverlay(polyline!)
            }
            
            if userCoordinates.count > 1 {
                polyline = MKPolyline(coordinates: &userCoordinates, count: userCoordinates.count)
                print("CALLING ADD OVERLAY")
                self.mapView.addOverlay(polyline!)
            }
        }
    
    @IBAction func startAndStopClicked(_ sender: Any) {
        
        if startStopButton.titleLabel?.text == " Start Run" {
            print("Button Title is Start Run")
            startStopButton.setTitle(" Stop Run", for: .normal)
            startStopButton.setImage(UIImage(systemName: "stop"), for: .normal)
            startStopButton.backgroundColor = UIColor.white
            startStopButton.configuration?.baseForegroundColor = UIColor.orange
            
            isWalking = true
            distance = 0.0
            
        }
        else if startStopButton.titleLabel?.text == " Stop Run" {
            print("Button Title is Stop Run")
            startStopButton.setTitle(" Start Run", for: .normal)
            startStopButton.setImage(UIImage(systemName: "play"), for: .normal)
            startStopButton.backgroundColor = UIColor.darkGray
            startStopButton.configuration?.baseForegroundColor = UIColor.white
            
            calculateDistance()
            
            userCoordinates.removeAll()
            
            if polyline != nil {
                self.mapView.removeOverlay(polyline!)
            }
            
            isWalking = false
            
            self.performSegue(withIdentifier: "runEndedPopOverSegue", sender: self)
           
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "runEndedPopOverSegue" {
            let destination = segue.destination as! EndRunPopOverViewController
            destination.distance = self.distance
        }
        if segue.identifier == "showTimePickerSegue" {
            let destinationVC = segue.destination as! TimePickerPopOverViewController
            destinationVC.delegate = self
            destinationVC.selectedHour = self.hour
            destinationVC.selectedMinutes = self.minutes
            
                }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("MAP VIEW OVERLAY RENDERER CALLED")
        let renderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
                renderer.strokeColor = .orange
            renderer.lineWidth = 5.0
            renderer.alpha = 1.0 // changed 0.8 to 1.0, now it works
        }
        return renderer
    }
    
    
    
    func calculateDistance() {
        
        if userCoordinates.count > 1 {
            
            for i in 0..<userCoordinates.count - 1 {
                        let start = userCoordinates[i]
                        let end = userCoordinates[i + 1]
                        let pointDistance = getDistance(from: start, to: end)
                        distance += pointDistance
            }
        }
        print("PRINTING DISTANCE........")
        print(distance)
    }

    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    func getNotificationTime() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationTime")
        do {
            let results:NSArray =  try context.fetch(request) as NSArray
            
            
            print("NOTIFICATION TIME RESULTS COUNT: ")
            print(results.count)
            if results.count < 1 {
                self.hour = 18
                self.minutes = 30
            }
            
            else {
                
                let result = results[0]
                let time = result as! NotificationTime
                
                self.hour = Int(time.hour)
                self.minutes = Int(time.minutes)
            }
        } catch {
            print("Fetching Data from DB Failed")
            
        }
    }
    
    func saveNotificationTime() {
        
        deleteTimeData()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "NotificationTime", in: context)
        
        if entity != nil {
            print("ENTIY IN SAVING IS NOT NIL")
            let newNotificationTime = NotificationTime(entity: entity!, insertInto: context)
            newNotificationTime.hour = Int16(Int(self.hour))
            newNotificationTime.minutes = Int16(self.minutes)
            
            
            do {
                try context.save()
            }
            catch {
                print("CONTEXT SAVE ERROR")
            }
        }
        
    }
    
    func deleteTimeData () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationTime")
        do {
            let results:NSArray =  try context.fetch(request) as NSArray
            if results.count > 0 {
                for result in results {
                    context.delete(result as! NSManagedObject)
                }
                try  context.save()
            }
           
        } catch {
            print("Deleting time data failed")
            
        }
    }

}

