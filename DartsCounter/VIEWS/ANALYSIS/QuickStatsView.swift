//
//  QuickStatsView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct QuickStatsView: View {
    let stats: PlayerStatistics
    
    var body: some View {
        HStack(spacing: 15) {
            QuickStatItem(
                title: "Spiele",
                value: "\(stats.matches)",
                icon: "gamecontroller.fill"
            )
            
            QuickStatItem(
                title: "Siege",
                value: "\(stats.wins)",
                icon: "trophy.fill"
            )
            
            QuickStatItem(
                title: "Average",
                value: String(format: "%.1f", stats.averageScore),
                icon: "chart.bar.fill"
            )
        }
    }
}

struct QuickStatItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.accent)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text(for: colorScheme))
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.secondaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground(for: colorScheme))
        .cornerRadius(12)
    }
}
