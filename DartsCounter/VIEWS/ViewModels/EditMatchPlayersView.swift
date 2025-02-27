//
//  EditMatchPlayersView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 19.02.25.
//
import SwiftUI

struct EditMatchPlayersView: View {
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
                Section(header: Text("Spieler")) {
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
