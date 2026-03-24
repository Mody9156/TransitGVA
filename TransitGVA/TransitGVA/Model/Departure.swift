//
//  Departure.swift
//  TransitGVA
//
//  Created by KEÏTA on 23/03/2026.
//

import Foundation

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
