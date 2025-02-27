import SwiftUI

struct TournamentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var tournamentManager: TournamentManager
    @ObservedObject var playerManager: PlayerManager
    @State private var showingNewTournamentSheet = false
    
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
        self._tournamentManager = StateObject(wrappedValue: TournamentManager(
            historyManager: MatchHistoryManager(),
            playerManager: playerManager
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
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
                                    TournamentCard(
                                        tournamentManager: tournamentManager,
                                        tournament: tournament
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Turniere")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: $showingNewTournamentSheet) {
            CreateTournamentView(
                tournamentManager: tournamentManager,
                playerManager: playerManager
            )
        }
    }
}
