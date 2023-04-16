//
//  LocationManager.swift
//  Streamini
//
//  Created by Vasily Evreinov on 08/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationDidChanged(_ currentLocation: CLLocationCoordinate2D?, locality: String)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    var currentPlacemark: CLPlacemark?
    weak var delegate: LocationManagerDelegate?
    
    class var shared : LocationManager {
        struct Static {
            static let instance : LocationManager = LocationManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                if #available(iOS 8.0, *) {
                    self.locationManager.requestWhenInUseAuthorization()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    func startMonitoringLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopMonitoringLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CoreLocationDelegate
    
    func locationManager(_ manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                return
            }
            
            if (placemarks!.count > 0) {
                if let del = self.delegate {
                    self.currentPlacemark       = placemarks?[0] as CLPlacemark?
                    let locality: String?       = self.currentPlacemark!.locality
                    let location: CLLocation?   = self.currentPlacemark!.location
                    
                    if let userLocality = locality, let userLocation = location {
                        del.locationDidChanged(userLocation.coordinate, locality: userLocality)
                    }
                }
            }
        })
    }
}
