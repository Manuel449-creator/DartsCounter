import Foundation

class TournamentManager: ObservableObject {
    @Published var tournaments: [Tournament] = []
    private let saveKey = "SavedTournaments"
    
    init() {
        loadTournaments()
    }
    
    func addTournament(_ tournament: Tournament) {
        tournaments.append(tournament)
        saveTournaments()
    }
    
    func updateTournament(_ tournament: Tournament) {
        if let index = tournaments.firstIndex(where: { $0.id == tournament.id }) {
            tournaments[index] = tournament
            saveTournaments()
        }
    }
    
    func deleteTournament(id: UUID) {
        tournaments.removeAll { $0.id == id }
        saveTournaments()
    }
    
    private func saveTournaments() {
        if let encoded = try? JSONEncoder().encode(tournaments) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTournaments() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Tournament].self, from: data) {
            tournaments = decoded
        }
    }
}