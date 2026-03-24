//
//  TransitGVAApp.swift
//  TransitGVA
//
//  Created by KEÏTA on 23/03/2026.
//

import SwiftUI

@main
struct TransitGVAApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                // Carte
                MapView()
                    .tabItem {
                        Image(systemName: "map")
                        Text("Carte")
                    }

                // Départs (liste des prochains départs)
                DeparturesView()
                    .tabItem {
                        Image(systemName: "tram.fill")
                        Text("Départs")
                    }

            }
        }
    }
}
