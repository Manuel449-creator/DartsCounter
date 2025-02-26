//
//  GameViewModel.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 06.02.25.
//


class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    @Published var playerScore = 501
    @Published var opponentScore = 501
    @Published var inputScore = ""
    @Published var playerLastScore = "-"
    @Published var opponentLastScore = "-"
    @Published var playerDartsThrown = 0
    @Published var opponentDartsThrown = 0
    @Published var isPlayerTurn = true
    @Published var shouldShowGameEndAlert = false
    
    private var turnHistory: [Turn] = []
    private var legs: [Leg] = []
    let homeName: String // Changed from private to internal access
    private let guestName: String
    private let opponentType: OpponentType
    private let botDifficulty: BotDifficulty
    private let numberOfSets: Int
    
    var opponentName: String {
        switch opponentType {
        case .human:
            return guestName.isEmpty ? "Gast" : guestName
        case .bot:
            return "Dartbot (\(Int(botDifficulty.average)) Avg)"
        }
    }
    
    var gameStatusText: String {
        "SET \(gameState.currentSet) - LEG \(gameState.currentLeg)"
    }
    
    init(savedGameState: SavedGameState?, 
         homeName: String, 
         guestName: String, 
         opponentType: OpponentType, 
         botDifficulty: BotDifficulty,
         numberOfSets: Int) {
        self.homeName = homeName
        self.guestName = guestName
        self.opponentType = opponentType
        self.botDifficulty = botDifficulty
        self.numberOfSets = numberOfSets
        
        if let savedState = savedGameState {
            loadSavedGame(savedState)
        }
    }
    
    // ... Rest des GameViewModel-Codes bleibt unverändert ...
}