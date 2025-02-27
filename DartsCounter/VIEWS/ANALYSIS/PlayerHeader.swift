//
//  PlayerHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct PlayerHeader: View {
    let player: Player
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)
            
            Text(player.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.1))
        .cornerRadius(15)
    }
}
