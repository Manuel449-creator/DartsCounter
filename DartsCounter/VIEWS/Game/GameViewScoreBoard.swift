//
//  GameViewScoreBoard.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 05.02.25.
//
import SwiftUI

struct GameViewScoreBoard: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            Text("\(viewModel.playerScore)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(AppColors.text(for: colorScheme))
            
            Spacer()
            
            Text("\(viewModel.opponentScore)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(AppColors.text(for: colorScheme))
        }
        .padding(.horizontal)
    }
}
