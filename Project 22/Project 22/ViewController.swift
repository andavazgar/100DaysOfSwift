//
//  ViewController.swift
//  Project 22
//
//  Created by Andres Vazquez on 2020-03-05.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var iBeaconIDLabel: UILabel!
    @IBOutlet var circleView: UIView!
    var locationManager: CLLocationManager?
    var beaconsDetected = [
        "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0": true,
        "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5": true,
        "74278BDA-B644-4520-8F0C-720EAF059935": true
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        circleView.layer.cornerRadius = 187
        circleView.layer.borderColor = UIColor.black.cgColor
        circleView.layer.borderWidth = 2
        update(distance: .unknown)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            } else {
                print("I can't range")
            }
        }
    }
    
    private func startScanning() {
        if #available(iOS 13.0, *) {
            for beacon in beaconsDetected {
                let beaconConstraint = CLBeaconIdentityConstraint(uuid: UUID(uuidString: beacon.key)!, major: 123, minor: 456)
                let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint, identifier: "testBeacon")
                locationManager?.startMonitoring(for: beaconRegion)
                locationManager?.startRangingBeacons(satisfying: beaconConstraint)
            }
        } else {
            for beacon in beaconsDetected {
                let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.key)!, major: 123, minor: 456, identifier: "testBeacon")
                locationManager?.startMonitoring(for: beaconRegion)
                locationManager?.startRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    private func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceLabel.text = "FAR"
                self.circleView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                
            case .near:
                self.view.backgroundColor = .orange
                self.distanceLabel.text = "NEAR"
                self.circleView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceLabel.text = "RIGHT HERE"
                self.circleView.transform = CGAffineTransform.identity
                
            default:
                self.view.backgroundColor = .gray
                self.distanceLabel.text = "UNKNOWN"
                self.circleView.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            if beaconsDetected[beacon.proximityUUID.uuidString] == true {
                beaconsDetected[beacon.proximityUUID.uuidString] = false
                
                let ac = UIAlertController(title: "First detection", message: "This is a new iBeacon!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(ac, animated: true)
            }
            update(distance: beacon.proximity)
            iBeaconIDLabel.text = beacon.proximityUUID.uuidString
        } else {
            update(distance: .unknown)
        }
    }
    
    @available(iOS 13.0, *)
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            if beaconsDetected[beacon.proximityUUID.uuidString] == true {
                beaconsDetected[beacon.proximityUUID.uuidString] = false
                
                let ac = UIAlertController(title: "First detection", message: "This is a new iBeacon!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(ac, animated: true)
            }
            update(distance: beacon.proximity)
            iBeaconIDLabel.text = beacon.proximityUUID.uuidString
        } else {
            update(distance: .unknown)
        }
    }
}

