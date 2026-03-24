//
//  DeparturesView.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import SwiftUI

struct DeparturesView: View {
    @StateObject private var vm = DeparturesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Chargement…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let error = vm.errorMessage {
                    ContentUnavailableView(
                        "Impossible de charger",
                        systemImage: "wifi.exclamationmark",
                        description: Text(error)
                    )

                } else {
                    List(vm.departures) { dep in
                        DepartureRow(departure: dep)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .refreshable { await vm.loadDepartures() }
                }
            }
            .navigationTitle("Cornavin")
            .navigationBarTitleDisplayMode(.large)
        }
        .task { vm.startAutoRefresh() }
        .onDisappear { vm.stopAutoRefresh() }
    }
}

// MARK: - Ligne de départ

struct DepartureRow: View {
    let departure: Departure

    var body: some View {
        HStack(spacing: 14) {

            // Badge ligne
            Text(departure.line)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 46, height: 30)
                .background(lineColor(departure.line), in: RoundedRectangle(cornerRadius: 8))

            // Destination
            VStack(alignment: .leading, spacing: 2) {
                Text(departure.destination)
                    .font(.system(size: 15, weight: .medium))
                if let time = departure.scheduledTime {
                    Text(time, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Temps restant
            Text(departure.displayTime)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(departure.isImminent ? .red : .primary)
                .contentTransition(.numericText())  // animation fluide
        }
        .padding(.vertical, 6)
    }

    // Couleurs par famille de transport genevois
    private func lineColor(_ line: String) -> Color {
        switch line {
        case "D", "E", "G", "H", "K",
             "L", "M", "O", "P", "Q": return .orange      // Tram
        case let l where Int(l) != nil: return .blue       // Bus
        default: return .purple                            // Train/autre
        }
    }
}

#Preview {
    DeparturesView()
}
