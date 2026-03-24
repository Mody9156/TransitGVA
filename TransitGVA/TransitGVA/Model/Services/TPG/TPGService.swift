//
//  TPGService.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import Foundation
internal import _LocationEssentials


actor TPGService {
    static let shared = TPGService()

    private let baseURL = "https://transport.opendata.ch/v1"
    // 💡 Opendata.ch est l'API publique suisse qui inclut TPG + CFF
    //    Doc : https://transport.opendata.ch

    /// Récupère les prochains départs pour un arrêt donné
    func fetchDepartures(
        stopName: String,
        limit: Int = 10
    ) async throws -> [Departure] {

        // Construction de l'URL
        var components = URLComponents(string: "\(baseURL)/stationboard")!
        components.queryItems = [
            URLQueryItem(name: "station", value: stopName),
            URLQueryItem(name: "limit",   value: "\(limit)"),
            URLQueryItem(name: "type",    value: "departure")
        ]

        guard let url = components.url else {
            throw TPGError.invalidURL
        }

        // Appel réseau avec async/await
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw TPGError.networkError(error)
        }

        // Vérification du code HTTP
        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw TPGError.noData
        }

        // Décodage JSON
        do {
            let decoded = try JSONDecoder().decode(StationboardResponse.self, from: data)
            return decoded.stationboard.map { entry in
                mapToDeparture(entry)
            }
        } catch {
            throw TPGError.decodingError(error)
        }
    }

    /// Récupère les arrêts proches autour d'une coordonnée
    func fetchNearbyStops(
        latitude: Double,
        longitude: Double,
        limit: Int = 20
    ) async throws -> [StopAnnotation] {
        // Construire l'URL: /locations?x=lat&y=lon&type=station&limit=n
        var components = URLComponents(string: "\(baseURL)/locations")!
        components.queryItems = [
            URLQueryItem(name: "x", value: String(latitude)),
            URLQueryItem(name: "y", value: String(longitude)),
            URLQueryItem(name: "type", value: "station"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        guard let url = components.url else {
            throw TPGError.invalidURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw TPGError.networkError(error)
        }

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw TPGError.noData
        }

        // Décoder la réponse des locations
        do {
            let decoded = try JSONDecoder().decode(LocationsResponse.self, from: data)
            // Mapper vers StopAnnotation (en filtrant uniquement les stations avec coordonnées)
            let annotations: [StopAnnotation] = decoded.stations.compactMap { station in
                guard let lat = station.coordinate?.x, let lon = station.coordinate?.y else { return nil }
                let name = station.name
                let lines = station.products ?? []
                return StopAnnotation(
                    name: name,
                    lines: lines,
                    coordinate: .init(latitude: lat, longitude: lon)
                )
            }
            return annotations
        } catch {
            throw TPGError.decodingError(error)
        }
    }

    // MARK: - Mapping

    private func mapToDeparture(_ entry: StationboardEntry) -> Departure {
        let minutes = minutesUntil(isoString: entry.stop.departure)
        return Departure(
            line:          entry.number,
            destination:   entry.to,
            minutesLeft:   minutes,
            scheduledTime: parseDate(entry.stop.departure)
        )
    }

    private func minutesUntil(isoString: String?) -> Int {
        guard let str = isoString,
              let date = parseDate(str) else { return -1 }
        let diff = date.timeIntervalSinceNow
        return diff < 0 ? 0 : Int(diff / 60)
    }

    private func parseDate(_ str: String?) -> Date? {
        guard let str else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: str)
    }
    
    
    
}
// MARK: - Locations decoding
private struct LocationsResponse: Codable {
    let stations: [LocationStation]

    enum CodingKeys: String, CodingKey {
        case stations = "stations"
    }
}

private struct LocationStation: Codable {
    let name: String
    let coordinate: LocationCoordinate?
    let products: [String]? // list of lines if available (opendata may provide)
}

private struct LocationCoordinate: Codable {
    let x: Double? // latitude
    let y: Double? // longitude
}


