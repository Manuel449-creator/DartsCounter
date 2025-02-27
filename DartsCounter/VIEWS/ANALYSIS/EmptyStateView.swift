//
//  EmptyStateView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Wähle einen Spieler aus")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Hier werden die Statistiken des ausgewählten Spielers angezeigt")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
