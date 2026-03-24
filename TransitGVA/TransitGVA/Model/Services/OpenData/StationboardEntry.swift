//
//  StationboardEntry.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import Foundation

 struct StationboardEntry: Codable {
    let number: String       // numéro de ligne, ex: "18"
    let to: String           // destination
    let stop: StopInfo
}
