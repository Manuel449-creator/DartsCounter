import SwiftUI

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var playerScore: Int
    @Published var opponentScore: Int
    private let startingScore: Int
    @Published var inputScore = ""
    @Published var playerLastScore = "-"
    @Published var opponentLastScore = "-"
    @Published var playerDartsThrown = 0
    @Published var opponentDartsThrown = 0
    @Published var isPlayerTurn = true
    @Published var shouldShowGameEndAlert = false
    
    // Neue Variablen für die Gesamtwerte
    private var totalPlayerPointsScored = 0
    private var totalOpponentPointsScored = 0
    
    private var turnHistory: [Turn] = []
    private var legs: [Leg] = []
    let homeName: String
    let onMatchComplete: ((String, String) -> Void)?
    private let guestName: String
    private let opponentType: OpponentType
    private let botDifficulty: BotDifficulty
    private let numberOfSets: Int
    
    // Getter für die Punkteberechnung
    var playerTotalPoints: Int {
        let currentLegPoints = startingScore - playerScore
        return totalPlayerPointsScored + currentLegPoints
    }
    
    var opponentTotalPoints: Int {
        let currentLegPoints = startingScore - opponentScore
        return totalOpponentPointsScored + currentLegPoints
    }
    
    // Getter für den Startwert
    var startingScoreValue: Int {
        return startingScore
    }
    
    // Behalten Sie Ihre bestehenden Computed Properties
    var player1Legs: Int { gameState.player1Legs }
    var player2Legs: Int { gameState.player2Legs }
    var player1Sets: Int { gameState.player1Sets }
    var player2Sets: Int { gameState.player2Sets }
    var isPlayer1Starting: Bool { gameState.isPlayer1Starting }
    
    var opponentName: String {
        // Bestehende Implementierung
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
         numberOfSets: Int,
         startingScore: Int = 501,
         onMatchComplete: ((String, String) -> Void)? = nil) {
        
        self.onMatchComplete = onMatchComplete
        self.homeName = homeName
        self.guestName = guestName
        self.opponentType = opponentType
        self.botDifficulty = botDifficulty
        self.numberOfSets = numberOfSets
        self.startingScore = startingScore
        self.playerScore = startingScore
        self.opponentScore = startingScore
        
        if let savedState = savedGameState {
            self.gameState = GameState(player1Name: homeName, player2Name: guestName)
            loadSavedGame(savedState)
        } else {
            self.gameState = GameState(player1Name: homeName, player2Name: guestName)
        }
        
        // Übernehme den Startwert aus gameState
        self.isPlayerTurn = self.gameState.isPlayer1Starting
    }
    
    private func loadSavedGame(_ savedState: SavedGameState) {
        gameState.currentSet = savedState.currentSet
        gameState.player1Sets = savedState.player1Sets
        gameState.player2Sets = savedState.player2Sets
        gameState.currentLeg = savedState.currentLeg
        gameState.player1Legs = savedState.player1Legs
        gameState.player2Legs = savedState.player2Legs
        gameState.isPlayer1Starting = savedState.isPlayer1Starting
        playerScore = savedState.playerScore
        opponentScore = savedState.opponentScore
        playerLastScore = savedState.playerLastScore
        opponentLastScore = savedState.opponentLastScore
        playerDartsThrown = savedState.playerDartsThrown
        opponentDartsThrown = savedState.opponentDartsThrown
        isPlayerTurn = savedState.isPlayerTurn
        turnHistory = savedState.turnHistory
    }
    
    // Angepasste resetForNewLeg-Methode
    private func resetForNewLeg() {
        // Vor dem Zurücksetzen die Punkte des aktuellen Legs speichern
        totalPlayerPointsScored += (startingScore - playerScore)
        totalOpponentPointsScored += (startingScore - opponentScore)
        
        // Dann für das neue Leg zurücksetzen
        playerScore = startingScore
        opponentScore = startingScore
        turnHistory = []
        playerLastScore = "-"
        opponentLastScore = "-"
        
        isPlayerTurn = gameState.isPlayer1Starting
    }
    
    // Diese Methoden zum GameViewModel hinzufügen
    func undoLastTurn() {
        guard let lastTurn = turnHistory.last else { return }
        
        if lastTurn.isPlayer1 {
            playerScore += lastTurn.score
            playerDartsThrown -= lastTurn.dartsThrown
            playerLastScore = turnHistory.count >= 2 ? "\(turnHistory[turnHistory.count - 2].score)" : "-"
        } else {
            opponentScore += lastTurn.score
            opponentDartsThrown -= lastTurn.dartsThrown
            opponentLastScore = turnHistory.count >= 2 ? "\(turnHistory[turnHistory.count - 2].score)" : "-"
        }
        
        turnHistory.removeLast()
        isPlayerTurn = lastTurn.isPlayer1
    }

    func submitScore(_ points: Int) {
        print("submitScore called with \(points) points")
        guard isValidDartScore(points) else { return }
        
        let isLegWin: Bool
        if isPlayerTurn {
            let turn = Turn(score: points, dartsThrown: 3, isPlayer1: true)
            turnHistory.append(turn)
            playerLastScore = "\(points)"
            playerDartsThrown += 3
            
            if points <= playerScore {
                playerScore -= points
                isLegWin = playerScore == 0
            } else {
                isLegWin = false
            }
        } else {
            let turn = Turn(score: points, dartsThrown: 3, isPlayer1: false)
            turnHistory.append(turn)
            opponentLastScore = "\(points)"
            opponentDartsThrown += 3
            
            if points <= opponentScore {
                opponentScore -= points
                isLegWin = opponentScore == 0
            } else {
                isLegWin = false
            }
        }
        
        inputScore = ""
        
        if isLegWin {
            // Wenn Leg gewonnen wurde
            checkForLegWin()
        } else {
            // Normaler Spielerwechsel während des Legs
            isPlayerTurn.toggle()
            
            if !isPlayerTurn && opponentType == .bot {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.simulateBotTurn()
                }
            }
        }
    }

    func resetInput() {
        inputScore = ""
    }

    private func isValidDartScore(_ score: Int) -> Bool {
        if score > 180 { return false }
        
        let impossibleScores = [
            179, 178, 176, 175, 173, 172, 169, 166, 163
        ]
        
        return !impossibleScores.contains(score)
    }

    func simulateBotTurn() {
        let botScore = Int.random(in: 0...Int(botDifficulty.average))
        let actualScore = min(botScore, opponentScore)
        
        let turn = Turn(score: actualScore, dartsThrown: 3, isPlayer1: false)
        turnHistory.append(turn)
        
        opponentScore -= actualScore
        opponentLastScore = "\(actualScore)"
        opponentDartsThrown += 3
        
        checkForLegWin()
        if !shouldShowGameEndAlert {
            isPlayerTurn = true
        }
    }

    private func checkForLegWin() {
        if playerScore == 0 || opponentScore == 0 {
            let isPlayer1Win = playerScore == 0
            
            // Setze die GameState Werte vor dem resetForNewLeg
            gameState.handleLegWin(wonByPlayer1: isPlayer1Win)
            
            let legWinner = isPlayer1Win ? homeName : opponentName
            legs.append(Leg(
                id: UUID(),
                turns: turnHistory,
                winner: legWinner,
                startingPlayer: gameState.isPlayer1Starting ? homeName : opponentName
            ))
                        
            if gameState.player1Sets > numberOfSets / 2 || gameState.player2Sets > numberOfSets / 2 {
                shouldShowGameEndAlert = true
                onMatchComplete?(legWinner, "\(gameState.player1Sets)-\(gameState.player2Sets)")
            } else {
                resetForNewLeg()
            }
        }
    }
    
    // Zu GameViewModel hinzufügen:

    func onAppear() {
        if turnHistory.isEmpty {
            isPlayerTurn = gameState.isPlayer1Starting
        }
    }

    func saveUnfinishedMatch(matchId: UUID?, historyManager: MatchHistoryManager) {
        let savedState = SavedGameState(
            currentSet: gameState.currentSet,
            player1Sets: gameState.player1Sets,
            player2Sets: gameState.player2Sets,
            currentLeg: gameState.currentLeg,
            player1Legs: gameState.player1Legs,
            player2Legs: gameState.player2Legs,
            isPlayer1Starting: gameState.isPlayer1Starting,
            playerScore: playerScore,
            opponentScore: opponentScore,
            playerLastScore: playerLastScore,
            opponentLastScore: opponentLastScore,
            playerDartsThrown: playerDartsThrown,
            opponentDartsThrown: opponentDartsThrown,
            isPlayerTurn: isPlayerTurn,
            turnHistory: turnHistory,
            numberOfSets: numberOfSets
        )
        
        let match = Match(
            id: matchId ?? UUID(),
            date: Date(),
            player1: homeName,
            player2: opponentName,
            gameMode: .fiveZeroOne,
            legs: legs,
            winner: nil,
            isCompleted: false,
            gameState: savedState
        )
            
        if matchId != nil {
            historyManager.updateMatch(match)
        } else {
            historyManager.saveMatch(match)
        }
    }

    func saveCompletedMatch(matchId: UUID?, historyManager: MatchHistoryManager, playerManager: PlayerManager) {
        let match = Match(
            id: matchId ?? UUID(),
            date: Date(),
            player1: homeName,
            player2: opponentName,
            gameMode: .fiveZeroOne,
            legs: legs,
            winner: gameState.player1Sets > gameState.player2Sets ? homeName : opponentName,
            isCompleted: true,
            gameState: nil
        )
        
        if matchId != nil {
            historyManager.updateMatch(match)
        } else {
            historyManager.saveMatch(match)
        }
        
        playerManager.updatePlayerStats(playerName: homeName, won: gameState.player1Sets > gameState.player2Sets)
        if opponentType == .human {
            playerManager.updatePlayerStats(playerName: guestName, won: gameState.player2Sets > gameState.player1Sets)
        }
    }
}

