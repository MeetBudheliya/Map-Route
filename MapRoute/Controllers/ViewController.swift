//
//  ViewController.swift
//  MapRoute
//
//  Created by Meet's Mac on 13/03/24.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    //MARK: - UI Variables
    var view_map = MKMapView()
    
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
    
}
