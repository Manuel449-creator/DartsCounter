import SwiftUI

struct AnalysisView: View {
    @ObservedObject var historyManager: MatchHistoryManager
    @ObservedObject var playerManager: PlayerManager
    @State private var selectedPlayer: Player?
    @State private var showingGameResumeSheet = false
    @State private var selectedMatch: Match?
        
    private func refreshStats() {
        // Lade die Daten explizit neu
        self.historyManager.reloadMatches()
        playerManager.loadPlayers()
        
        // Wenn ein Spieler ausgewählt ist, aktualisiere dessen Statistiken
        if let player = selectedPlayer {
            // Eine kleine Verzögerung, um sicherzustellen, dass die Daten geladen sind
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Erzwinge UI-Update durch temporäre Neuzuweisung
                let currentPlayer = player
                selectedPlayer = nil
                selectedPlayer = currentPlayer
            }
        }
    }
    
    private func getUnfinishedMatches(player: Player) -> [Match] {
        let playerMatches = historyManager.matches.filter { match in
            !match.isCompleted &&
            (match.player1 == player.name || match.player2 == player.name)
        }
        return playerMatches.sorted { $0.date > $1.date }
    }
    
    private func getCompletedMatches(player: Player) -> [Match] {
        let playerMatches = historyManager.matches.filter { match in
            match.isCompleted &&
            (match.player1 == player.name || match.player2 == player.name)
        }
        let sortedMatches = playerMatches.sorted { $0.date > $1.date }
        return Array(sortedMatches.prefix(5))
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Statistiken")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color(white: 0.1))
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Player Selection
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(playerManager.players) { player in
                                    PlayerSelectionButton(
                                        player: player,
                                        isSelected: selectedPlayer?.id == player.id,
                                        action: { selectedPlayer = player }
                                    )
                                }
                            }
                            .padding()
                        }
                        
                        if let player = selectedPlayer {
                            VStack(spacing: 20) {
                                PlayerHeader(player: player)
                                
                                QuickStatsView(stats: historyManager.getPlayerStatistics(for: player.name))
                                
                                DetailedStatsView(stats: historyManager.getPlayerStatistics(for: player.name))
                                
                                // Unfinished Matches
                                let unfinishedMatches = getUnfinishedMatches(player: player)
                                if !unfinishedMatches.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Unbeendete Spiele")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.top)
                                        
                                        ForEach(unfinishedMatches) { match in
                                            UnfinishedMatchRow(
                                                match: match,
                                                playerName: player.name,
                                                onResume: {
                                                    selectedMatch = match
                                                    showingGameResumeSheet = true
                                                },
                                                onDelete: {
                                                    historyManager.deleteMatch(id: match.id)
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                // Completed Matches
                                let completedMatches = getCompletedMatches(player: player)
                                RecentMatchesView(
                                    player: player,
                                    matches: completedMatches,
                                    historyManager: historyManager
                                )
                            }
                            .padding()
                        } else {
                            EmptyStateView()
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        
        
            
        .sheet(isPresented: $showingGameResumeSheet, onDismiss: {
                    selectedMatch = nil
                }) {
                    if let match = selectedMatch,
                       let gameState = match.gameState {
                        GameView(
                            gameMode: .fiveZeroOne,
                            opponentType: .human,
                            botDifficulty: .easy,
                            guestName: match.player2,
                            homeName: match.player1,
                            historyManager: historyManager,
                            playerManager: playerManager,
                            numberOfSets: gameState.numberOfSets,
                            startingScore: GamePoints.fiveOOne.rawValue,
                            savedGameState: gameState,
                            matchId: match.id,
                            onMatchComplete: { winner, score in
                                historyManager.updateMatch(match)
                            }
                        )
                    }
                }
                .onAppear {
                    refreshStats()
                }
                .onChange(of: selectedPlayer) { _, _ in
                    refreshStats()
        }
    }
    
    struct UnfinishedMatchRow: View {
        let match: Match
        let playerName: String
        let onResume: () -> Void
        let onDelete: () -> Void
        @State private var showingDeleteAlert = false
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: match.date)
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(match.player1) vs \(match.player2)")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: onResume) {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(12)
            .alert("Spiel löschen", isPresented: $showingDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Möchtest du dieses unbeendete Spiel wirklich löschen?")
            }
        }
    }
}
