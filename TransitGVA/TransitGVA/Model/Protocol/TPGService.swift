//
//  TPGService.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import Foundation

enum TPGError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "URL invalide"
        case .networkError(let e):  return "Erreur réseau : \(e.localizedDescription)"
        case .decodingError(let e): return "Erreur de décodage : \(e.localizedDescription)"
        case .noData:               return "Aucune donnée reçue"
        }
    }
}

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

// MARK: - Modèles internes (opendata.ch)

private struct StationboardResponse: Codable {
    let stationboard: [StationboardEntry]
}

private struct StationboardEntry: Codable {
    let number: String       // numéro de ligne, ex: "18"
    let to: String           // destination
    let stop: StopInfo
}

private struct StopInfo: Codable {
    let departure: String?   // ISO8601
}
