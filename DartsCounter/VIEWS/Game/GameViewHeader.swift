//
//  GameViewHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 05.02.25.
//
import SwiftUI

struct GameViewHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var showQuitAlert: Bool
    let gameStatus: String
    
    var body: some View {
        HStack {
            Button(action: {
                showQuitAlert = true
            }) {
                Text("Quit")
                    .foregroundColor(AppColors.text(for: colorScheme))
            }
            
            Spacer()
            
            Text(gameStatus)
                .foregroundColor(AppColors.text(for: colorScheme))
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {}) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(AppColors.text(for: colorScheme))
                }
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .foregroundColor(AppColors.text(for: colorScheme))
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground(for: colorScheme))
    }
}
