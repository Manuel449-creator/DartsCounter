import SwiftUI

struct TournamentCard: View {
    let tournament: Tournament
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: tournament.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tournament.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(tournament.players.count) Spieler")
                .font(.caption)
                .foregroundColor(.gray)
            
            if let winner = tournament.winner {
                Text("Gewinner: \(winner)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.15))
        .cornerRadius(10)
    }
}