//
//  TournamentMatch.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 11.02.25.
//
import SwiftUI

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
    var isBye: Bool
    var tournamentId: UUID
    
    // Implementiere displayPhase als computed property innerhalb der Struktur
    var displayPhase: TournamentPhase {
        return phase
    }
    
    init(id: UUID = UUID(),
             player1: String,
             player2: String,
             phase: TournamentPhase,
             matchNumber: Int,
             nextMatchNumber: Int?,
             isCompleted: Bool,
             isBye: Bool,
             tournamentId: UUID,
             winner: String? = nil,
             score: String? = nil) {
            self.id = id
            self.player1 = player1
            self.player2 = player2
            self.phase = phase
            self.matchNumber = matchNumber
            self.nextMatchNumber = nextMatchNumber
            self.isCompleted = isCompleted
            self.isBye = isBye
            self.tournamentId = tournamentId
            self.winner = winner
            self.score = score
        }

   }

    extension TournamentMatch: Equatable {
        static func == (lhs: TournamentMatch, rhs: TournamentMatch) -> Bool {
            return lhs.id == rhs.id &&
            lhs.player1 == rhs.player1 &&
            lhs.player2 == rhs.player2 &&
            lhs.winner == rhs.winner &&
            lhs.isCompleted == rhs.isCompleted
        }
    }
    
    enum TournamentPhase: String, Codable, CaseIterable {
        case round256 = "Runde der 256"
        case round128 = "Runde der 128"
        case round64 = "Runde der 64"
        case round32 = "Runde der 32"
        case firstRound = "1. Spieltag"
        case quarterFinal = "Viertelfinale"
        case semiFinal = "Halbfinale"
        case final = "Finale"
        case thirdPlace = "Spiel um Platz 3"
    }
    
    enum TournamentSize {
        case two, four, eight, sixteen, thirtyTwo, sixtyFour, oneHundredTwentyEight, twoHundredFiftySix
        
        static func getSize(for playerCount: Int) -> TournamentSize {
            if playerCount <= 2 { return .two }
            if playerCount <= 4 { return .four }
            if playerCount <= 8 { return .eight }
            if playerCount <= 16 { return .sixteen }
            if playerCount <= 32 { return .thirtyTwo }
            if playerCount <= 64 { return .sixtyFour }
            if playerCount <= 128 { return .oneHundredTwentyEight }
            return .twoHundredFiftySix
        }
        
        var requiredMatches: Int {
            switch self {
            case .two: return 1
            case .four: return 2
            case .eight: return 4
            case .sixteen: return 8
            case .thirtyTwo: return 16
            case .sixtyFour: return 32
            case .oneHundredTwentyEight: return 64
            case .twoHundredFiftySix: return 128
            }
        }
        
        var rounds: [TournamentPhase] {
            switch self {
            case .two:
                return [.final]
            case .four:
                return [.semiFinal, .final]
            case .eight:
                return [.quarterFinal, .semiFinal, .final]
            case .sixteen:
                return [.firstRound, .quarterFinal, .semiFinal, .final]
            case .thirtyTwo:
                return [.round32, .firstRound, .quarterFinal, .semiFinal, .final]
            case .sixtyFour:
                return [.round64, .round32, .firstRound, .quarterFinal, .semiFinal, .final]
            case .oneHundredTwentyEight:
                return [.round128, .round64, .round32, .firstRound, .quarterFinal, .semiFinal, .final]
            case .twoHundredFiftySix:
                return [.round256, .round128, .round64, .round32, .firstRound, .quarterFinal, .semiFinal, .final]
            }
        }
    }
