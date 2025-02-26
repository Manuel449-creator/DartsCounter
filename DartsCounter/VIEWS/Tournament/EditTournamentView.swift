//
//  EditTournamentView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 12.02.25.
//


// EditTournamentView.swift
struct EditTournamentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    
    @State private var tournamentName: String
    @State private var selectedPlayers: Set<UUID>
    
    init(tournamentManager: TournamentManager, tournament: Tournament) {
        self.tournamentManager = tournamentManager
        self.tournament = tournament
        _tournamentName = State(initialValue: tournament.name)
        _selectedPlayers = State(initialValue: Set(tournament.players.map { $0.id }))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    TextField("Turniername", text: $tournamentName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Teilnehmende Spieler")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(tournamentManager.playerManager.players) { player in
                                    TournamentPlayerRow(
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
                }
            }
            .navigationTitle("Turnier bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Abbrechen") { dismiss() },
                trailing: Button("Speichern") {
                    saveTournament()
                    dismiss()
                }
                .disabled(!isFormValid)
            )
        }
    }
    
    private var isFormValid: Bool {
        !tournamentName.isEmpty && selectedPlayers.count >= 2
    }
    
    private func saveTournament() {
        let selectedPlayersList = tournamentManager.playerManager.players.filter { selectedPlayers.contains($0.id) }
        tournamentManager.updateTournament(
            tournamentId: tournament.id,
            name: tournamentName,
            players: selectedPlayersList
        )
    }
}