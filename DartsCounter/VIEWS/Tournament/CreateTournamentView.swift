import SwiftUI

struct CreateTournamentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tournamentManager: TournamentManager
    @ObservedObject var playerManager: PlayerManager = PlayerManager()
    
    @State private var tournamentName = ""
    @State private var selectedPlayers: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Turniername
                    TextField("Turniername", text: $tournamentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    // Spielerauswahl
                    VStack(alignment: .leading) {
                        Text("Spieler auswählen")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(playerManager.players) { player in
                                    PlayerSelectionRow(
                                        player: player,
                                        isSelected: selectedPlayers.contains(player.id),
                                        onTap: {
                                            if selectedPlayers.contains(player.id) {
                                                selectedPlayers.remove(player.id)
                                            } else {
                                                selectedPlayers.insert(player.id)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Turnier erstellen Button
                    Button(action: createTournament) {
                        Text("Turnier erstellen")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .padding()
                }
            }
            .navigationTitle("Neues Turnier")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
    
    private var isFormValid: Bool {
        !tournamentName.isEmpty && selectedPlayers.count >= 2
    }
    
    private func createTournament() {
        let selectedPlayersList = playerManager.players.filter { selectedPlayers.contains($0.id) }
        let tournament = Tournament(
            name: tournamentName,
            players: selectedPlayersList
        )
        tournamentManager.addTournament(tournament)
        dismiss()
    }
}

struct PlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(player.name)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(10)
        }
    }
}