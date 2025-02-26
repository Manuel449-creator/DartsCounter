import SwiftUI

struct TournamentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var tournamentManager = TournamentManager()
    @State private var showingNewTournamentSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Neues Turnier Button
                    Button(action: {
                        showingNewTournamentSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Neues Turnier erstellen")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Liste der Turniere
                    if tournamentManager.tournaments.isEmpty {
                        VStack {
                            Image(systemName: "trophy")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Keine Turniere vorhanden")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(tournamentManager.tournaments) { tournament in
                                    TournamentCard(tournament: tournament)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Turniere")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Zurück") {
                dismiss()
            })
        }
        .sheet(isPresented: $showingNewTournamentSheet) {
            CreateTournamentView(tournamentManager: tournamentManager)
        }
    }
}

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