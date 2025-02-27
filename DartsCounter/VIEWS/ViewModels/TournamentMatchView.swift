//
//  TournamentMatchView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 11.02.25.
//
import SwiftUI

struct TournamentMatchView: View {
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    let match: TournamentMatch
    let nextMatch: TournamentMatch?
    
    @State private var showingMatchOptions = false
    @State private var showingGameView = false
    @State private var showingResultDetails = false
    @State private var showingEditSheet = false
    @State private var animateWinner = false
    
    private var matchBackground: Color {
        switch true {
        case match.isBye:
            return Color(white: 0.1)
        case match.isCompleted:
            return Color(white: 0.15)
        default:
            return Color(white: 0.2)
        }
    }
    
    private var matchBorderColor: Color {
        switch true {
        case match.isCompleted:
            return .green.opacity(0.3)
        case match.isBye:
            return .blue.opacity(0.3)
        default:
            return Color(white: 0.3)
        }
    }
    
    var body: some View {
        Button(action: {
            showingMatchOptions = true
        }) {
            VStack(spacing: 8) {
                // Match Header
                HStack {
                    Text(match.phase.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    MatchStatusIndicator(match: match)
                }
                
                // Match Content
                VStack(spacing: 4) {
                    if match.isBye {
                        ByeMatchView(player: match.player1)
                    } else {
                        PlayerMatchRow(
                            name: match.player1,
                            isWinner: match.winner == match.player1,
                            animate: animateWinner && match.winner == match.player1
                        )
                        
                        Text("vs")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        PlayerMatchRow(
                            name: match.player2,
                            isWinner: match.winner == match.player2,
                            animate: animateWinner && match.winner == match.player2
                        )
                    }
                }
                
                // Match Score
                if let score = match.score {
                    Text(score)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(matchBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(matchBorderColor, lineWidth: 1)
            )
        }
        .actionSheet(isPresented: $showingMatchOptions) {
            ActionSheet(title: Text(match.isCompleted ? "Abgeschlossenes Spiel" : "Match Optionen"),
                       message: Text(match.isCompleted ?
                                   "\(match.player1) vs \(match.player2)\nErgebnis: \(match.score ?? "")" :
                                   "Wähle eine Option"),
                       buttons: [
                .default(Text(match.isCompleted ? "Details anzeigen" : "Spiel starten")) {
                    if match.isCompleted {
                        showingResultDetails = true
                    } else {
                        showingGameView = true
                    }
                },
                .default(Text("Spiel neu spielen")) {
                    tournamentManager.resetMatch(tournamentId: tournament.id, matchId: match.id)
                    showingGameView = true
                },
                .default(Text("Spieler bearbeiten")) {
                    showingEditSheet = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingResultDetails) {
            MatchResultView(match: match)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditMatchPlayersView(
                tournamentManager: tournamentManager,
                tournament: tournament,
                match: match
            )
        }
        .fullScreenCover(isPresented: $showingGameView) {
            GameView(
                gameMode: .fiveZeroOne,
                opponentType: .human,
                botDifficulty: .easy,
                guestName: match.player2,
                homeName: match.player1,
                historyManager: tournamentManager.historyManager,
                playerManager: tournamentManager.playerManager,
                numberOfSets: tournament.legsToWin.rawValue,
                startingScore: tournament.gamePoints.rawValue,
                savedGameState: nil,
                matchId: match.id,
                onMatchComplete: { winner, score in
                    tournamentManager.completeMatch(
                        tournamentId: tournament.id,
                        matchId: match.id,
                        winner: winner,
                        score: score
                    )
                    animateWinner = true
                }
            )
        }
    }
}

struct PlayerMatchRow: View {
    let name: String
    let isWinner: Bool
    let animate: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(isWinner ? .green : .white)
                .fontWeight(isWinner ? .bold : .regular)
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(.spring(), value: animate)
            
            if isWinner {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .animation(.spring().delay(0.1), value: animate)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isWinner ? Color.green.opacity(0.1) : Color.clear)
        )
    }
}

struct ByeMatchView: View {
    let player: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(player)
                .foregroundColor(.blue)
                .fontWeight(.bold)
            
            Text("Freilos")
                .font(.caption)
                .foregroundColor(.gray)
                .italic()
            
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
        }
    }
}

struct MatchStatusIndicator: View {
    let match: TournamentMatch
    @State private var glowing = false
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(statusColor.opacity(0.5), lineWidth: 2)
                        .scaleEffect(glowing ? 1.5 : 1.0)
                        .opacity(glowing ? 0 : 1)
                )
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
        }
        .onAppear {
            if match.isCompleted {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glowing = true
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch true {
        case match.isCompleted:
            return .green
        case match.isBye:
            return .blue
        default:
            return .gray
        }
    }
    
    private var statusText: String {
        switch true {
        case match.isCompleted:
            return "Abgeschlossen"
        case match.isBye:
            return "Freilos"
        default:
            return "Ausstehend"
        }
    }
}
