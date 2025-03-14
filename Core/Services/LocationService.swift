//
//  LocationService.swift
//  Squad
//
//  Created for Squad App
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func checkLocationAuthorization(completion: @escaping (Bool) -> Void) {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            completion(false)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            if let location = locationManager.location {
                completion(location)
            } else {
                completion(nil)
            }
        default:
            completion(nil)
        }
    }
    
    func getCurrentWeather(completion: @escaping (WeatherState.WeatherCondition?) -> Void) {
        getCurrentLocation { location in
            guard let location = location else {
                completion(nil)
                return
            }
            
            // In a real app, you would use WeatherKit or another weather API
            // For this example, we'll use a simplified approach
            self.fetchWeatherData(for: location) { weatherCondition in
                completion(weatherCondition)
            }
        }
    }
    
    private func fetchWeatherData(for location: CLLocation, completion: @escaping (WeatherState.WeatherCondition?) -> Void) {
        // Simulated weather API call
        // In a real app, you would call a weather service API
        
        // For testing, we'll return a random weather condition or base it on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Simple logic to determine weather based on time
        if hour >= 22 || hour < 6 {
            // Night time - higher chance of clear skies
            let conditions: [WeatherState.WeatherCondition] = [.clear, .clear, .cloudy]
            completion(conditions.randomElement())
        } else if hour >= 6 && hour < 12 {
            // Morning - mix of conditions
            let conditions: [WeatherState.WeatherCondition] = [.clear, .cloudy, .rain]
            completion(conditions.randomElement())
        } else {
            // Afternoon/evening - more variety
            let conditions: [WeatherState.WeatherCondition] = [.clear, .cloudy, .rain, .snow]
            completion(conditions.randomElement())
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates if needed
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle authorization changes if needed
    }
}
