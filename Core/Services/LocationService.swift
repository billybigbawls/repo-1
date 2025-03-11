//
//  LocationService.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var locationUpdateTimer: Timer?
    
    @Published var currentLocation: CLLocation?
    @Published var locationContext: Message.LocationContext?
    @Published var durationAtLocation: TimeInterval = 0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoring() {
        locationManager.startUpdatingLocation()
        startLocationDurationTimer()
    }
    
    private func startLocationDurationTimer() {
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateLocationDuration()
        }
    }
    
    private func updateLocationDuration() {
        durationAtLocation += 1
        if durationAtLocation >= 180 { // 3 minutes
            analyzeCurrentLocation()
        }
    }
    
    private func analyzeCurrentLocation() {
        guard let location = currentLocation else { return }
        
        let context = Message.LocationContext(
            coordinates: Message.Coordinates(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            ),
            placeName: "Current Location",
            placeType: "Unknown",
            duration: durationAtLocation
        )
        
        locationContext = context
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if currentLocation?.distance(from: location) ?? 0 > 50 {
            // Reset duration when location changes significantly
            durationAtLocation = 0
            currentLocation = location
        }
    }
}
