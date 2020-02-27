//
//  ViewController.swift
//  Project 16
//
//  Created by Andres Vazquez on 2020-02-27.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import MapKit
import SafariServices
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Capital Maps"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(changeMapTypeBtnTapped))
        
        let london = Capital(title: "London", subtitle: "Home to the 2012 Summer Olympics", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275))
        let oslo = Capital(title: "Oslo", subtitle: "Founded over a thousand years ago.", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75))
        let paris = Capital(title: "Paris", subtitle: "Often called the City of Light.", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508))
        let rome = Capital(title: "Rome", subtitle: "Has a whole country inside it.", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5))
        let washington = Capital(title: "Washington D.C.", subtitle: "Named after George himself.", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), wikiPageURL: "Washington,_D.C.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }
    
    // MARK: - MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital, capital.title != nil else { return }
        
        let wikiPage = capital.wikiPageURL != nil ? capital.wikiPageURL! : capital.title!
        
        if let wikiURL = URL(string: "https://en.wikipedia.org/wiki/" + wikiPage){
            let safariVC = SFSafariViewController(url: wikiURL)
            present(safariVC, animated: true)
        }
    }
    
    
    // MARK: - Custom methods
    @objc private func changeMapTypeBtnTapped() {
        let ac = UIAlertController(title: "Change map type", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: { [weak mapView] _ in
            mapView?.mapType = .standard
        }))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { [weak mapView] _ in
            mapView?.mapType = .satellite
        }))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { [weak mapView] _ in
            mapView?.mapType = .hybrid
        }))
        ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: { [weak mapView] _ in
            mapView?.mapType = .satelliteFlyover
        }))
        ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: { [weak mapView] _ in
            mapView?.mapType = .hybridFlyover
        }))
        ac.addAction(UIAlertAction(title: "Muted Standard", style: .default, handler: { [weak mapView] _ in
            mapView?.mapType = .mutedStandard
        }))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
}
