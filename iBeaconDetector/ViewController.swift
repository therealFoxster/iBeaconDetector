//
//  ViewController.swift
//  iBeaconDetector
//
//  Created by Huy Bui on 2022-11-28.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    private let circle = UIView()
    @IBOutlet var status: UILabel!
    @IBOutlet var beaconUUID: UILabel!
    @IBOutlet var distanceReading: UILabel!
    
    private var locationManager: CLLocationManager?
    private var foundBeacon = false
    
    private let beaconUUIDs = [
        "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
        "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5",
        "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        distanceReading.textColor = .white
        distanceReading.center = view.center
        view.backgroundColor = .systemFill
  
        circle.backgroundColor = .white
        circle.alpha = 0.25
        circle.frame.size.width = view.frame.width * 2/3
        circle.frame.size.height = view.frame.width * 2/3
        circle.layer.cornerRadius = circle.frame.width / 2
        circle.layer.zPosition = -1
        circle.center = view.center
        
        let circleContainer = UIView()
        circleContainer.frame.size.width = view.frame.width
        circleContainer.frame.size.height = view.frame.height
        circleContainer.center = view.center
        view.addSubview(circleContainer)
        circleContainer.addSubview(circle)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 7, options: [.repeat, .autoreverse]) {
            circleContainer.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
        
        animateCircleForDistance(.unknown)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways // Authorized.
            && CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) // Able to monitor iBeacon(s).
            && CLLocationManager.isRangingAvailable() // Able to range.
        {
            startScanning()
        }
    }
    
    func startScanning() {
        update(status: "Scanning...")
        print("scanning...")
        
        for (i, uuid) in beaconUUIDs.enumerated() {
//            if i != 0 { return }
            let beaconRegion = CLBeaconRegion(uuid: UUID(uuidString: uuid)!, major: 123, minor: 456, identifier: "MyBeacon\(i)")
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
        }
    }
    
    func update(distance: CLProximity) {
        animateCircleForDistance(distance)
        UIView.animate(withDuration: 0.75) {
            switch distance {
            case .far:
                self.distanceReading.text = "Far Away"
                self.view.backgroundColor = .systemOrange
            case .near:
                self.distanceReading.text = "Nearby"
                self.view.backgroundColor = .systemYellow
            case .immediate:
                self.distanceReading.text = "Here"
                self.view.backgroundColor = .systemGreen
            case .unknown:
                fallthrough
            default:
                self.distanceReading.text = "Unknown"
                self.view.backgroundColor = .systemFill
                self.update(status: "Scanning...")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(status: "Found", beaconUUID: beacon.uuid.uuidString)
            update(distance: beacon.proximity)
            
            if !foundBeacon {
                let alertController = UIAlertController(title: "Success", message: "Found beacon \"\(beacon.uuid.uuidString)\".", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
//                present(alertController, animated: true)
                foundBeacon.toggle()
            }
        }
//        else {
//            update(distance: .unknown)
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func update(status: String, beaconUUID: String = "No beacons found".capitalized) {
        self.status.text = status.uppercased()
        self.beaconUUID.text = beaconUUID
    }
    
    func animateCircleForDistance(_ distance: CLProximity) {
        switch distance {
        case .far:
            UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut]) {
                self.circle.transform = CGAffineTransform(scaleX: 1.5, y: 1.55)
            }
        case .near:
            UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut]) {
                self.circle.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            }
        case .immediate:
            UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut]) {
                self.circle.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        case .unknown:
            UIView.animate(withDuration: 1.5, delay: 1, options: []) {
                self.circle.transform = CGAffineTransform(scaleX: 0, y: 0)
            }
        default:
            break
        }
    }
    
}

