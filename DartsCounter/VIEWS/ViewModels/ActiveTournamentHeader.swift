//
//  ActiveTournamentHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 13.02.25.
//
import SwiftUI

struct ActiveTournamentHeader: View {
    @Environment(\.colorScheme) private var colorScheme
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
                .foregroundColor(AppColors.text(for: colorScheme))
            
            HStack {
                Text("Punktzahl: \(tournament.gamePoints.description)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText(for: colorScheme))
                
                Spacer()
                
                Text("Modus: \(modusText)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText(for: colorScheme))
            }
            
            Text("\(completedMatches) von \(totalMatches) Spielen abgeschlossen")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText(for: colorScheme))
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppColors.cardBackground(for: colorScheme))
    }
}
