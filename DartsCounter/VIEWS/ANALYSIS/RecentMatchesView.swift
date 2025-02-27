//
//  RecentMatchesView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct RecentMatchesView: View {
    let player: Player
    let matches: [Match]
    @ObservedObject var historyManager: MatchHistoryManager
    @State private var showingDeleteMatchAlert = false
    @State private var matchToDelete: Match?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Letzte Spiele")
                .font(.headline)
                .foregroundColor(.white)
            
            if matches.isEmpty {
                Text("Noch keine Spiele")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(matches) { match in
                    HStack {
                        RecentMatchCard(match: match, playerName: player.name)
                        
                        Button(action: {
                            matchToDelete = match
                            showingDeleteMatchAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(.leading)
                        }
                    }
                }
            }
        }
        .alert("Spiel löschen", isPresented: $showingDeleteMatchAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                if let match = matchToDelete {
                    historyManager.deleteMatch(id: match.id)
                }
            }
        } message: {
            Text("Möchtest du dieses Spiel wirklich löschen?")
        }
    }
}

struct RecentMatchCard: View {
    let match: Match
    let playerName: String
    @State private var showingMatchDetails = false
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: match.date)
    }
    
    var average: Double {
        match.player1 == playerName ? match.averagePlayer1 : match.averagePlayer2
    }
    
    var body: some View {
        Button(action: { showingMatchDetails = true }) {
            VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(match.player1) vs \(match.player2)")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(match.winner == playerName ? "Sieg" : "Niederlage")
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(match.winner == playerName ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                    .foregroundColor(match.winner == playerName ? .green : .red)
                    .cornerRadius(8)
            }
            
            Text("Average: \(String(format: "%.2f", average))")
                .font(.caption)
                .foregroundColor(.gray)
        }
            .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showingMatchDetails) {
                        MatchDetailView(match: match, playerName: playerName)
                    }
                }
            }
