//
//  ActiveTournamentHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 13.02.25.
//


import SwiftUI

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
        totalMatches > 0 ? min(1.0, max(0.0, Double(completedMatches) / Double(totalMatches))) : 0
    }
    
    var modusText: String {
        tournament.tournamentMode == .sets ? "Sets (\(tournament.legsToWin.description))" : "Legs (\(tournament.legsToWin.description))"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(tournament.players.count) Spieler")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Text("Punktzahl: \(tournament.gamePoints.description)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Modus: \(modusText)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text("\(completedMatches) von \(totalMatches) Spielen abgeschlossen")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(maxWidth: .infinity)
        }
    }
}
