//
//  PlayerSelectionSheet.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 31.01.25.
//
import SwiftUI

struct PlayerSelectionSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var playerManager: PlayerManager
    @ObservedObject var historyManager: MatchHistoryManager
    @Binding var selectedPlayerName: String
    let excludePlayerName: String
    @State private var showingDeleteAlert = false
    @State private var playerToDelete: Player?
    @State private var showingAddPlayer = false
    
    var availablePlayers: [Player] {
        playerManager.players.filter { $0.name != excludePlayerName }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
                
                VStack {
                    List {
                        ForEach(availablePlayers) { player in
                            HStack {
                                // Spieler-Auswahl-Bereich
                                Button(action: {
                                    selectedPlayerName = player.name
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(AppColors.secondaryText(for: colorScheme))
                                        Text(player.name)
                                            .foregroundColor(AppColors.text(for: colorScheme))
                                        Spacer()
                                    }
                                }
                                
                                // Löschen-Button
                                Button(action: {
                                    playerToDelete = player
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .listRowBackground(AppColors.cardBackground(for: colorScheme))
                        }
                        .onDelete { _ in }
                    }
                    .listStyle(PlainListStyle())
                    
                    Button(action: {
                        showingAddPlayer = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Neuen Spieler hinzufügen")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Spieler auswählen")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerSheet(
                    playerManager: playerManager,
                    selectedPlayerName: $selectedPlayerName
                )
            }
            .alert("Spieler löschen", isPresented: $showingDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    if let player = playerToDelete {
                        historyManager.deleteMatchesForPlayer(name: player.name)
                        playerManager.deletePlayer(id: player.id)
                    }
                }
            } message: {
                Text("Möchtest du diesen Spieler wirklich löschen? Alle zugehörigen Spiele werden ebenfalls gelöscht.")
            }
        }
    }
}

// Separate View für die Spielerauswahl
struct PlayerSelectionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let player: Player
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(AppColors.secondaryText(for: colorScheme))
                Text(player.name)
                    .foregroundColor(AppColors.text(for: colorScheme))
            }
        }
    }
}

// Separate View für den Löschbutton
struct DeleteButton: View {
    let player: Player
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onDelete) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
