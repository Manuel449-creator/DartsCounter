import SwiftUI
import Foundation

enum TournamentMode: String, Codable, CaseIterable {
    case sets = "Sets"
    case legs = "Legs"
}

struct Tournament: Codable, Identifiable {
    let id: UUID
    var name: String
    let date: Date
    var players: [Player]
    var matches: [TournamentMatch]
    var winner: String?
    var isCompleted: Bool
    var gamePoints: GamePoints
    var legsToWin: LegsToWin
    var tournamentMode: TournamentMode
    
    init(id: UUID = UUID(),
         name: String,
         players: [Player],
         matches: [TournamentMatch] = [],
         winner: String? = nil,
         isCompleted: Bool = false,
         gamePoints: GamePoints = .fiveOOne,
         legsToWin: LegsToWin = .three,
         tournamentMode: TournamentMode = .sets) {
        self.id = id
        self.name = name
        self.date = Date()
        self.players = players
        self.matches = matches
        self.winner = winner
        self.isCompleted = isCompleted
        self.gamePoints = gamePoints
        self.legsToWin = legsToWin
        self.tournamentMode = tournamentMode
    }
    
    mutating func updateMatch(matchId: UUID, winner: String, score: String) {
        if let matchIndex = matches.firstIndex(where: { $0.id == matchId }) {
            matches[matchIndex].winner = winner
            matches[matchIndex].score = score
            matches[matchIndex].isCompleted = true
            checkTournamentCompletion()
        }
    }
    
    private mutating func checkTournamentCompletion() {
        if let finalMatch = matches.first(where: { $0.phase == .final && $0.isCompleted }) {
            self.winner = finalMatch.winner
            self.isCompleted = true
            createThirdPlaceMatch()
        }
    }
    
    private mutating func createThirdPlaceMatch() {
        let semiFinalsLosers = matches
            .filter { $0.phase == .semiFinal && $0.isCompleted }
            .compactMap { match -> String? in
                if match.winner == match.player1 {
                    return match.player2
                } else {
                    return match.player1
                }
            }
        
        if semiFinalsLosers.count == 2 && !matches.contains(where: { $0.phase == .thirdPlace }) {
            let thirdPlaceMatch = TournamentMatch(
                id: UUID(),
                player1: semiFinalsLosers[0],
                player2: semiFinalsLosers[1],
                phase: .thirdPlace,
                matchNumber: matches.count,
                nextMatchNumber: nil,
                isCompleted: false,
                isBye: false,
                tournamentId: id
            )
            matches.append(thirdPlaceMatch)
        }
    }
}



extension Tournament {
    static func generateMatches(players: [Player], tournamentId: UUID) -> [TournamentMatch] {
        let size = TournamentSize.getSize(for: players.count)
        var matches: [TournamentMatch] = []
        var matchNumber = 1
        var playerQueue = players.map { $0.name }
        
        // Berechne die Startposition für jede Runde
        var roundStartNumbers: [TournamentPhase: Int] = [:]
        var currentStartNumber = 1
        
        for phase in size.rounds {
            roundStartNumbers[phase] = currentStartNumber
            let matchesInPhase = size.requiredMatches / Int(pow(2.0, Double(size.rounds.firstIndex(of: phase) ?? 0)))
            currentStartNumber += matchesInPhase
        }
        
        print("Debug - Round start numbers: \(roundStartNumbers)")
        
        // Fülle mit Freilosen auf, falls nötig
        while playerQueue.count < size.requiredMatches * 2 {
            playerQueue.append("BYE")
        }
        
        // Erstelle erste Runde
        if let firstPhase = size.rounds.first {
            while playerQueue.count >= 2 {
                let player1 = playerQueue.removeFirst()
                let player2 = playerQueue.removeFirst()
                
                // Sicherheitscheck für den Index
                let nextPhaseIndex = size.rounds.firstIndex(of: firstPhase).map { $0 + 1 }
                
                let nextMatchNumber: Int?
                if let nextIndex = nextPhaseIndex, nextIndex < size.rounds.count {
                    let nextPhase = size.rounds[nextIndex]
                    let nextStart = roundStartNumbers[nextPhase] ?? 0
                    nextMatchNumber = nextStart + (matchNumber - 1) / 2
                } else {
                    nextMatchNumber = nil
                }
                
                print("Debug - Creating first round match: \(matchNumber) -> \(String(describing: nextMatchNumber))")
                
                // Prüfen, ob es ein Freilos ist
                let isBye = player1 == "BYE" || player2 == "BYE"
                let winner: String?
                if isBye {
                    // Wenn einer der Spieler ein Freilos hat, gewinnt der andere automatisch
                    winner = player1 == "BYE" ? player2 : player1
                } else {
                    winner = nil
                }
                
                let match = TournamentMatch(
                    id: UUID(),
                    player1: player1,
                    player2: player2,
                    phase: firstPhase,        // Diese Reihenfolge ist korrekt
                    matchNumber: matchNumber,
                    nextMatchNumber: nextMatchNumber,
                    isCompleted: isBye,
                    isBye: isBye,
                    tournamentId: tournamentId,
                    winner: winner,           // Diese Parameter sind
                    score: isBye ? "w.o." : nil  // in der richtigen Reihenfolge
                )
                matches.append(match)
                matchNumber += 1
            }
        }
        
        // Erstelle restliche Runden
        for (index, phase) in size.rounds.dropFirst().enumerated() {
            let currentRoundStart = roundStartNumbers[phase] ?? 0
            
            // Sichere Berechnung des nächsten RoundStart
            let nextRoundStart: Int
            if index + 1 < size.rounds.count - 1 {
                let nextPhase = size.rounds[index + 2]
                nextRoundStart = roundStartNumbers[nextPhase] ?? 0
            } else {
                nextRoundStart = 0
            }
            
            let matchesInRound = size.requiredMatches / Int(pow(2.0, Double(index + 1)))
            
            print("Debug - Creating \(phase) round: start=\(currentRoundStart), next=\(nextRoundStart), count=\(matchesInRound)")
            
            for i in 0..<matchesInRound {
                let currentMatchNumber = currentRoundStart + i
                let nextMatchNumber = phase == .final ? nil : nextRoundStart + i / 2
                
                let match = TournamentMatch(
                    id: UUID(),
                    player1: "",
                    player2: "",
                    phase: phase,             // Diese Reihenfolge ist korrekt
                    matchNumber: currentMatchNumber,
                    nextMatchNumber: nextMatchNumber,
                    isCompleted: false,
                    isBye: false,
                    tournamentId: tournamentId,
                    winner: nil,              // Diese Parameter sind
                    score: nil                // in der richtigen Reihenfolge
                )
                matches.append(match)
            }
        }
        
        return matches
    }
}
