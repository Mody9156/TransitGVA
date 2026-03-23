//
//  TPGResponse.swift
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
