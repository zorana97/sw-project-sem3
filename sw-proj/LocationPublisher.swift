//
//  LocationPublisher.swift
//  sw-proj
//
//  Created by Zorana Jevtic on 28.01.23.
//

import Foundation
import CoreLocation
import Combine

class LocationPublisher: NSObject{
    
    private let locationManager = CLLocationManager()
    
    typealias Output = (longitude: Double, latitude: Double)
    typealias Failure = Never
        
    private let wrapped = PassthroughSubject<(Output), Failure>()
    
    
        
        override init() {
            super.init()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
           // self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.startUpdatingLocation()
        }
    
    
    func getLocation() -> (latitude: Double, longitude: Double)? {
        if locationManager.location != nil {
            let latitude = locationManager.location!.coordinate.latitude
            let longitude = locationManager.location!.coordinate.longitude
            
            return (latitude, longitude)
        }
        return nil
    }
}

extension LocationPublisher: Publisher {
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, Output == Downstream.Input {
        wrapped.subscribe(subscriber)
    }
}


extension LocationPublisher: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        wrapped.send((longitude: location.coordinate.longitude, latitude: location.coordinate.latitude))
    }
    
}
