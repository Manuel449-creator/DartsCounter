//
//  TournamentManager.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 10.02.25.
//
import SwiftUI

class TournamentManager: ObservableObject {
    @Published var tournaments: [Tournament] = []
    @Published var selectedTournament: Tournament?
    let historyManager: MatchHistoryManager
    let playerManager: PlayerManager
    private let saveKey = "SavedTournaments"
    
    
    init(historyManager: MatchHistoryManager, playerManager: PlayerManager) {
        self.historyManager = historyManager
        self.playerManager = playerManager
        loadTournaments()
    }
    
    func addTournament(_ tournament: Tournament) {
        var newTournament = tournament
        newTournament.matches = Tournament.generateMatches(
            players: tournament.players,
            tournamentId: tournament.id
        )
        print("Debug - Adding Tournament with points: \(tournament.gamePoints.rawValue)")  // Neue Debug-Zeile
        tournaments.append(newTournament)
        saveTournaments()
    }
    
    func updateTournament(tournamentId: UUID, name: String, players: [Player]) {
        if let index = tournaments.firstIndex(where: { $0.id == tournamentId }) {
            var updatedTournament = tournaments[index]
            updatedTournament.name = name
            
            if Set(updatedTournament.players.map { $0.id }) != Set(players.map { $0.id }) {
                updatedTournament.players = players
                updatedTournament.matches = Tournament.generateMatches(
                    players: players,
                    tournamentId: tournamentId
                )
                updatedTournament.winner = nil
                updatedTournament.isCompleted = false
            }
            
            tournaments[index] = updatedTournament
            saveTournaments()
        }
    }

    struct TournamentPlayerRow: View {
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
    
    func completeMatch(tournamentId: UUID, matchId: UUID, winner: String, score: String) {
        print("Debug - Completing match. Tournament: \(tournamentId), Match: \(matchId), Winner: \(winner)")
        
        if let tournamentIndex = tournaments.firstIndex(where: { $0.id == tournamentId }) {
            if let matchIndex = tournaments[tournamentIndex].matches.firstIndex(where: { $0.id == matchId }) {
                let currentMatch = tournaments[tournamentIndex].matches[matchIndex]
                
                // Aktuelles Match aktualisieren
                tournaments[tournamentIndex].matches[matchIndex].winner = winner
                tournaments[tournamentIndex].matches[matchIndex].score = score
                tournaments[tournamentIndex].matches[matchIndex].isCompleted = true
                
                // NEU: Das Match auch zum MatchHistoryManager hinzufügen
                saveMatchToHistory(tournamentMatch: tournaments[tournamentIndex].matches[matchIndex], tournamentId: tournamentId)
                
                // Finde das nächste Match anhand der nextMatchNumber
                if let nextMatchNumber = currentMatch.nextMatchNumber {
                    print("Debug - Looking for next match number: \(nextMatchNumber)")
                    
                    // Suche explizit nach dem Match mit der richtigen Nummer UND der nächsten Phase
                    let nextPhaseIndex = TournamentSize.getSize(for: tournaments[tournamentIndex].players.count).rounds.firstIndex(of: currentMatch.phase)
                    let nextPhase = nextPhaseIndex.flatMap { idx -> TournamentPhase? in
                        let rounds = TournamentSize.getSize(for: tournaments[tournamentIndex].players.count).rounds
                        return idx + 1 < rounds.count ? rounds[idx + 1] : nil
                    }
                    
                    print("Debug - Current phase: \(currentMatch.phase), Next phase should be: \(String(describing: nextPhase))")
                    
                    // Suche das nächste Match anhand der Nummer UND Phase
                    if let nextPhase = nextPhase,
                       let nextMatchIndex = tournaments[tournamentIndex].matches.firstIndex(where: {
                           $0.matchNumber == nextMatchNumber && $0.phase == nextPhase
                       }) {
                        
                        print("Debug - Found next match at index: \(nextMatchIndex), phase: \(tournaments[tournamentIndex].matches[nextMatchIndex].phase)")
                        
                        var nextMatch = tournaments[tournamentIndex].matches[nextMatchIndex]
                        print("Debug - Next match before update: P1: \(nextMatch.player1), P2: \(nextMatch.player2)")
                        
                        // Position bestimmen
                        if currentMatch.matchNumber % 2 == 1 {
                            nextMatch.player1 = winner
                            print("Debug - Updated player1 to: \(winner) based on match number \(currentMatch.matchNumber)")
                        } else {
                            nextMatch.player2 = winner
                            print("Debug - Updated player2 to: \(winner) based on match number \(currentMatch.matchNumber)")
                        }
                        
                        // Automatische Vervollständigung für BYE
                        if nextMatch.player1 != "" && nextMatch.player2 == "BYE" {
                            // Automatisch vervollständigen, wenn gegen BYE
                            nextMatch.winner = nextMatch.player1
                            nextMatch.score = "2-0" // Standardergebnis
                            nextMatch.isCompleted = true
                            nextMatch.isBye = true
                            print("Debug - Auto-completing match against BYE. Winner: \(nextMatch.player1)")
                            
                            // Rekursiver Aufruf, um den Gewinner ins nächste Match zu befördern
                            tournaments[tournamentIndex].matches[nextMatchIndex] = nextMatch
                            saveTournaments()
                            
                            // Nach dem Speichern rekursiv aufrufen
                            completeMatch(
                                tournamentId: tournamentId,
                                matchId: nextMatch.id,
                                winner: nextMatch.player1,
                                score: nextMatch.score ?? "2-0"
                            )
                            return
                        } else if nextMatch.player2 != "" && nextMatch.player1 == "BYE" {
                            // Umgekehrter Fall
                            nextMatch.winner = nextMatch.player2
                            nextMatch.score = "0-2" // Standardergebnis
                            nextMatch.isCompleted = true
                            nextMatch.isBye = true
                            print("Debug - Auto-completing match against BYE. Winner: \(nextMatch.player2)")
                            
                            tournaments[tournamentIndex].matches[nextMatchIndex] = nextMatch
                            saveTournaments()
                            
                            completeMatch(
                                tournamentId: tournamentId,
                                matchId: nextMatch.id,
                                winner: nextMatch.player2,
                                score: nextMatch.score ?? "0-2"
                            )
                            return
                        }
                        
                        tournaments[tournamentIndex].matches[nextMatchIndex] = nextMatch
                        print("Debug - Next match after update: P1: \(nextMatch.player1), P2: \(nextMatch.player2)")
                    }
                }
                
                // Aktualisiere UI
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
                saveTournaments()
                
                // Neu laden um Konsistenz zu gewährleisten
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.loadTournaments()
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    private func saveMatchToHistory(tournamentMatch: TournamentMatch, tournamentId: UUID) {
        // Extrahiere das Ergebnis aus dem score-String (z.B. "2-0")
        let scoreComponents = tournamentMatch.score?.components(separatedBy: "-") ?? []
        let player1Sets = Int(scoreComponents.first ?? "0") ?? 0
        let player2Sets = Int(scoreComponents.last ?? "0") ?? 0
        
        // Erzeuge leere Legs (da wir die detaillierten Leg-Daten nicht haben)
        var legs: [Leg] = []
        
        // Erstelle für jeden Set ein Leg (vereinfachte Darstellung)
        for _ in 0..<max(player1Sets, player2Sets) {
            let legWinner = player1Sets > player2Sets ? tournamentMatch.player1 : tournamentMatch.player2
            let leg = Leg(
                id: UUID(),
                turns: [], // Keine detaillierten Daten verfügbar
                winner: legWinner,
                startingPlayer: tournamentMatch.player1 // Annahme: Player1 startet
            )
            legs.append(leg)
        }
        
        // Erstelle das Match für die Historie
        let historyMatch = Match(
            id: tournamentMatch.id, // Verwende die gleiche ID für Konsistenz
            date: Date(),
            player1: tournamentMatch.player1,
            player2: tournamentMatch.player2,
            gameMode: .fiveZeroOne, // Annahme: Standard-Spielmodus
            legs: legs,
            winner: tournamentMatch.winner,
            isCompleted: true,
            gameState: nil
        )
        
        // Speichere das Match in der Historie
        historyManager.saveMatch(historyMatch)
        
        // Aktualisiere auch die Spielerstatistiken
        playerManager.updatePlayerStats(playerName: tournamentMatch.player1, won: tournamentMatch.winner == tournamentMatch.player1)
        playerManager.updatePlayerStats(playerName: tournamentMatch.player2, won: tournamentMatch.winner == tournamentMatch.player2)
        
        // WICHTIG: Erzwinge UI-Updates für alle relevanten Observable Objects
        DispatchQueue.main.async {
            // Benachrichtige, dass sich die Daten geändert haben
            self.objectWillChange.send()
            self.historyManager.objectWillChange.send()
            self.playerManager.objectWillChange.send()
            
            // Lade die Daten explizit neu
            self.historyManager.reloadMatches()
            self.playerManager.loadPlayers()
        }
    }
    
    func getNextMatch(for match: TournamentMatch) -> TournamentMatch? {
        guard let nextMatchNumber = match.nextMatchNumber else { return nil }
        return tournaments
            .first(where: { $0.id == match.tournamentId })?
            .matches
            .first(where: { $0.matchNumber == nextMatchNumber })
    }
    
    func resetTournament(_ tournament: Tournament) {
        if let index = tournaments.firstIndex(where: { $0.id == tournament.id }) {
            var resetTournament = tournament
            resetTournament.matches = resetTournament.matches.map { match in
                var resetMatch = match
                if !match.isBye {
                    resetMatch.winner = nil
                    resetMatch.score = nil
                    resetMatch.isCompleted = false
                }
                return resetMatch
            }
            resetTournament.winner = nil
            resetTournament.isCompleted = false
            
            tournaments[index] = resetTournament
            selectedTournament = resetTournament
            saveTournaments()
        }
    }
    
    func deleteTournament(_ tournament: Tournament) {
        tournaments.removeAll { $0.id == tournament.id }
        saveTournaments()
    }
    
    func updateMatchPlayers(tournamentId: UUID, matchId: UUID, player1: String, player2: String) {
        if let tournamentIndex = tournaments.firstIndex(where: { $0.id == tournamentId }),
           let matchIndex = tournaments[tournamentIndex].matches.firstIndex(where: { $0.id == matchId }) {
            tournaments[tournamentIndex].matches[matchIndex].player1 = player1
            tournaments[tournamentIndex].matches[matchIndex].player2 = player2
            saveTournaments()
        }
    }
    
    func deleteMatch(tournamentId: UUID, matchId: UUID) {
        if let tournamentIndex = tournaments.firstIndex(where: { $0.id == tournamentId }) {
            tournaments[tournamentIndex].matches.removeAll { $0.id == matchId }
            saveTournaments()
        }
    }
    
    static func generateMatches(players: [Player], tournamentId: UUID) -> [TournamentMatch] {
        let size = TournamentSize.getSize(for: players.count)
        var matches: [TournamentMatch] = []
        var playerQueue = players.map { $0.name }
        
        // Fülle mit Freilosen auf, falls nötig
        while playerQueue.count < size.requiredMatches * 2 {
            playerQueue.append("BYE")
        }
        
        // Berechne die Match-Nummern für jede Phase
        var matchNumberCounter = 1
        var phaseMatchNumbers: [TournamentPhase: [Int]] = [:]
        
        // Erstelle für jede Phase die Match-Nummern
        for phase in size.rounds {
            let matchesInPhase = size.requiredMatches / Int(pow(2.0, Double(size.rounds.firstIndex(of: phase) ?? 0)))
            var numbers: [Int] = []
            
            for _ in 0..<matchesInPhase {
                numbers.append(matchNumberCounter)
                matchNumberCounter += 1
            }
            
            phaseMatchNumbers[phase] = numbers
        }
        
        print("Debug - Phase match numbers: \(phaseMatchNumbers)")
        
        // Erstelle Matches für jede Phase
        for phase in size.rounds {
            let matchNumbers = phaseMatchNumbers[phase] ?? []
            let nextPhaseIndex = size.rounds.firstIndex(of: phase).map { $0 + 1 }
            let nextPhase = nextPhaseIndex.flatMap { index -> TournamentPhase? in
                return index < size.rounds.count ? size.rounds[index] : nil
            }
            
            for (index, matchNumber) in matchNumbers.enumerated() {
                let nextMatchNumber: Int?
                
                if let nextPhase = nextPhase, let nextPhaseNumbers = phaseMatchNumbers[nextPhase] {
                    nextMatchNumber = nextPhaseNumbers[index / 2]
                } else {
                    nextMatchNumber = nil
                }
                
                if phase == size.rounds.first {
                    // Erste Runde mit Spielern füllen
                    if playerQueue.count >= 2 {
                        let player1 = playerQueue.removeFirst()
                        let player2 = playerQueue.removeFirst()
                        
                        let match = TournamentMatch(
                            id: UUID(),
                            player1: player1,
                            player2: player2,
                            phase: phase,
                            matchNumber: matchNumber,
                            nextMatchNumber: nextMatchNumber,
                            isCompleted: player2 == "BYE",
                            isBye: player2 == "BYE",
                            tournamentId: tournamentId
                        )
                        matches.append(match)
                        print("Debug - Created first round match: \(matchNumber) -> \(String(describing: nextMatchNumber))")
                    }
                } else {
                    // Folgende Runden erstellen
                    let match = TournamentMatch(
                        id: UUID(),
                        player1: "",
                        player2: "",
                        phase: phase,
                        matchNumber: matchNumber,
                        nextMatchNumber: nextMatchNumber,
                        isCompleted: false,
                        isBye: false,
                        tournamentId: tournamentId
                    )
                    matches.append(match)
                    print("Debug - Created \(phase) match: \(matchNumber) -> \(String(describing: nextMatchNumber))")
                }
            }
        }
        
        return matches
    }
    
    func exportTournamentData(_ tournament: Tournament) -> String {
        var export = "Turnier: \(tournament.name)\n"
        export += "Datum: \(formatDate(tournament.date))\n"
        export += "Spieler: \(tournament.players.map { $0.name }.joined(separator: ", "))\n\n"
        
        let matchesByPhase = Dictionary(grouping: tournament.matches) { $0.phase }
        
        for phase in TournamentPhase.allCases {
            if let matches = matchesByPhase[phase] {
                export += "\n\(phase.rawValue):\n"
                for match in matches {
                    if match.isBye {
                        export += "- \(match.player1) (Freilos)\n"
                    } else if match.isCompleted {
                        export += "- \(match.player1) vs \(match.player2) - Gewinner: \(match.winner ?? "N/A")"
                        if let score = match.score {
                            export += " (\(score))"
                        }
                        export += "\n"
                    } else {
                        export += "- \(match.player1) vs \(match.player2) - Ausstehend\n"
                    }
                }
            }
        }
        
        if let winner = tournament.winner {
            export += "\nTurniersieger: \(winner)"
        }
        
        return export
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func saveTournaments() {
        print("Debug - Saving tournaments")
        if let encoded = try? JSONEncoder().encode(tournaments) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("Debug - Tournaments saved successfully")
        } else {
            print("Debug - Failed to encode tournaments for saving")
        }
    }
    
    private func loadTournaments() {
        print("Debug - Loading tournaments")
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Tournament].self, from: data) {
            tournaments = decoded
            print("Debug - Loaded \(tournaments.count) tournaments")
            // Debug-Ausgabe für das gesuchte Turnier
            if let tournament = tournaments.first(where: { $0.id.uuidString == "4170C3D8-28B0-4415-B82E-120EA1A7E0A2" }) {
                for match in tournament.matches {
                    print("Debug - Loaded match: \(match.phase) - P1: \(match.player1), P2: \(match.player2)")
                }
            }
        } else {
            print("Debug - No tournaments found or failed to decode")
        }
    }
    
    func resetMatch(tournamentId: UUID, matchId: UUID) {
        if let tournamentIndex = tournaments.firstIndex(where: { $0.id == tournamentId }),
           let matchIndex = tournaments[tournamentIndex].matches.firstIndex(where: { $0.id == matchId }) {
            tournaments[tournamentIndex].matches[matchIndex].winner = nil
            tournaments[tournamentIndex].matches[matchIndex].score = nil
            tournaments[tournamentIndex].matches[matchIndex].isCompleted = false
            
            // Reset nachfolgende Matches wenn nötig
            resetSubsequentMatches(in: &tournaments[tournamentIndex], startingFrom: matchIndex)
            saveTournaments()
        }
    }

    private func resetSubsequentMatches(in tournament: inout Tournament, startingFrom matchIndex: Int) {
        let currentMatch = tournament.matches[matchIndex]
        if let nextMatchNumber = currentMatch.nextMatchNumber {
            if let nextMatchIndex = tournament.matches.firstIndex(where: { $0.matchNumber == nextMatchNumber }) {
                var nextMatch = tournament.matches[nextMatchIndex]
                // Reset nur den Spieler, der aus diesem Match kam
                if nextMatch.player1 == currentMatch.winner {
                    nextMatch.player1 = ""
                } else if nextMatch.player2 == currentMatch.winner {
                    nextMatch.player2 = ""
                }
                nextMatch.winner = nil
                nextMatch.score = nil
                nextMatch.isCompleted = false
                tournament.matches[nextMatchIndex] = nextMatch
                
                // Rekursiv für alle nachfolgenden Matches
                resetSubsequentMatches(in: &tournament, startingFrom: nextMatchIndex)
            }
        }
    }
}
    
    
