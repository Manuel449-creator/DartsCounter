//
//  TournamentCard.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 10.02.25.
//


import SwiftUI

struct TournamentCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    @State private var showingActionSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingGameView = false
    @State private var selectedMatch: TournamentMatch?
    
    private func debugGameSettings() {
        print("Debug - Tournament Points: \(tournament.gamePoints.rawValue)")
        print("Debug - Tournament Legs: \(tournament.legsToWin.rawValue)")
    }
    
    var body: some View {
        NavigationLink(destination: TournamentDetailView(tournamentManager: tournamentManager, tournament: tournament)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(tournament.name)
                            .font(.headline)
                            .foregroundColor(AppColors.text(for: colorScheme))
                        
                        Text("\(tournament.players.count) Spieler")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText(for: colorScheme))
                        
                        if let winner = tournament.winner {
                            Text("Gewinner: \(winner)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showingActionSheet = true }) {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppColors.text(for: colorScheme))
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground(for: colorScheme))
            .cornerRadius(10)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(tournament.name), buttons: [
                .default(Text("Turnier spielen")) {
                    if let nextMatch = tournament.matches.first(where: { !$0.isCompleted && !$0.isBye }) {
                        selectedMatch = nextMatch
                        showingGameView = true
                    }
                },
                .default(Text("Turnier neu starten")) {
                    tournamentManager.resetTournament(tournament)
                },
                .default(Text("Turnier bearbeiten")) {
                    showingEditSheet = true
                },
                .destructive(Text("Turnier löschen")) {
                    showingDeleteAlert = true
                },
                .cancel()
            ])
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Turnier löschen"),
                message: Text("Möchtest du dieses Turnier wirklich löschen?"),
                primaryButton: .destructive(Text("Löschen")) {
                    tournamentManager.deleteTournament(tournament)
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditTournamentView(tournamentManager: tournamentManager, tournament: tournament)
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
                    onMatchComplete: { [self] winner, score in
                        self.tournamentManager.completeMatch(
                            tournamentId: tournament.id,
                            matchId: match.id,
                            winner: winner,
                            score: score
                        )
                    }
                )
            }
        }
        .onAppear {
            tournamentManager.reloadTournaments()
        }
    }
}
