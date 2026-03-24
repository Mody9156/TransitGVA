//
//  MapViewModel.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import MapKit
import Combine
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude:  46.2044,   // Genève, Cornavin
            longitude:  6.1432
        ),
        span: MKCoordinateSpan(
            latitudeDelta:  0.025,
            longitudeDelta: 0.025
        )
    )

    @Published var stops: [StopAnnotation]       = []
    @Published var selectedStop: StopAnnotation? = nil
    @Published var isLoadingStops                = false

    private let locationService = LocationService.shared
    private var cancellables    = Set<AnyCancellable>()

    init() {
        bindUserLocation()
        loadNearbyStops()
    }

    // Centre la carte sur la position GPS dès qu'elle est disponible
    private func bindUserLocation() {
        locationService.$userLocation
            .compactMap { $0 }
            .first()                        // une seule fois au démarrage
            .receive(on: RunLoop.main)
            .sink { [weak self] loc in
                withAnimation(.easeInOut(duration: 0.6)) {
                    self?.region.center = loc.coordinate
                }
            }
            .store(in: &cancellables)
    }

    // Charge les arrêts proches via opendata.ch /locations
    func loadNearbyStops(around center: CLLocationCoordinate2D? = nil) {
        let coord = center ?? region.center
        isLoadingStops = true

        Task {
            do {
                let results = try await TPGService.shared.fetchNearbyStops(
                    latitude:  coord.latitude,
                    longitude: coord.longitude,
                    limit: 20
                )
                stops          = results
                isLoadingStops = false
            } catch {
                isLoadingStops = false
            }
        }
    }

    // Appelé quand l'utilisateur arrête de déplacer la carte
    func onRegionChanged() {
        loadNearbyStops(around: region.center)
    }

    func centerOnUser() {
        guard let loc = locationService.userLocation else {
            locationService.requestPermission()
            return
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = loc.coordinate
        }
    }
}
