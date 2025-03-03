//
//  PlayerHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct PlayerHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let player: Player
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(AppColors.accent)
            
            Text(player.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text(for: colorScheme))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground(for: colorScheme))
        .cornerRadius(15)
    }
}
