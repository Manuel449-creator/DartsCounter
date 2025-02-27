import SwiftUI

struct CompletedTournamentHeader: View {
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
        VStack(spacing: 12) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            if let winner = tournament.winner {
                Text("Turniersieger")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text(winner)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(tournament.players.count) Spieler")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(completedMatches) von \(totalMatches) Spielen abgeschlossen")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(white: 0.1))
    }
}
