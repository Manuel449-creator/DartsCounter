struct TournamentBracketView: View {
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .center, spacing: 20) {
                // Erste Runde
                VStack(spacing: 20) {
                    Text("1. Spieltag")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(tournament.matches.filter { $0.phase == .firstRound }) { match in
                        TournamentMatchView(
                            tournamentManager: tournamentManager,
                            match: match
                        )
                    }
                }
                
                // Viertelfinale
                if tournament.players.count > 4 {
                    VStack {
                        Text("Viertelfinale")
                            .font(.headline)
                            .foregroundColor(.white)
                        // ... ähnliche Struktur
                    }
                }
                
                // Halbfinale
                VStack {
                    Text("Halbfinale")
                        .font(.headline)
                        .foregroundColor(.white)
                    // ... ähnliche Struktur
                }
                
                // Finale
                VStack {
                    Text("Finale")
                        .font(.headline)
                        .foregroundColor(.white)
                    // ... ähnliche Struktur
                }
            }
            .padding()
        }
    }
}