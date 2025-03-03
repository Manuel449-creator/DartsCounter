import SwiftUI

struct MatchResultView: View {
    @Environment(\.colorScheme) private var colorScheme
    let match: TournamentMatch
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Spielergebnis")
                .font(.title)
                .foregroundColor(AppColors.text(for: colorScheme))
            
            VStack(spacing: 8) {
                HStack {
                    Text(match.player1)
                        .foregroundColor(match.winner == match.player1 ? .green : AppColors.text(for: colorScheme))
                    Text("vs")
                        .foregroundColor(AppColors.secondaryText(for: colorScheme))
                    Text(match.player2)
                        .foregroundColor(match.winner == match.player2 ? .green : AppColors.text(for: colorScheme))
                }
                
                if let score = match.score {
                    Text(score)
                        .font(.title2)
                        .foregroundColor(AppColors.accent)
                }
                
                Text("Gewinner: \(match.winner ?? "Nicht verfügbar")")
                    .foregroundColor(.green)
            }
            .padding()
            .background(AppColors.cardBackground(for: colorScheme))
            .cornerRadius(10)
        }
        .padding()
        .background(AppColors.background(for: colorScheme))
    }
}
