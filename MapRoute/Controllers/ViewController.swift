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
    var last_coordinates = CLLocationCoordinate2D()
    var button_clear = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetup()
        
        mapRouteSetup()
    }
    
    
    //MARK: - Methods
    func layoutSetup(){
        
        // clear button setup
        button_clear.backgroundColor = .lightGray
        button_clear.layer.borderColor = UIColor.black.cgColor
        button_clear.layer.borderWidth = 1
        button_clear.layer.cornerRadius = 5
        button_clear.setImage(UIImage(named: "ic_close"), for: .normal)
        view.addSubview(button_clear)
        button_clear.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button_clear.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            button_clear.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            button_clear.heightAnchor.constraint(equalToConstant: 50),
            button_clear.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        // map view setup
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
        
        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.delegate = self
        view_map.addGestureRecognizer(longPressGesture)
    }
    
    func mapRouteSetup(){
        
        self.startLoader()
        
        // Add a location to start (VIP Circle)
        let source_location = CLLocationCoordinate2D(latitude: 21.231563, longitude: 72.866245)
        
        // Add a location to end (Kamrej)
        let destination_location = CLLocationCoordinate2D(latitude: 21.270000, longitude: 72.958000)
        last_coordinates = destination_location
        
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
        
        // Add annotations
        self.addAnnonation(coordinate: source_location, initial: true)
        self.addAnnonation(coordinate: destination_location, initial: true)
        
        // Create a directions object
        let directions = MKDirections(request: request)
        
        // Calculate the route
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            
            guard let response = response else {
                if let error = error {
                    print("Error getting directions: \(error.localizedDescription)")
                    self.showPopup(message: "Error getting directions: \(error.localizedDescription)")
                }
                return
            }

            // Get all routes
                       for route in response.routes {
                           // Add each route as a separate overlay
                           self.view_map.addOverlay(route.polyline, level: .aboveRoads)
                       }
                       
                       // Get the bounding map rect to cover both source, destination, and route
                       if let firstRoute = response.routes.first {
                           let sourceRect = firstRoute.polyline.boundingMapRect
                           self.view_map.setVisibleMapRect(sourceRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
                       }
        }
    }
    
    func addStops(coordinates: CLLocationCoordinate2D){
        // Create a request for directions
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: last_coordinates))
        last_coordinates = coordinates // for set current desctination to source location for next time
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        request.transportType = .automobile
        
        // Create a directions object
        let directions = MKDirections(request: request)
        
        // Calculate the route
        directions.calculate { [weak self] (response, error) in
            guard let self = self else {
                self?.stopLoader()
                return
            }
            
            guard let response = response else {
                if let error = error {
                    print("Error getting directions: \(error.localizedDescription)")
                    self.showPopup(message: "Error getting directions: \(error.localizedDescription)")
                }else{
                    self.stopLoader()
                }
                return
            }
            
            // Get all routes
            for route in response.routes {
                // route as a separate overlay
                self.view_map.addOverlay(route.polyline, level: .aboveRoads)
                // region to show all routes
                self.view_map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
            self.stopLoader()
        }
    }
    
    func addAnnonation(coordinate: CLLocationCoordinate2D, initial: Bool = false){
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                self.showPopup(message: "Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                self.showPopup(message: "No placemark found")
                return
            }
            
            // address string
            var address_string = ""
            if let name = placemark.name {
                address_string += name + ", "
            }
            if let sub_locality = placemark.subLocality {
                address_string += sub_locality + ", "
            }
            if let locality = placemark.locality {
                address_string += locality + ", "
            }
            if let administrative_area = placemark.administrativeArea {
                address_string += administrative_area + " "
            }
            if let postal_code = placemark.postalCode {
                address_string += postal_code
            }
            
            // Add annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = placemark.name ?? placemark.locality ?? "unknown"
            annotation.subtitle = address_string
            self.view_map.addAnnotation(annotation)
            
            if !initial{
                // draw route for selected destnation
                self.addStops(coordinates: coordinate)
            }else{
                self.stopLoader()
            }
            
        }
    }
    
    //MARK: - Actions
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: view_map)
            let coordinate = view_map.convert(touchPoint,toCoordinateFrom: view_map)
            
            self.startLoader()
            self.addAnnonation(coordinate: coordinate)
        }
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.random()
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           guard annotation is MKPointAnnotation else {
               return nil
           }
           
           let identifier = "Annotation"
           var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
           
           if annotationView == nil {
               annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
               annotationView!.canShowCallout = true
               let detailButton = UIButton(type: .detailDisclosure)
               annotationView!.rightCalloutAccessoryView = detailButton
           } else {
               annotationView!.annotation = annotation
           }
           
           return annotationView
       }
       
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
          // Handle when the callout accessory is tapped
          if control == view.rightCalloutAccessoryView {
              if let annotation = view.annotation {
                  let alertController = UIAlertController(title: annotation.title ?? "", message: annotation.subtitle ?? "", preferredStyle: .alert)
                  let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                  alertController.addAction(okAction)
                  present(alertController, animated: true, completion: nil)
              }
          }
      }
    
}
