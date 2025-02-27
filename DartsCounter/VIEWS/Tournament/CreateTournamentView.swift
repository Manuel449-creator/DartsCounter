//
//  CreateTournamentView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 10.02.25.
//


import SwiftUI

struct CreateTournamentView: View {
   @Environment(\.dismiss) var dismiss
   @ObservedObject var tournamentManager: TournamentManager
   @ObservedObject var playerManager: PlayerManager
   
   @State private var tournamentName = ""
   @State private var selectedPlayers: Set<UUID> = []
   @State private var showingAddPlayerSheet = false
   @State private var selectedGamePoints: GamePoints = .fiveOOne
   @State private var selectedLegsToWin: LegsToWin = .three
   
   var body: some View {
       NavigationView {
           ZStack {
               Color.black.edgesIgnoringSafeArea(.all)
               
               VStack(spacing: 20) {
                   TextField("Turniername", text: $tournamentName)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()
                   
                   // Spieler Auswahl
                   VStack(alignment: .leading) {
                       HStack {
                           Text("Spieler auswählen")
                               .font(.headline)
                               .foregroundColor(.white)
                           
                           Spacer()
                           
                           Button(action: {
                               showingAddPlayerSheet = true
                           }) {
                               HStack {
                                   Image(systemName: "person.badge.plus")
                                   Text("Spieler hinzufügen")
                               }
                               .foregroundColor(.blue)
                           }
                       }
                       .padding(.horizontal)
                       
                       ScrollView {
                           VStack(spacing: 10) {
                               ForEach(playerManager.players) { player in
                                   TournamentPlayerRow(
                                       player: player,
                                       isSelected: selectedPlayers.contains(player.id),
                                       onTap: {
                                           if selectedPlayers.contains(player.id) {
                                               selectedPlayers.remove(player.id)
                                           } else {
                                               selectedPlayers.insert(player.id)
                                           }
                                       }
                                   )
                               }
                           }
                           .padding()
                       }
                   }
                   
                   // Spieleinstellungen
                   VStack(alignment: .leading) {
                       Text("Spieleinstellungen")
                           .font(.headline)
                           .foregroundColor(.white)
                           .padding(.horizontal)
                       
                       Picker("Punkte", selection: $selectedGamePoints) {
                           ForEach(GamePoints.allCases, id: \.self) { points in
                               Text(points.description).tag(points)
                           }
                       }
                       .pickerStyle(SegmentedPickerStyle())
                       .padding()
                       
                       Picker("Legs", selection: $selectedLegsToWin) {
                           ForEach(LegsToWin.allCases, id: \.self) { legs in
                               Text(legs.description).tag(legs)
                           }
                       }
                       .pickerStyle(SegmentedPickerStyle())
                       .padding()
                   }
                   
                   Button(action: {
                       let selectedPlayersList = playerManager.players.filter { selectedPlayers.contains($0.id) }
                       let tournament = Tournament(
                           name: tournamentName,
                           players: selectedPlayersList,
                           gamePoints: selectedGamePoints,
                           legsToWin: selectedLegsToWin
                       )
                       print("Debug - Creating Tournament with points: \(selectedGamePoints.rawValue)")  // Neue Debug-Zeile
                       print("Debug - Tournament object points: \(tournament.gamePoints.rawValue)")      // Neue Debug-Zeile
                       tournamentManager.addTournament(tournament)
                       dismiss()
                   }) {
                       Text("Turnier erstellen")
                           .foregroundColor(.white)
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(isFormValid ? Color.blue : Color.gray)
                           .cornerRadius(10)
                   }
                   .disabled(!isFormValid)
                   .padding()
               }
           }
           .navigationTitle("Neues Turnier")
           .navigationBarTitleDisplayMode(.inline)
           .navigationBarItems(trailing: Button("Abbrechen") {
               dismiss()
           })
       }
       .sheet(isPresented: $showingAddPlayerSheet) {
           AddPlayerSheet(
               playerManager: playerManager,
               selectedPlayerName: .constant("")
           )
       }
   }
   
   var isFormValid: Bool {
       !tournamentName.isEmpty && selectedPlayers.count >= 2
   }
}
