//
//  LocationService.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {

    static let shared = LocationService()

    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate           = self
        manager.desiredAccuracy    = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter     = 20   // mise à jour tous les 20m
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // Distance depuis l'utilisateur vers un arrêt
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let userLoc = userLocation else { return nil }
        let dest = CLLocation(
            latitude:  coordinate.latitude,
            longitude: coordinate.longitude
        )
        return userLoc.distance(from: dest)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.userLocation = loc
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.locationError = error.localizedDescription
        }
    }
}
