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
        
        // Met à jour la Live Activity si elle est active
        if let first = departures.first,
           let time  = first.scheduledTime {
            let formatted = time.formatted(date: .omitted, time: .shortened)
            await LiveActivityService.shared.update(
                minutesLeft:   first.minutesLeft,
                departureTime: formatted
            )
        }

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

    // Nouveau : l'utilisateur appuie sur "Suivre ce départ"
    func trackDeparture(_ departure: Departure) {
        guard let time = departure.scheduledTime else { return }
        LiveActivityService.shared.start(
            line:          departure.line,
            destination:   departure.destination,
            stopName:      "Cornavin",
            minutesLeft:   departure.minutesLeft,
            departureTime: time.formatted(date: .omitted, time: .shortened)
        )
    }
//    ```
//
//    ---
//
//    ### ⚙️ Config Xcode requise
//    ```
//    1. Ajouter une nouvelle target :
//       File > New > Target > Widget Extension
//       → Cocher "Include Live Activity"
//
//    2. Activer App Groups :
//       App target + Widget target → Signing & Capabilities
//       → App Groups → "group.ch.transitgva"
//
//    3. Info.plist de l'app principale :
//       <key>NSSupportsLiveActivities</key>
//       <true/>
}
