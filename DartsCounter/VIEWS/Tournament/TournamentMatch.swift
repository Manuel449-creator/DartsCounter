//
//  TournamentMatch.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 11.02.25.
//


struct TournamentMatch: Codable, Identifiable {
    let id: UUID
    var player1: String
    var player2: String
    var winner: String?
    var score: String?
    var phase: TournamentPhase
    var matchNumber: Int
    var nextMatchNumber: Int?
    var isCompleted: Bool
}

enum TournamentPhase: String, Codable {
    case firstRound = "1. Spieltag"
    case quarterFinal = "Viertelfinale"
    case semiFinal = "Halbfinale"
    case final = "Finale"
    case thirdPlace = "Spiel um Platz 3"
}

struct Tournament: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let players: [Player]
    var matches: [TournamentMatch]
    var winner: String?
    var isCompleted: Bool
    
    // Hilfsfunktion zum automatischen Erstellen des Turnierbaums
    mutating func createBracket() {
        matches = []
        let shuffledPlayers = players.shuffled()
        
        // Erste Runde erstellen
        for i in stride(from: 0, to: players.count, by: 2) {
            if i + 1 < players.count {
                let match = TournamentMatch(
                    id: UUID(),
                    player1: shuffledPlayers[i].name,
                    player2: shuffledPlayers[i + 1].name,
                    phase: .firstRound,
                    matchNumber: i/2,
                    nextMatchNumber: i/4,
                    isCompleted: false
                )
                matches.append(match)
            }
        }
        
        // Weitere Runden erstellen
        createNextRounds()
    }
    
    private mutating func createNextRounds() {
        // Implementation für weitere Runden
    }
}