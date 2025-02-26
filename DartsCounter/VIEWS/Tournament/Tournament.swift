import Foundation

struct Tournament: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let players: [Player]
    var matches: [TournamentMatch] // Hier TournamentMatch statt Match
    var winner: String?
    var isCompleted: Bool
    
    init(id: UUID = UUID(), name: String, players: [Player], matches: [TournamentMatch] = [], winner: String? = nil, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.date = Date()
        self.players = players
        self.matches = matches
        self.winner = winner
        self.isCompleted = isCompleted
    }
}