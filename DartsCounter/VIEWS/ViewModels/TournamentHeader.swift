//
//  TournamentHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 13.02.25.
//


import SwiftUI

struct TournamentHeader: View {
    let tournament: Tournament
    
    var body: some View {
        VStack(spacing: 8) {
            if tournament.isCompleted {
                CompletedTournamentHeader(tournament: tournament)
            } else {
                ActiveTournamentHeader(tournament: tournament)
            }
        }
        .padding()
        .background(Color(white: 0.1))
    }
}