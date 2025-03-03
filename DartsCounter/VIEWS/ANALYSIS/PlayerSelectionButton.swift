//
//  PlayerSelectionButton.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct PlayerSelectionButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let player: Player
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                Text(player.name)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.accent : AppColors.cardBackground(for: colorScheme))
            .foregroundColor(isSelected ? .white : AppColors.text(for: colorScheme))
            .cornerRadius(25)
        }
    }
}
