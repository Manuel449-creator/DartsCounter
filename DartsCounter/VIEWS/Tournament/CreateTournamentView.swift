//
//  CreateTournamentView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 10.02.25.
//


import SwiftUI

struct CreateTournamentView: View {
   @Environment(\.colorScheme) private var colorScheme
   @Environment(\.dismiss) var dismiss
   @ObservedObject var tournamentManager: TournamentManager
   @ObservedObject var playerManager: PlayerManager
   
   @State private var tournamentName = ""
   @State private var selectedPlayers: Set<UUID> = []
   @State private var showingAddPlayerSheet = false
   @State private var selectedGamePoints: GamePoints = .fiveOOne
   @State private var selectedLegsToWin: LegsToWin = .three
   @State private var selectedTournamentMode: TournamentMode = .sets
   
   var body: some View {
       NavigationView {
           ZStack {
               AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
               
               ScrollView {
                   VStack(spacing: 20) {
                       TextField("Turniername", text: $tournamentName)
                           .textFieldStyle(RoundedBorderTextFieldStyle())
                           .padding()
                           .foregroundColor(AppColors.text(for: colorScheme))
                       
                       // Spieler Auswahl
                       VStack(alignment: .leading) {
                           HStack {
                               Text("Spieler auswählen")
                                   .font(.headline)
                                   .foregroundColor(AppColors.text(for: colorScheme))
                               
                               Spacer()
                               
                               Button(action: {
                                   showingAddPlayerSheet = true
                               }) {
                                   HStack {
                                       Image(systemName: "person.badge.plus")
                                       Text("Spieler hinzufügen")
                                   }
                                   .foregroundColor(AppColors.accent)
                               }
                           }
                           .padding(.horizontal)
                           
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
                       
                       // Spieleinstellungen
                       VStack(alignment: .leading) {
                           Text("Spieleinstellungen")
                               .font(.headline)
                               .foregroundColor(AppColors.text(for: colorScheme))
                               .padding(.horizontal)
                           
                           // Turniermodus: Sets oder Legs
                           VStack(alignment: .leading) {
                               Text("Spielmodus")
                                   .font(.subheadline)
                                   .foregroundColor(AppColors.secondaryText(for: colorScheme))
                                   .padding(.horizontal)
                               
                               Picker("Turniermodus", selection: $selectedTournamentMode) {
                                   ForEach(TournamentMode.allCases, id: \.self) { mode in
                                       Text(mode.rawValue).tag(mode)
                                   }
                               }
                               .pickerStyle(SegmentedPickerStyle())
                               .padding(.horizontal)
                           }
                           
                           VStack(alignment: .leading) {
                               Text("Punkte")
                                   .font(.subheadline)
                                   .foregroundColor(AppColors.secondaryText(for: colorScheme))
                                   .padding(.horizontal)
                               
                               Picker("Punkte", selection: $selectedGamePoints) {
                                   ForEach(GamePoints.allCases, id: \.self) { points in
                                       Text(points.description).tag(points)
                                   }
                               }
                               .pickerStyle(SegmentedPickerStyle())
                               .padding(.horizontal)
                           }
                           
                           VStack(alignment: .leading) {
                               Text(selectedTournamentMode == .sets ? "Sets" : "Legs")
                                   .font(.subheadline)
                                   .foregroundColor(AppColors.secondaryText(for: colorScheme))
                                   .padding(.horizontal)
                               
                               Picker(selectedTournamentMode == .sets ? "Sets" : "Legs", selection: $selectedLegsToWin) {
                                   ForEach(LegsToWin.allCases, id: \.self) { legs in
                                       Text(legs.description).tag(legs)
                                   }
                               }
                               .pickerStyle(SegmentedPickerStyle())
                               .padding(.horizontal)
                           }
                       }
                       
                       Button(action: {
                           let selectedPlayersList = playerManager.players.filter { selectedPlayers.contains($0.id) }
                           let tournament = Tournament(
                               name: tournamentName,
                               players: selectedPlayersList,
                               gamePoints: selectedGamePoints,
                               legsToWin: selectedLegsToWin,
                               tournamentMode: selectedTournamentMode
                           )
                           tournamentManager.addTournament(tournament)
                           dismiss()
                       }) {
                           Text("Turnier erstellen")
                               .foregroundColor(.white)
                               .padding()
                               .frame(maxWidth: .infinity)
                               .background(isFormValid ? AppColors.accent : Color.gray)
                               .cornerRadius(10)
                       }
                       .disabled(!isFormValid)
                       .padding()
                   }
                   .padding(.bottom, 20)
               }
           }
           .navigationTitle("Neues Turnier")
           .navigationBarTitleDisplayMode(.inline)
           .navigationBarItems(trailing: Button("Abbrechen") {
               dismiss()
           })
           .foregroundColor(AppColors.text(for: colorScheme))
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
