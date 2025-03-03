//
//  EditMatchPlayersView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 19.02.25.
//
import SwiftUI

struct EditMatchPlayersView: View {
    @Environment(\.colorScheme) private var colorScheme
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
            ZStack {
                AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Spieler").foregroundColor(AppColors.text(for: colorScheme))) {
                        Picker("Spieler 1", selection: $player1) {
                            ForEach(tournament.players) { player in
                                Text(player.name).tag(player.name)
                                    .foregroundColor(AppColors.text(for: colorScheme))
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        
                        Picker("Spieler 2", selection: $player2) {
                            ForEach(tournament.players) { player in
                                Text(player.name).tag(player.name)
                                    .foregroundColor(AppColors.text(for: colorScheme))
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                    }
                    .listRowBackground(AppColors.cardBackground(for: colorScheme))
                }
                .scrollContentBackground(.hidden)
                .background(AppColors.background(for: colorScheme))
            }
            .navigationTitle("Spieler bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(AppColors.text(for: colorScheme))
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
