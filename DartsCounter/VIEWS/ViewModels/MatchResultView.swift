import SwiftUI

struct MatchResultView: View {
    let match: TournamentMatch
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Spielergebnis")
                .font(.title)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                HStack {
                    Text(match.player1)
                        .foregroundColor(match.winner == match.player1 ? .green : .white)
                    Text("vs")
                        .foregroundColor(.gray)
                    Text(match.player2)
                        .foregroundColor(match.winner == match.player2 ? .green : .white)
                }
                
                if let score = match.score {
                    Text(score)
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Text("Gewinner: \(match.winner ?? "Nicht verfügbar")")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(10)
        }
        .padding()
    }
}
