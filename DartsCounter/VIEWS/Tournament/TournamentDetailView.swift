import SwiftUI

struct TournamentDetailView: View {
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingExportSheet = false
    @State private var exportText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header basierend auf Turnierstatus
            if tournament.isCompleted {
                CompletedTournamentHeader(tournament: tournament)
            } else {
                ActiveTournamentHeader(tournament: tournament)
            }
            
            // Turnierbaum
            ScrollView([.horizontal, .vertical]) {
                TournamentBracketView(
                    tournamentManager: tournamentManager,
                    tournament: tournament
                )
            }
        }
        .navigationTitle(tournament.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Export Funktionalität kommt später
                    }) {
                        Label("Exportieren", systemImage: "square.and.arrow.up")
                    }
                    
                    if !tournament.isCompleted {
                        Button(action: {
                            showingAlert = true
                            alertMessage = "Möchten Sie das Turnier wirklich zurücksetzen?"
                        }) {
                            Label("Turnier zurücksetzen", systemImage: "arrow.counterclockwise")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Zurücksetzen", role: .destructive) {
                resetTournament()
            }
        }
    }
    
    private func resetTournament() {
        tournamentManager.resetTournament(tournament)
    }
}
