//
//  TournamentPlayerRow.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 13.02.25.
//
import SwiftUI

struct TournamentPlayerRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppColors.accent : AppColors.secondaryText(for: colorScheme))
                
                Text(player.name)
                    .foregroundColor(AppColors.text(for: colorScheme))
                
                Spacer()
            }
            .padding()
            .background(AppColors.cardBackground(for: colorScheme))
            .cornerRadius(10)
        }
    }
}
