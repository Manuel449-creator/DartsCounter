//
//  ActiveTournamentHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 13.02.25.
//


import SwiftUI

struct ActiveTournamentHeader: View {
    let tournament: Tournament
    
    var completedMatches: Int {
        tournament.matches.filter { $0.isCompleted }.count
    }
    
    var totalMatches: Int {
        tournament.matches.filter { !$0.isBye }.count
    }
    
    var progress: Double {
        Double(completedMatches) / Double(totalMatches)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(tournament.players.count) Spieler")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(completedMatches) von \(totalMatches) Spielen abgeschlossen")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(maxWidth: .infinity)
        }
    }
}