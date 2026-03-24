//
//  TransitWidgetView.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import SwiftUI

import WidgetKit
import SwiftUI
import Intents

// MARK: - Timeline Entry

struct TransitEntry: TimelineEntry {
    let date: Date
    let departures: [Departure]
    let stopName: String
}

// MARK: - Provider (charge les données)

struct TransitProvider: TimelineProvider {

    func placeholder(in context: Context) -> TransitEntry {
        TransitEntry(
            date: .now,
            departures: [
                Departure(line: "18", destination: "Meyrin-Gravière",
                          minutesLeft: 4, scheduledTime: nil),
                Departure(line: "3",  destination: "Onex-Cité",
                          minutesLeft: 8, scheduledTime: nil)
            ],
            stopName: "Cornavin"
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (TransitEntry) -> Void
    ) {
        completion(placeholder(in: context))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TransitEntry>) -> Void
    ) {
        Task {
            // Récupère l'arrêt favori depuis UserDefaults partagé (App Group)
            let stopName = SharedDefaults.favoriteStop ?? "Genève, gare Cornavin"

            let departures = (try? await TPGService.shared.fetchDepartures(
                stopName: stopName,
                limit: 5
            )) ?? []

            let entry = TransitEntry(
                date: .now,
                departures: departures,
                stopName: stopName
            )

            // Rafraîchissement toutes les 10 minutes
            let nextUpdate = Calendar.current.date(
                byAdding: .minute, value: 10, to: .now
            )!

            completion(Timeline(
                entries: [entry],
                policy: .after(nextUpdate)
            ))
        }
    }
}

// MARK: - Widget View

struct TransitWidgetView: View {
    let entry: TransitEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Header
            HStack {
                Image(systemName: "tram.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text(entry.stopName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Divider()

            // Lignes de départ
            let count = family == .systemSmall ? 3 : 5
            ForEach(entry.departures.prefix(count)) { dep in
                HStack {
                    Text(dep.line)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 18)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 5))

                    Text(dep.destination)
                        .font(.system(size: 12))
                        .lineLimit(1)

                    Spacer()

                    Text(dep.displayTime)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(dep.isImminent ? .red : .primary)
                }
            }

            Spacer(minLength: 0)

            // Heure de mise à jour
            Text("Mis à jour \(entry.date, style: .time)")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .containerBackground(.background, for: .widget)
    }
}

// MARK: - Widget declaration

struct TransitGVAWidget: Widget {
    let kind = "TransitGVAWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TransitProvider()) { entry in
            TransitWidgetView(entry: entry)
        }
        .configurationDisplayName("Prochains départs")
        .description("Affiche les départs depuis votre arrêt favori.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview {
    TransitWidgetView()
}
