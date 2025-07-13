//
//  AppointmentLocationMapView.swift
//  SWEEPLYPRO
//
//  Created on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct AppointmentLocationMapView: View {
    let location: String
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var locationCoordinate: CLLocationCoordinate2D?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                Color(hex: "#F8F8F6")
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#246BFD")))
                    )
            } else {
                if let coordinate = locationCoordinate {
                    // Using UIViewRepresentable for native MapKit behavior
                    LocationMapViewRepresentable(
                        region: $region,
                        showsUserLocation: true,
                        annotationCoordinate: coordinate,
                        annotationTitle: location
                    )
                } else {
                    Color(hex: "#F8F8F6")
                        .overlay(
                            Text("Location not found")
                                .foregroundColor(Color(hex: "#5A7184"))
                        )
                }
            }
            
            // Control buttons overlay
            VStack {
                // Center on me button (top right)
                HStack {
                    Spacer()
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#246BFD"))
                            .padding(10)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                
                Spacer()
                
                // Open in Maps button (bottom right)
                HStack {
                    Spacer()
                    Button(action: {
                        openInMaps()
                    }) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#246BFD"))
                            .padding(8)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(16)
                }
            }
        }
        .onAppear {
            geocodeAddress()
        }
    }
    
    private func geocodeAddress() {
        isLoading = true
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { placemarks, error in
            isLoading = false
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                self.locationCoordinate = location.coordinate
                
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
    
    private func openInMaps() {
        guard let coordinate = locationCoordinate else { return }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = self.location
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        } else {
            // If location is not available, request permission
            locationManager.requestLocationPermission()
        }
    }
}

// UIViewRepresentable wrapper for MKMapView with annotation
struct LocationMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var showsUserLocation: Bool
    var annotationCoordinate: CLLocationCoordinate2D
    var annotationTitle: String
    
    // Create the MKMapView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.region = region
        
        // Enable all standard gestures
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        // Configure POI filtering to show only gas stations and EV chargers
        let filterCategories: [MKPointOfInterestCategory] = [.gasStation, .evCharger]
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: filterCategories)
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationCoordinate
        annotation.title = annotationTitle.isEmpty ? "Location" : annotationTitle
        mapView.addAnnotation(annotation)
        
        return mapView
    }
    
    // Update the view when SwiftUI state changes
    func updateUIView(_ view: MKMapView, context: Context) {
        // Only update region if it's significantly different to avoid interrupting user interactions
        if shouldUpdateRegion(view.region, newRegion: region) {
            view.setRegion(region, animated: true)
        }
        
        // Update annotation if needed
        if view.annotations.count > 0 {
            if let annotation = view.annotations.first as? MKPointAnnotation {
                if annotation.coordinate.latitude != annotationCoordinate.latitude ||
                   annotation.coordinate.longitude != annotationCoordinate.longitude {
                    annotation.coordinate = annotationCoordinate
                }
                if annotation.title != annotationTitle {
                    annotation.title = annotationTitle
                }
            }
        }
    }
    
    // Determine if we should update the region
    private func shouldUpdateRegion(_ currentRegion: MKCoordinateRegion, newRegion: MKCoordinateRegion) -> Bool {
        // Calculate distance between centers
        let currentCenter = CLLocation(latitude: currentRegion.center.latitude, longitude: currentRegion.center.longitude)
        let newCenter = CLLocation(latitude: newRegion.center.latitude, longitude: newRegion.center.longitude)
        let distance = currentCenter.distance(from: newCenter)
        
        // Calculate span difference
        let spanDifference = abs(currentRegion.span.latitudeDelta - newRegion.span.latitudeDelta) + 
                            abs(currentRegion.span.longitudeDelta - newRegion.span.longitudeDelta)
        
        // Update if significant change
        return distance > 50 || spanDifference > 0.01
    }
    
    // Create coordinator to handle delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class for delegate callbacks
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocationMapViewRepresentable
        private var isUserInteraction = false
        
        init(_ parent: LocationMapViewRepresentable) {
            self.parent = parent
        }
        
        // Called when user begins interaction with the map
        func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
            isUserInteraction = true
        }
        
        // Called when region will change
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            isUserInteraction = !animated // If not animated, likely user interaction
        }
        
        // Update the binding when the map is moved by user
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Only update the binding if this is from user interaction, not from our own setRegion call
            if isUserInteraction {
                DispatchQueue.main.async {
                    self.parent.region = mapView.region
                }
            }
            isUserInteraction = false
        }
        
        // Customize annotation view
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize user location blue dot
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "AppointmentPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerAnnotationView = annotationView as? MKMarkerAnnotationView {
                markerAnnotationView.markerTintColor = UIColor(red: 36/255, green: 107/255, blue: 253/255, alpha: 1.0) // #246BFD
            }
            
            return annotationView
        }
    }
}

// Preview
#Preview {
    AppointmentLocationMapView(location: "123 Main St, San Francisco, CA")
        .frame(height: 120)
} 