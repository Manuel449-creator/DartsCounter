import Foundation

// Punktzahl und Legs Definitionen
enum GamePoints: Int, Codable, CaseIterable {
    case oneOOne = 101
    case twoOOne = 201
    case threeOOne = 301
    case fourOOne = 401
    case fiveOOne = 501
    
    var description: String {
        return "\(self.rawValue)"
    }
}

enum LegsToWin: Int, Codable, CaseIterable {
    case three = 3
    case five = 5
    case seven = 7
    
    var description: String {
        return "Best of \(self.rawValue)"
    }
}

// Game Modes and Types
enum GameMode: String, Codable, CaseIterable {
    case fiveZeroOne = "501"
    case cricket = "Cricket"
    case training = "Training"
}

enum OpponentType: String, Codable, CaseIterable {
    case human = "Mensch"
    case bot = "Bot"
}

enum BotDifficulty: String, Codable, CaseIterable {
    case easy = "Einfach"
    case medium = "Mittel"
    case hard = "Schwer"
    
    var average: Double {
        switch self {
        case .easy: return 40.0
        case .medium: return 60.0
        case .hard: return 80.0
        }
    }
}

struct Turn: Codable, Equatable {
    let score: Int
    let dartsThrown: Int
    let isPlayer1: Bool
}

struct Leg: Codable, Identifiable {
    let id: UUID
    let turns: [Turn]
    let winner: String
    let startingPlayer: String
}

struct SavedGameState: Codable {
    let currentSet: Int
    let player1Sets: Int
    let player2Sets: Int
    let currentLeg: Int
    let player1Legs: Int
    let player2Legs: Int
    let isPlayer1Starting: Bool
    let playerScore: Int
    let opponentScore: Int
    let playerLastScore: String
    let opponentLastScore: String
    let playerDartsThrown: Int
    let opponentDartsThrown: Int
    let isPlayerTurn: Bool
    let turnHistory: [Turn]
    let numberOfSets: Int
}

struct SetConfiguration {
    static let options = ["Best of 3", "Best of 5", "Best of 7"]
}

// Entfernen Sie die Match-Definition hier, wenn sie bereits woanders definiert ist
