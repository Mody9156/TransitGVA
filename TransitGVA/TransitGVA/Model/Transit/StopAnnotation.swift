//
//  StopAnnotation.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import MapKit

// Représente un arrêt de transport sur la carte
final class StopAnnotation: NSObject, MKAnnotation {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?        // ex: "Tram 18 · Bus 3 · Bus 10"
    let stopName: String

    init(
        id: UUID = UUID(),
        name: String,
        lines: [String],
        coordinate: CLLocationCoordinate2D
    ) {
        self.id         = id
        self.stopName   = name
        self.title      = name
        self.subtitle   = lines.joined(separator: " · ")
        self.coordinate = coordinate
    }
}
