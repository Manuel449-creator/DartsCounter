//
//  TournamentMatchView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 11.02.25.
//


struct TournamentMatchView: View {
    @ObservedObject var tournamentManager: TournamentManager
    let match: TournamentMatch
    @State private var showingMatchOptions = false
    
    var body: some View {
        Button(action: {
            showingMatchOptions = true
        }) {
            VStack(spacing: 8) {
                Text(match.phase.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(spacing: 4) {
                    PlayerMatchRow(
                        name: match.player1,
                        isWinner: match.winner == match.player1
                    )
                    
                    PlayerMatchRow(
                        name: match.player2,
                        isWinner: match.winner == match.player2
                    )
                }
                
                if let score = match.score {
                    Text(score)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(10)
        }
        .actionSheet(isPresented: $showingMatchOptions) {
            ActionSheet(title: Text("Match Optionen"), buttons: [
                .default(Text("Spiel starten")) {
                    // Navigation zum Spiel
                },
                .default(Text("Spieler bearbeiten")) {
                    // Spieler bearbeiten Sheet
                },
                .default(Text("Modus bearbeiten")) {
                    // Modus bearbeiten Sheet
                },
                .cancel()
            ])
        }
    }
}

struct PlayerMatchRow: View {
    let name: String
    let isWinner: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(isWinner ? .green : .white)
                .fontWeight(isWinner ? .bold : .regular)
            
            if isWinner {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
    }
}