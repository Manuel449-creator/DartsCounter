//
//  GameViewPlayers.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 05.02.25.
//
import SwiftUI

struct GameViewPlayers: View {
    let homeName: String
    let opponentName: String
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            GamePlayerHeader(
                name: homeName,
                legs: viewModel.player1Legs,
                sets: viewModel.player1Sets,
                isActive: viewModel.isPlayerTurn,
                isStarting: viewModel.isPlayer1Starting
            )
            
            GamePlayerHeader(
                name: opponentName,
                legs: viewModel.player2Legs,
                sets: viewModel.player2Sets,
                isActive: !viewModel.isPlayerTurn,
                isStarting: !viewModel.isPlayer1Starting
            )
        }
    }
}
