//
//  GameView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 31.01.25.
//
import SwiftUI

struct GameView: View {
    var gameMode: GameMode
    var opponentType: OpponentType
    var botDifficulty: BotDifficulty
    var tournamentMatch: TournamentMatch?
    var tournamentId: UUID?
    var onMatchComplete: ((String, String) -> Void)?
    let guestName: String
    let homeName: String
    let historyManager: MatchHistoryManager
    let playerManager: PlayerManager
    let numberOfSets: Int
    let savedGameState: SavedGameState?
    let matchId: UUID?
    let startingScore: Int
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: GameViewModel
    @State private var showGameEndAlert = false
    @State private var showImpossibleScoreAlert = false
    @State private var showQuitAlert = false
    
    init(gameMode: GameMode,
           opponentType: OpponentType,
           botDifficulty: BotDifficulty,
           guestName: String,
           homeName: String,
           historyManager: MatchHistoryManager,
           playerManager: PlayerManager,
           numberOfSets: Int,
           startingScore: Int,
           savedGameState: SavedGameState? = nil,
           matchId: UUID? = nil,
           onMatchComplete: ((String, String) -> Void)? = nil) {
          
          self.gameMode = gameMode
          self.opponentType = opponentType
          self.botDifficulty = botDifficulty
          self.guestName = guestName
          self.homeName = homeName
          self.historyManager = historyManager
          self.playerManager = playerManager
          self.numberOfSets = numberOfSets
          self.startingScore = startingScore
          self.savedGameState = savedGameState
          self.matchId = matchId
          self.onMatchComplete = onMatchComplete
          
          _viewModel = StateObject(wrappedValue: GameViewModel(
              savedGameState: savedGameState,
              homeName: homeName,
              guestName: guestName,
              opponentType: opponentType,
              botDifficulty: botDifficulty,
              numberOfSets: numberOfSets,
              startingScore: startingScore,
              onMatchComplete: onMatchComplete
          ))
      }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                GameViewHeader(
                    showQuitAlert: $showQuitAlert,
                    gameStatus: viewModel.gameStatusText
                )
                
                GameViewPlayers(
                    homeName: homeName,
                    opponentName: viewModel.opponentName,
                    viewModel: viewModel
                )
                
                GameViewScoreBoard(viewModel: viewModel)
                
                GameViewStatistics(viewModel: viewModel)
                
                GameViewScoreInput(
                    viewModel: viewModel,
                    showImpossibleScoreAlert: $showImpossibleScoreAlert
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.shouldShowGameEndAlert) { _, newValue in
            showGameEndAlert = newValue
        }
        .alert("Spiel beenden?", isPresented: $showQuitAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Speichern & Beenden") {
                viewModel.saveUnfinishedMatch(
                    matchId: matchId,
                    historyManager: historyManager
                )
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Das Spiel ist noch nicht beendet. Möchtest du den aktuellen Spielstand speichern?")
        }
        .alert("Unmögliche Punktzahl", isPresented: $showImpossibleScoreAlert) {
            Button("OK") {
                viewModel.resetInput()
            }
        } message: {
            Text("Diese Punktzahl ist mit drei Darts nicht möglich. Bitte gib eine gültige Punktzahl ein.")
        }
        .alert("Spiel beendet", isPresented: $showGameEndAlert) {
            Button("OK") {
                viewModel.saveCompletedMatch(
                    matchId: matchId,
                    historyManager: historyManager,
                    playerManager: playerManager
                )
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("\(viewModel.gameState.player1Sets > viewModel.gameState.player2Sets ? homeName : viewModel.opponentName) hat gewonnen!")
        }
    }
    private func handleGameEnd() {
        if let winner = viewModel.gameState.winner,
           let _ = tournamentMatch,    // match durch _ ersetzt
           let _ = tournamentId {      // id durch _ ersetzt
            onMatchComplete?(winner, "\(viewModel.gameState.player1Sets)-\(viewModel.gameState.player2Sets)")
        }
        showGameEndAlert = true
    }
    }
