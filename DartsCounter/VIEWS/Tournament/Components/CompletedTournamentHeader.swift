import SwiftUI

struct CompletedTournamentHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let tournament: Tournament
    
    var completedMatches: Int {
        tournament.matches.filter { $0.isCompleted }.count
    }
    
    var totalMatches: Int {
        tournament.matches.filter { !$0.isBye }.count
    }
    
    var progress: Double {
        min(1.0, max(0.0, Double(completedMatches) / Double(totalMatches)))
    }
    
    var modusText: String {
        tournament.tournamentMode == .sets ? "Sets (\(tournament.legsToWin.description))" : "Legs (\(tournament.legsToWin.description))"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            if let winner = tournament.winner {
                Text("Turniersieger")
                    .font(.headline)
                    .foregroundColor(AppColors.secondaryText(for: colorScheme))
                
                Text(winner)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.text(for: colorScheme))
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(tournament.players.count) Spieler")
                        .font(.headline)
                        .foregroundColor(AppColors.text(for: colorScheme))
                    
                    Text("\(completedMatches) von \(totalMatches) Spielen abgeschlossen")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText(for: colorScheme))
                }
                
                Spacer()
                
                // Turnier-Statistiken
                VStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Abgeschlossen")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    Text("Modus: \(modusText)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText(for: colorScheme))
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppColors.cardBackground(for: colorScheme))
    }
}
