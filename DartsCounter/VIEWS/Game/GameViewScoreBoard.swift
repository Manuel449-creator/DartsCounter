//
//  GameViewScoreBoard.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 05.02.25.
//
import SwiftUI

struct GameViewScoreBoard: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            Text("\(viewModel.playerScore)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(viewModel.opponentScore)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}
