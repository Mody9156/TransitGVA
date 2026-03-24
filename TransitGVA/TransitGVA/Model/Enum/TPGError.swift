//
//  Enum.swift
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
