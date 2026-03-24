//
//  LiveActivityService.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import ActivityKit
import Foundation

@MainActor
final class LiveActivityService {

    static let shared = LiveActivityService()

    private var currentActivity: Activity<TransitActivityAttributes>?

    // MARK: - Démarrer une Live Activity

    func start(
        line: String,
        destination: String,
        stopName: String,
        minutesLeft: Int,
        departureTime: String
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TransitActivityAttributes(
            lineName:    line,
            destination: destination,
            stopName:    stopName
        )

        let state = TransitActivityAttributes.ContentState(
            minutesLeft:    minutesLeft,
            isImminent:     minutesLeft <= 2,
            nextDeparture:  departureTime
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: state,
                pushType: nil          // pas de push APNs pour ce portfolio
            )
        } catch {
            print("Erreur Live Activity : \(error)")
        }
    }

    // MARK: - Mettre à jour (appelé toutes les ~30s par le ViewModel)

    func update(minutesLeft: Int, departureTime: String) async {
        let newState = TransitActivityAttributes.ContentState(
            minutesLeft:   minutesLeft,
            isImminent:    minutesLeft <= 2,
            nextDeparture: departureTime
        )
        await currentActivity?.update(using: newState)
    }

    // MARK: - Arrêter (départ passé)

    func stop() async {
        await currentActivity?.end(
            using: nil,
            dismissalPolicy: .after(.now + 5)  // disparaît 5s après
        )
        currentActivity = nil
    }
}

// MARK: - UserDefaults partagé (App Group)

enum SharedDefaults {
    static let suiteName = "group.ch.transitgva"
    static var favoriteStop: String? {
        get { UserDefaults(suiteName: suiteName)?.string(forKey: "favoriteStop") }
        set { UserDefaults(suiteName: suiteName)?.set(newValue, forKey: "favoriteStop") }
    }
}
