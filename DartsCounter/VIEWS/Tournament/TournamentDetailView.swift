import SwiftUI

struct TournamentDetailView: View {
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    @Environment(\.dismiss) var dismiss
    @State private var selectedView = 0 // 0 = Spiele, 1 = Turnierbaum
    @State private var showingMatchOptions = false
    @State private var selectedMatch: TournamentMatch?
    @State private var showingGameView = false
    @State private var showingEditMatchSheet = false
    @State private var showingDeleteMatchAlert = false
    @State private var refreshTrigger = UUID() // Neuer Aktualisierungstrigger

    
    var upcomingMatches: [TournamentMatch] {
        tournament.matches.filter { !$0.isCompleted && !$0.isBye }
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            if tournament.isCompleted {
                CompletedTournamentHeader(tournament: tournament)
            } else {
                ActiveTournamentHeader(tournament: tournament)
            }
            
            // View Selector
            Picker("Ansicht", selection: $selectedView) {
                Text("Spiele").tag(0)
                Text("Turnierbaum").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            .id(refreshTrigger) // Erzwingt Neuzeichnung wenn sich der Trigger ändert
                   .onAppear {
                       // Generiere neuen Trigger bei jedem Erscheinen
                       refreshTrigger = UUID()
                   }
            
            if selectedView == 0 {
                // Upcoming Matches View
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(upcomingMatches) { match in
                            UpcomingMatchCard(
                                match: match,
                                onTap: {
                                    selectedMatch = match
                                    showingMatchOptions = true
                                }
                            )
                        }
                    }
                    .padding()
                }
            } else {
                // Tournament Bracket View
                TournamentBracketView(
                    tournamentManager: tournamentManager,
                    tournament: tournament
                )
            }
        }
        .actionSheet(isPresented: $showingMatchOptions) {
            ActionSheet(
                title: Text("Spiel Optionen"),
                message: Text(getMatchDescription()),
                buttons: [
                    .default(Text("Spiel starten")) {
                        showingGameView = true
                    },
                    .default(Text("Spieler bearbeiten")) {
                        showingEditMatchSheet = true
                    },
                    .destructive(Text("Spiel löschen")) {
                        showingDeleteMatchAlert = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingEditMatchSheet) {
            if let match = selectedMatch {
                EditMatchView(
                    tournamentManager: tournamentManager,
                    tournament: tournament,
                    match: match
                )
            }
        }
        .alert(isPresented: $showingDeleteMatchAlert) {
            Alert(
                title: Text("Spiel löschen"),
                message: Text("Möchtest du dieses Spiel wirklich löschen?"),
                primaryButton: .destructive(Text("Löschen")) {
                    if let match = selectedMatch {
                        tournamentManager.deleteMatch(tournamentId: tournament.id, matchId: match.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .fullScreenCover(isPresented: $showingGameView) {
            if let match = selectedMatch {
                GameView(
                                    gameMode: .fiveZeroOne,
                                    opponentType: .human,
                                    botDifficulty: .easy,
                                    guestName: match.player2,
                                    homeName: match.player1,
                                    historyManager: tournamentManager.historyManager,
                                    playerManager: tournamentManager.playerManager,
                                    numberOfSets: tournament.tournamentMode == .sets ? tournament.legsToWin.rawValue : 1,
                                    startingScore: tournament.gamePoints.rawValue,
                                    savedGameState: nil,
                                    matchId: match.id,
                                    onMatchComplete: { winner, score in
                                        tournamentManager.completeMatch(
                                            tournamentId: tournament.id,
                                            matchId: match.id,
                                            winner: winner,
                                            score: score
                                        )
                                    }
                                )
            }
        }
        .onDisappear {
            // Aktualisiere die Ansicht, wenn die GameView geschlossen wird
            refreshTrigger = UUID()
        }
        
        .onChange(of: upcomingMatches) { _, _ in
                            // Force view update
                            self.refreshTrigger = UUID()
                            tournamentManager.objectWillChange.send()
                        }
                        
                    // Erzwingt Aktualisierung beim Erscheinen der View
                    .onAppear {
                        // Sicherstellen, dass die Daten aktuell sind
                        tournamentManager.reloadTournaments()
                                   self.refreshTrigger = UUID()
                    }
    }
    
    private func getMatchDescription() -> String {
        guard let match = selectedMatch else { return "" }
        return "\(match.player1) vs \(match.player2)"
    }
}

struct UpcomingMatchCard: View {
    let match: TournamentMatch
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(match.phase.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    // Zeige "TBD" an, wenn der Spielername leer ist
                    Text(match.player1.isEmpty ? "TBD" : match.player1)
                        .foregroundColor(.white)
                    
                    Text("vs")
                        .foregroundColor(.gray)
                    
                    Text(match.player2.isEmpty ? "TBD" : match.player2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(white: 0.2))
            .cornerRadius(10)
        }
        .id(match.id) // Wichtig: Erzwingt Neuzeichnung bei Änderungen
    }
}

struct EditMatchView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    let match: TournamentMatch
    @State private var player1: String
    @State private var player2: String
    
    init(tournamentManager: TournamentManager, tournament: Tournament, match: TournamentMatch) {
        self.tournamentManager = tournamentManager
        self.tournament = tournament
        self.match = match
        _player1 = State(initialValue: match.player1)
        _player2 = State(initialValue: match.player2)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Spieler 1", selection: $player1) {
                    ForEach(tournament.players) { player in
                        Text(player.name).tag(player.name)
                    }
                }
                
                Picker("Spieler 2", selection: $player2) {
                    ForEach(tournament.players) { player in
                        Text(player.name).tag(player.name)
                    }
                }
            }
            .navigationTitle("Spieler bearbeiten")
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Speichern") {
                    tournamentManager.updateMatchPlayers(
                        tournamentId: tournament.id,
                        matchId: match.id,
                        player1: player1,
                        player2: player2
                    )
                    dismiss()
                }
                .disabled(player1 == player2)
            )
        }
    }
}
