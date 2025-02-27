import SwiftUI
import Foundation

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
    
    init(id: UUID = UUID(),
         name: String,
         players: [Player],
         matches: [TournamentMatch] = [],
         winner: String? = nil,
         isCompleted: Bool = false,
         gamePoints: GamePoints = .fiveOOne,
         legsToWin: LegsToWin = .three) {
        self.id = id
        self.name = name
        self.date = Date()
        self.players = players
        self.matches = matches
        self.winner = winner
        self.isCompleted = isCompleted
        self.gamePoints = gamePoints
        self.legsToWin = legsToWin
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
            currentStartNumber += size.requiredMatches / Int(pow(2.0, Double(roundStartNumbers.count)))
        }
        
        print("Debug - Round start numbers: \(roundStartNumbers)")
        
        // Fülle mit Freilosen auf, falls nötig
        while playerQueue.count < size.requiredMatches * 2 {
            playerQueue.append("BYE")
        }
        
        // Erstelle erste Runde
        let firstPhase = size.rounds.first!
        while playerQueue.count >= 2 {
            let player1 = playerQueue.removeFirst()
            let player2 = playerQueue.removeFirst()
            
            let nextRoundStart = roundStartNumbers[size.rounds[1]] ?? 0
            let nextMatchNumber = nextRoundStart + (matchNumber - 1) / 2
            
            print("Debug - Creating first round match: \(matchNumber) -> \(nextMatchNumber)")
            
            let isByeMatch = player2 == "BYE"
            let winner = isByeMatch ? player1 : nil
            
            let match = TournamentMatch(
                id: UUID(),
                player1: player1,
                player2: player2,
                winner: winner,  // Wenn BYE, dann ist player1 automatisch der Gewinner
                phase: firstPhase,
                matchNumber: matchNumber,
                nextMatchNumber: nextMatchNumber,
                isCompleted: isByeMatch,  // Match ist bereits abgeschlossen, wenn ein Freilos besteht
                isBye: isByeMatch,
                tournamentId: tournamentId
            )
            matches.append(match)
            matchNumber += 1
            
            // WICHTIG: Wenn ein BYE Match erstellt wurde, direkt den Gewinner in das nächste Match eintragen
            if isByeMatch {
                // Finde die nächste Phase
                let nextPhaseIndex = size.rounds.firstIndex(of: firstPhase).map { $0 + 1 }
                let nextPhase = nextPhaseIndex.flatMap { index -> TournamentPhase? in
                    return index < size.rounds.count ? size.rounds[index] : nil
                }
                
                // Finde/erstelle das nächste Match
                if let nextPhase = nextPhase {
                    let isFirstPositionFiller = match.matchNumber % 2 == 1
                    
                    // Dieses Match wird später erstellt, wir merken uns die Informationen
                    if isFirstPositionFiller {
                        // Wir müssen später player1 setzen
                        print("Debug - BYE: Need to set player1 of match \(nextMatchNumber) to \(player1)")
                    } else {
                        // Wir müssen später player2 setzen
                        print("Debug - BYE: Need to set player2 of match \(nextMatchNumber) to \(player1)")
                    }
                }
            }
        }
        
        // Erstelle restliche Runden
        for (index, phase) in size.rounds.dropFirst().enumerated() {
            let currentRoundStart = roundStartNumbers[phase] ?? 0
            let nextRoundStart = index + 1 < size.rounds.count - 1 ? roundStartNumbers[size.rounds[index + 2]] ?? 0 : 0
            let matchesInRound = size.requiredMatches / Int(pow(2.0, Double(index + 1)))
            
            print("Debug - Creating \(phase) round: start=\(currentRoundStart), next=\(nextRoundStart), count=\(matchesInRound)")
            
            for i in 0..<matchesInRound {
                let currentMatchNumber = currentRoundStart + i
                let nextMatchNumber = phase == .final ? nil : nextRoundStart + i / 2
                
                // Suche nach BYE-Matches, die zu diesem Match führen können
                let prevPhase = size.rounds[index]
                let prevMatches = matches.filter {
                    $0.phase == prevPhase &&
                    $0.nextMatchNumber == currentMatchNumber &&
                    $0.isBye
                }
                
                // Bestimme anfängliche Spieler basierend auf BYE-Matches
                var player1 = ""
                var player2 = ""
                
                for prevMatch in prevMatches {
                    if prevMatch.matchNumber % 2 == 1 {
                        player1 = prevMatch.player1
                    } else {
                        player2 = prevMatch.player1
                    }
                }
                
                let match = TournamentMatch(
                    id: UUID(),
                    player1: player1,
                    player2: player2,
                    phase: phase,
                    matchNumber: currentMatchNumber,
                    nextMatchNumber: nextMatchNumber,
                    isCompleted: false,
                    isBye: false,
                    tournamentId: tournamentId
                )
                matches.append(match)
            }
        }
        
        return matches
    }
}
