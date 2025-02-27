//
//  PlayerSelectionButton.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct PlayerSelectionButton: View {
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
            .background(isSelected ? Color.blue : Color(white: 0.2))
            .foregroundColor(.white)
            .cornerRadius(25)
        }
    }
}
