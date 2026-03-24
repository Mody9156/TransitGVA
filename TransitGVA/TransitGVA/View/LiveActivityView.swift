//
//  LiveActivityView.swift
//  TransitGVA
//
//  Created by KEÏTA on 24/03/2026.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct TransitLiveActivityView: View {
    let attributes: TransitActivityAttributes
    let state: TransitActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {

            // Badge ligne
            Text(attributes.lineName)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 40, height: 28)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 7))

            // Infos destination
            VStack(alignment: .leading, spacing: 2) {
                Text(attributes.destination)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                Text(attributes.stopName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Compte à rebours
            VStack(alignment: .trailing, spacing: 1) {
                Text(state.isImminent ? "À quai" : "\(state.minutesLeft) min")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(state.isImminent ? .red : .primary)
                    .contentTransition(.numericText())

                Text(state.nextDeparture)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Widget Bundle (obligatoire pour Live Activities)

@main
struct TransitWidgetBundle: WidgetBundle {
    var body: some Widget {
        TransitGVAWidget()
        TransitLiveActivityWidget()
    }
}

// MARK: - Live Activity Widget declaration

struct TransitLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: TransitActivityAttributes.self
        ) { context in
            // Bandeau sur l'écran verrouillé / notification
            TransitLiveActivityView(
                attributes: context.attributes,
                state: context.state
            )
            .activityBackgroundTint(Color(.systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                // Vue étendue (appui long)
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.lineName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.minutesLeft) min")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(context.state.isImminent ? .red : .primary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.destination)
                            .font(.subheadline)
                        Spacer()
                        Text("dep. \(context.state.nextDeparture)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                // Vue compacte gauche (ligne)
                Text(context.attributes.lineName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
            } compactTrailing: {
                // Vue compacte droite (minutes)
                Text("\(context.state.minutesLeft)m")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(context.state.isImminent ? .red : .primary)
                    .contentTransition(.numericText())
            } minimal: {
                // Vue minimale (pastille)
                Text("\(context.state.minutesLeft)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
            }
        }
    }
}
#Preview {
    TransitLiveActivityView()
}
