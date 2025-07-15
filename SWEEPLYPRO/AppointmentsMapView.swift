//
//  AppointmentsMapView.swift
//  SWEEPLYPRO
//
//  Created on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct AppointmentsMapView: View {
    // For now, we'll just accept an array of appointments but not use it
    // This will be implemented later
    let appointments: [Appointment]
    
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showGasStations = true
    @State private var showChargingStations = true
    @State private var showFilterOptions = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Service for fetching charging stations
    private let chargeMapService = OpenChargeMapService()
    
    // State for storing API data
    @State private var chargingStations: [ChargingStation] = []
    @State private var gasStations: [MKMapItem] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Using UIViewRepresentable for native MapKit behavior
            EnhancedMapViewRepresentable(
                region: $region, 
                showsUserLocation: true,
                showGasStations: showGasStations,
                showChargingStations: showChargingStations,
                appointments: appointments,
                chargingStations: chargingStations,
                gasStations: gasStations
            )
            .edgesIgnoringSafeArea(.all)
            
            // Control buttons
            VStack {
                HStack {
                    Spacer()
                    
                    // Filter button
                    Button(action: {
                        showFilterOptions.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#246BFD"))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(.trailing, 8)
                    
                    // Center on me button
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#246BFD"))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 16)
                }
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.bottom, 16)
                        .onAppear {
                            // Auto-dismiss error after 5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                self.errorMessage = nil
                            }
                        }
                }
                
                // Filter options panel
                if showFilterOptions {
                    VStack(spacing: 12) {
                        Text("Map Filters")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Divider()
                        
                        Toggle("Gas Stations (\(gasStations.count))", isOn: $showGasStations)
                            .padding(.horizontal)
                        
                        Toggle("Charging Stations (\(chargingStations.count))", isOn: $showChargingStations)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        Button("Refresh Data") {
                            if let location = locationManager.location {
                                fetchStations(near: location.coordinate)
                            } else {
                                errorMessage = "Location not available"
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 24)
                        .background(Color(hex: "#246BFD"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Close") {
                            showFilterOptions = false
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 24)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color(hex: "#246BFD"))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showFilterOptions)
                }
            }
        }
        .onAppear {
            // Center map on user's location when available
            if let location = locationManager.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                
                // Fetch stations when view appears
                fetchStations(near: location.coordinate)
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            // Update region when location changes, but only on first location update
            if let location = newLocation, locationManager.initialLocationSet == false {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                locationManager.initialLocationSet = true
                
                // Fetch stations when location is first determined
                fetchStations(near: location.coordinate)
            }
        }
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        } else {
            // If location is not available, request permission
            locationManager.requestLocationPermission()
        }
    }
    
    private func fetchStations(near coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        
        // Create a dispatch group to wait for both API calls
        let group = DispatchGroup()
        
        // Fetch charging stations
        group.enter()
        chargeMapService.fetchChargingStations(near: coordinate, radius: 20) { stations, error in
            defer { group.leave() }
            
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Error fetching charging stations: \(error.localizedDescription)"
                    return
                }
                
                if let stations = stations {
                    self.chargingStations = stations
                    print("Found \(stations.count) charging stations")
                }
            }
        }
        
        // Fetch gas stations
        group.enter()
        chargeMapService.fetchGasStations(near: coordinate, radius: 20000) { stations, error in
            defer { group.leave() }
            
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Error fetching gas stations: \(error.localizedDescription)"
                    return
                }
                
                if let stations = stations {
                    self.gasStations = stations
                    print("Found \(stations.count) gas stations")
                }
            }
        }
        
        // When both API calls complete
        group.notify(queue: .main) {
            isLoading = false
        }
    }
}

// Enhanced UIViewRepresentable wrapper for MKMapView with POI filtering
struct EnhancedMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var showsUserLocation: Bool
    var showGasStations: Bool
    var showChargingStations: Bool
    var appointments: [Appointment]
    var chargingStations: [ChargingStation]
    var gasStations: [MKMapItem]
    
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
        
        // Hide all default POIs
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        
        return mapView
    }
    
    // Update the view when SwiftUI state changes
    func updateUIView(_ view: MKMapView, context: Context) {
        // Only update region if it's significantly different to avoid interrupting user interactions
        if shouldUpdateRegion(view.region, newRegion: region) {
            view.setRegion(region, animated: true)
        }
        
        // Update annotations
        context.coordinator.updateAnnotations(
            on: view,
            appointments: appointments,
            chargingStations: showChargingStations ? chargingStations : [],
            gasStations: showGasStations ? gasStations : []
        )
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
        var parent: EnhancedMapViewRepresentable
        private var isUserInteraction = false
        
        // Track different types of annotations
        private var appointmentAnnotations: [MKPointAnnotation] = []
        private var chargingStationAnnotations: [MKPointAnnotation] = []
        private var gasStationAnnotations: [MKPointAnnotation] = []
        
        init(_ parent: EnhancedMapViewRepresentable) {
            self.parent = parent
        }
        
        // Update all annotations on the map
        func updateAnnotations(
            on mapView: MKMapView,
            appointments: [Appointment],
            chargingStations: [ChargingStation],
            gasStations: [MKMapItem]
        ) {
            // Remove existing annotations
            mapView.removeAnnotations(appointmentAnnotations)
            mapView.removeAnnotations(chargingStationAnnotations)
            mapView.removeAnnotations(gasStationAnnotations)
            
            appointmentAnnotations.removeAll()
            chargingStationAnnotations.removeAll()
            gasStationAnnotations.removeAll()
            
            // Add appointment annotations
            for appointment in appointments {
                let annotation = MKPointAnnotation()
                annotation.title = appointment.title
                annotation.subtitle = appointment.clientName
                
                // For demo purposes, we'll use a geocoder to convert the address to coordinates
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(appointment.location) { placemarks, error in
                    if let error = error {
                        print("Geocoding error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let placemark = placemarks?.first, let location = placemark.location {
                        annotation.coordinate = location.coordinate
                        
                        // Add to map on main thread
                        DispatchQueue.main.async {
                            mapView.addAnnotation(annotation)
                            self.appointmentAnnotations.append(annotation)
                        }
                    }
                }
            }
            
            // Add charging station annotations
            for station in chargingStations {
                let annotation = station.toAnnotation()
                mapView.addAnnotation(annotation)
                chargingStationAnnotations.append(annotation)
            }
            
            // Add gas station annotations
            for mapItem in gasStations {
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = "Gas Station"
                mapView.addAnnotation(annotation)
                gasStationAnnotations.append(annotation)
            }
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
        
        // Customize annotation views
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize user location
            if annotation is MKUserLocation {
                return nil
            }
            
            // Check if it's one of our appointment annotations
            if appointmentAnnotations.contains(where: { $0 === annotation as? MKPointAnnotation }) {
                let identifier = "AppointmentAnnotation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                    annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                
                annotationView?.markerTintColor = UIColor(Color(hex: "#246BFD"))
                annotationView?.glyphImage = UIImage(systemName: "calendar")
                annotationView?.annotation = annotation
                
                return annotationView
            }
            
            // Check if it's a charging station annotation
            if chargingStationAnnotations.contains(where: { $0 === annotation as? MKPointAnnotation }) {
                let identifier = "ChargingStationAnnotation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                    annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                
                annotationView?.markerTintColor = UIColor(Color(hex: "#4CAF50")) // Green
                annotationView?.glyphImage = UIImage(systemName: "bolt.fill")
                annotationView?.annotation = annotation
                
                return annotationView
            }
            
            // Check if it's a gas station annotation
            if gasStationAnnotations.contains(where: { $0 === annotation as? MKPointAnnotation }) {
                let identifier = "GasStationAnnotation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                    annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                }
                
                annotationView?.markerTintColor = UIColor(Color(hex: "#FF9800")) // Orange
                annotationView?.glyphImage = UIImage(systemName: "fuelpump.fill")
                annotationView?.annotation = annotation
                
                return annotationView
            }
            
            return nil
        }
        
        // Handle callout accessory taps
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else { return }
            
            // Open in Maps app
            let placemark = MKPlacemark(coordinate: annotation.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title ?? "Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}

// Preview with sample data
#Preview {
    AppointmentsMapView(appointments: [
        Appointment(
            title: "Window Cleaning",
            clientName: "John Smith",
            location: "123 Main St, San Francisco, CA",
            startTime: "7 PM",
            endTime: "8 PM",
            date: 6,
            color: "#246BFD"
        )
    ])
} 