//
//  TPGDeparture.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import Foundation

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
