import Foundation

// Game State
struct GameState {
    var currentSet: Int = 1
    var player1Sets: Int = 0
    var player2Sets: Int = 0
    var currentLeg: Int = 1
    var player1Legs: Int = 0
    var player2Legs: Int = 0
    var isPlayer1Starting: Bool = true
    
    mutating func determineNextLegStarter() {
        isPlayer1Starting.toggle()
    }
    
    mutating func handleLegWin(wonByPlayer1: Bool) {
        if wonByPlayer1 {
            player1Legs += 1
        } else {
            player2Legs += 1
        }
        
        if player1Legs == 3 || player2Legs == 3 {
            if player1Legs > player2Legs {
                player1Sets += 1
            } else {
                player2Sets += 1
            }
            player1Legs = 0
            player2Legs = 0
            currentSet += 1
        }
        
        currentLeg += 1
        determineNextLegStarter()
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

// Game Data Structures
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