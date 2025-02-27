//
//  GameViewStatistics 2.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 05.02.25.
//
import SwiftUI

struct GameViewStatistics: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            StatisticsView(
                threeDartAverage: viewModel.playerDartsThrown == 0 ? "0.00" : String(format: "%.2f", calculateAverage(
                    score: viewModel.playerScore,
                    darts: viewModel.playerDartsThrown,
                    totalPoints: viewModel.playerTotalPoints
                )),
                lastScore: viewModel.playerLastScore,
                dartsThrown: "\(viewModel.playerDartsThrown)"
            )
            
            Spacer()
            
            StatisticsView(
                threeDartAverage: viewModel.opponentDartsThrown == 0 ? "0.00" : String(format: "%.2f", calculateAverage(
                    score: viewModel.opponentScore,
                    darts: viewModel.opponentDartsThrown,
                    totalPoints: viewModel.opponentTotalPoints
                )),
                lastScore: viewModel.opponentLastScore,
                dartsThrown: "\(viewModel.opponentDartsThrown)"
            )
        }
        .padding()
    }
    
    private func calculateAverage(score: Int, darts: Int, totalPoints: Int) -> Double {
        guard darts > 0 else { return 0 }
        return (Double(totalPoints) / Double(darts)) * 3.0
    }

    
    struct StatisticsView: View {
        let threeDartAverage: String
        let lastScore: String
        let dartsThrown: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                StatRow(title: "3-DART AVG.", value: threeDartAverage)
                StatRow(title: "LAST SCORE", value: lastScore)
                StatRow(title: "DARTS THROWN", value: dartsThrown)
            }
        }
    }
    
    struct StatRow: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.red)
                    .font(.caption)
                Text(value)
                    .foregroundColor(.white)
                    .font(.body)
            }
        }
    }
}
