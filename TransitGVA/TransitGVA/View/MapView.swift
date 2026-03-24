//
//  MapView.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var vm       = MapViewModel()
    @StateObject private var location = LocationService.shared

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // MARK: Carte principale
            Map(
                coordinateRegion: $vm.region,
                showsUserLocation: true,
                annotationItems: vm.stops
            ) { stop in
                MapAnnotation(coordinate: stop.coordinate) {
                    StopPin(stop: stop, isSelected: vm.selectedStop?.id == stop.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                vm.selectedStop = stop
                            }
                        }
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear { location.startUpdating() }
            .onDisappear { location.stopUpdating() }
            // Recharge les arrêts quand la région change
            .onChange(of: vm.region.center.latitude) { _ in
                vm.onRegionChanged()
            }

            // MARK: Boutons flottants
            VStack(spacing: 12) {
                // Centrer sur ma position
                MapButton(icon: "location.fill") {
                    vm.centerOnUser()
                }

                // Recharger manuellement
                MapButton(icon: vm.isLoadingStops ? "arrow.clockwise" : "arrow.clockwise") {
                    vm.loadNearbyStops()
                }
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100)

            // MARK: Fiche arrêt (bottom sheet)
            if let stop = vm.selectedStop {
                StopDetailSheet(stop: stop) {
                    withAnimation { vm.selectedStop = nil }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Pin d'arrêt

struct StopPin: View {
    let stop: StopAnnotation
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.white)
                    .frame(width: isSelected ? 36 : 28,
                           height: isSelected ? 36 : 28)
                    .shadow(radius: isSelected ? 4 : 2)

                Image(systemName: "tram.fill")
                    .font(.system(size: isSelected ? 16 : 12))
                    .foregroundStyle(isSelected ? .white : .blue)
            }

            // Petite flèche en bas
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundStyle(isSelected ? Color.blue : Color.white)
                .offset(y: -2)
        }
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

// MARK: - Bottom sheet arrêt

struct StopDetailSheet: View {
    let stop: StopAnnotation
    let onClose: () -> Void

    @StateObject private var vm: DeparturesViewModel

    init(stop: StopAnnotation, onClose: @escaping () -> Void) {
        self.stop    = stop
        self.onClose = onClose
        _vm = StateObject(wrappedValue: DeparturesViewModel(stopName: stop.stopName))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.stopName)
                        .font(.headline)
                    if let lines = stop.subtitle {
                        Text(lines)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Prochains départs
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(vm.departures.prefix(5)) { dep in
                    DepartureRow(departure: dep)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(radius: 8)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 90)
        .task { await vm.loadDepartures() }
    }
}

// MARK: - Bouton flottant

struct MapButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
                .shadow(radius: 3)
        }
    }
}

#Preview {
    MapView()
}
