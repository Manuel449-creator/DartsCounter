//
//  MatchDetailView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 26.02.25.
//
import SwiftUI

struct MatchDetailView: View {
    let match: Match
    let playerName: String
    @Environment(\.dismiss) var dismiss
    
    var isPlayer1: Bool {
        match.player1 == playerName
    }
    
    var playerAverage: Double {
        isPlayer1 ? match.averagePlayer1 : match.averagePlayer2
    }
    
    var opponentAverage: Double {
        isPlayer1 ? match.averagePlayer2 : match.averagePlayer1
    }
    
    var playerLegsWon: Int {
        match.legs.filter { $0.winner == playerName }.count
    }
    
    var opponentLegsWon: Int {
        match.legs.filter { $0.winner != playerName && $0.winner != nil }.count
    }
    
    var isWinner: Bool {
        match.winner == playerName
    }
    
    // Berechnung für First 9 Average
    var playerFirst9Average: Double {
        var first9Scores = 0.0
        var first9Count = 0
        
        for leg in match.legs {
            let playerTurns = leg.turns.filter { isPlayer1 ? $0.isPlayer1 : !$0.isPlayer1 }.prefix(3)
            let legFirst9Score = playerTurns.reduce(0) { sum, turn in
                return sum + turn.score
            }
            
            if !playerTurns.isEmpty {
                first9Scores += Double(legFirst9Score)
                first9Count += playerTurns.count
            }
        }
        
        return first9Count > 0 ? first9Scores / (Double(first9Count) * 3) : 0
    }
    
    // Checkout-Statistiken
    var playerCheckouts: [Int] {
        var checkouts: [Int] = []
        
        for leg in match.legs where leg.winner == playerName {
            let playerTurns = leg.turns.filter { isPlayer1 ? $0.isPlayer1 : !$0.isPlayer1 }
            if let lastTurn = playerTurns.last {
                checkouts.append(lastTurn.score)
            }
        }
        
        return checkouts
    }
    
    var highestCheckout: Int {
        playerCheckouts.max() ?? 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Match Header
                        VStack(spacing: 8) {
                            HStack {
                                Text(match.player1)
                                    .fontWeight(match.winner == match.player1 ? .bold : .regular)
                                    .foregroundColor(match.winner == match.player1 ? .green : .white)
                                
                                Text("vs")
                                    .foregroundColor(.gray)
                                
                                Text(match.player2)
                                    .fontWeight(match.winner == match.player2 ? .bold : .regular)
                                    .foregroundColor(match.winner == match.player2 ? .green : .white)
                            }
                            .font(.title2)
                            
                            Text("\(playerLegsWon) - \(opponentLegsWon)")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text(isWinner ? "Sieg" : "Niederlage")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isWinner ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                .foregroundColor(isWinner ? .green : .red)
                                .cornerRadius(8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(white: 0.15))
                        .cornerRadius(15)
                        
                        // Player Statistics
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Deine Statistiken")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 4)
                            
                            DetailStatRow(
                                title: "3-Dart Average",
                                value: String(format: "%.2f", playerAverage)
                            )
                            
                            DetailStatRow(
                                title: "First 9 Average",
                                value: String(format: "%.2f", playerFirst9Average)
                            )
                            
                            DetailStatRow(
                                title: "Höchster Checkout",
                                value: "\(highestCheckout)"
                            )
                            
                            DetailStatRow(
                                title: "Legs gewonnen",
                                value: "\(playerLegsWon)"
                            )
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(white: 0.15))
                        .cornerRadius(15)
                        
                        // Leg History
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Leg-Verlauf")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 4)
                            
                            ForEach(match.legs) { leg in
                                LegSummaryRow(
                                    leg: leg,
                                    playerName: playerName,
                                    isPlayer1: isPlayer1
                                )
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(white: 0.15))
                        .cornerRadius(15)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Spieldetails", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fertig") {
                dismiss()
            })
        }
    }
}

struct LegSummaryRow: View {
    let leg: Leg
    let playerName: String
    let isPlayer1: Bool
    
    var isWinner: Bool {
        leg.winner == playerName
    }
    
    var playerTurns: [Turn] {
        leg.turns.filter { isPlayer1 ? $0.isPlayer1 : !$0.isPlayer1 }
    }
    
    var opponentTurns: [Turn] {
        leg.turns.filter { isPlayer1 ? !$0.isPlayer1 : $0.isPlayer1 }
    }
    
    var playerAverage: Double {
        let totalScore = playerTurns.reduce(0) { $0 + $1.score }
        let totalDarts = playerTurns.reduce(0) { $0 + $1.dartsThrown }
        return totalDarts > 0 ? Double(totalScore) / (Double(totalDarts) / 3.0) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(isWinner ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(isWinner ? "Gewonnen" : "Verloren")
                    .font(.subheadline)
                    .foregroundColor(isWinner ? .green : .red)
                
                Spacer()
                
                Text("Avg: \(String(format: "%.2f", playerAverage))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !playerTurns.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(0..<playerTurns.count, id: \.self) { index in
                            Text("\(playerTurns[index].score)")
                                .font(.caption)
                                .padding(4)
                                .background(Color(white: 0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(10)
    }
}
