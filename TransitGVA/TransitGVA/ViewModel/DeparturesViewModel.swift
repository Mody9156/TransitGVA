//
//  DeparturesViewModel.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import Foundation
import Combine

@MainActor
final class DeparturesViewModel: ObservableObject {

    @Published var departures: [Departure] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var refreshTask: Task<Void, Never>?
    private let stopName: String

    init(stopName: String = "Genève, gare Cornavin") {
        self.stopName = stopName
    }

    // Chargement initial + rafraîchissement auto toutes les 30s
    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await loadDepartures()
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
    }

    func loadDepartures() async {
        isLoading = departures.isEmpty   // spinner seulement au 1er chargement
        errorMessage = nil

        do {
            departures = try await TPGService.shared.fetchDepartures(
                stopName: stopName,
                limit: 12
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
