//
//  ViewController.swift
//  MapRoute
//
//  Created by Meet's Mac on 13/03/24.
//

import UIKit
import MapKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Variables
    var view_map = MKMapView()
    var destinationCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetup()
        
        mapRouteSetup()
    }
    
    
    //MARK: - Methods
    func layoutSetup(){
        view.addSubview(view_map)
        view_map.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view_map.topAnchor.constraint(equalTo: view.topAnchor),
            view_map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view_map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view_map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set the delegate
        view_map.delegate = self
    }
    
    func mapRouteSetup(){
        
        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.delegate = self
        view_map.addGestureRecognizer(longPressGesture)
    
        // Add a location to start
        let source_location = CLLocationCoordinate2D(latitude: 21.231563, longitude: 72.866245)
        
        // Add a location to end
        let destination_location = CLLocationCoordinate2D(latitude: 21.213955, longitude: 72.862732)
        
        // Create MKPlacemark objects representing the start and end locations
        let source_placemark = MKPlacemark(coordinate: source_location, addressDictionary: nil)
        let destination_placemark = MKPlacemark(coordinate: destination_location, addressDictionary: nil)
        
        // Create MKMapItems for start and end locations
        let source_item = MKMapItem(placemark: source_placemark)
        let destination_item = MKMapItem(placemark: destination_placemark)
        
        // Create a request for directions
        let request = MKDirections.Request()
        request.source = source_item
        request.destination = destination_item
        request.transportType = .automobile
        
        // Create a directions object
        let directions = MKDirections(request: request)
        
        // Calculate the route
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error getting directions: \(error.localizedDescription)")
                }
                return
            }
            
            // Get the first route
            let route = response.routes[0]
            
            // Add the route to the map
            self.view_map.addOverlay(route.polyline, level: .aboveRoads)
            
            // Set the visible region to show the route
            self.view_map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    // MARK: - Gesture Recognizer
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: view_map)
            let coordinate = view_map.convert(touchPoint,toCoordinateFrom: view_map)
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                       let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("No placemark found")
                    return
                }
                
                // Construct the address string
                var addressString = ""
                if let name = placemark.name {
                    addressString += name + ", "
                }
                if let thoroughfare = placemark.thoroughfare {
                    addressString += thoroughfare + ", "
                }
                if let locality = placemark.locality {
                    addressString += locality + ", "
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressString += administrativeArea + " "
                }
                if let postalCode = placemark.postalCode {
                    addressString += postalCode
                }
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = addressString
//                annotation.subtitle = addressString
                self.view_map.addAnnotation(annotation)
                
                // Save destination coordinate
                self.destinationCoordinate = coordinate
                
            }
                           
        }
        
    }

    //MARK: - Actions
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation) else {
//            return nil
//        }
//
//        let reuseIdentifier = "AnnotationIdentifier"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//            annotationView?.canShowCallout = true
//            annotationView?.isUserInteractionEnabled = true
//
//            // Add a button as the right callout accessory view
//            let button = UIButton(type: .detailDisclosure)
//            annotationView?.detailCalloutAccessoryView = button
//
//        } else {
//            annotationView?.annotation = annotation
//        }
//
//        return annotationView
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("call out")
        guard let destinationCoordinate = destinationCoordinate else { return }
        
        // Create a request for directions
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        // Create a directions object
        let directions = MKDirections(request: request)
        
        // Calculate the route
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting directions: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, let route = response.routes.first else {
                print("No routes found")
                return
            }
            
            // Add the route to the map
            self.view_map.addOverlay(route.polyline, level: .aboveRoads)
            
            // Set the visible region to show the route
            self.view_map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
}
