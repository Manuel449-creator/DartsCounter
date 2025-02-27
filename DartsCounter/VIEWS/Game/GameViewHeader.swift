//
//  GameViewHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 05.02.25.
//
import SwiftUI

struct GameViewHeader: View {
    @Binding var showQuitAlert: Bool
    let gameStatus: String
    
    var body: some View {
        HStack {
            Button(action: {
                showQuitAlert = true
            }) {
                Text("Quit")
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(gameStatus)
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {}) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.white)
                }
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}
