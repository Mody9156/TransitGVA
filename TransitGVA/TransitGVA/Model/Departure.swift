//
//  Departure.swift
//  TransitGVA
//
//  Created by KEÏTA on 23/03/2026.
//

import Foundation

// Réponse brute de l'API TPG
struct TPGResponse: Codable {
    let departures: [TPGDeparture]

    enum CodingKeys: String, CodingKey {
        case departures = "Departures"
    }
}

struct TPGDeparture: Codable {
    let lineCode: String
    let destinationName: String
    let waitingTime: String       // ex: "5 min" ou "Departure"
    let timestamp: String?        // heure réelle ISO8601

    enum CodingKeys: String, CodingKey {
        case lineCode        = "line_code"
        case destinationName = "destination_name"
        case waitingTime     = "waiting_time"
        case timestamp       = "timestamp"
    }
}

// Modèle propre utilisé dans l'UI
struct Departure: Identifiable {
    let id = UUID()
    let line: String
    let destination: String
    let minutesLeft: Int          // -1 = "à quai"
    let scheduledTime: Date?

    var displayTime: String {
        if minutesLeft == 0 { return "à quai" }
        if minutesLeft < 0  { return "—" }
        return "\(minutesLeft) min"
    }

    var isImminent: Bool { minutesLeft >= 0 && minutesLeft <= 2 }
}
