//
//  LiveActivityAttributes.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import ActivityKit
import Foundation

// Définit les données d'une Live Activity TransitGVA
struct TransitActivityAttributes: ActivityAttributes {

    // Données FIXES pendant toute la durée de l'activité
    public struct ContentState: Codable, Hashable {
        var minutesLeft: Int        // temps restant en minutes
        var isImminent: Bool        // < 2 min
        var nextDeparture: String   // heure ex: "14:32"
    }

    // Données qui NE CHANGENT PAS
    let lineName: String            // ex: "18"
    let destination: String         // ex: "Meyrin-Gravière"
    let stopName: String            // ex: "Cornavin"
}
