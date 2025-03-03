//
//  CreateTournamentView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 10.02.25.
//

import SwiftUI
import Combine

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
   @State private var keyboardHeight: CGFloat = 0
   @State private var isKeyboardVisible = false
   @State private var cancellables = Set<AnyCancellable>()
   
   // Verzögertes Laden
   @State private var isLoaded = false
   
   var body: some View {
       NavigationView {
           ZStack {
               AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
               
               if !isLoaded {
                   ProgressView()
                       .progressViewStyle(CircularProgressViewStyle())
                       .scaleEffect(1.5)
               } else {
                   ScrollViewReader { scrollProxy in
                       ScrollView {
                           VStack(spacing: 20) {
                               TextField("Turniername", text: $tournamentName)
                                   .id("tournamentNameField")
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .padding()
                                   .foregroundColor(AppColors.text(for: colorScheme))
                                   .onChange(of: isKeyboardVisible) { wasVisible, isVisible in
                                       if isVisible {
                                           // Sanft zum Textfeld scrollen wenn die Tastatur erscheint
                                           withAnimation {
                                               scrollProxy.scrollTo("tournamentNameField", anchor: .top)
                                           }
                                       }
                                   }
                               
                               // Spieler Auswahl
                               VStack(alignment: .leading) {
                                   HStack {
                                       Text("Spieler auswählen")
                                           .font(.headline)
                                           .foregroundColor(AppColors.text(for: colorScheme))
                                       
                                       Spacer()
                                       
                                       Button(action: {
                                           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                               showingAddPlayerSheet = true
                                           }
                                       }) {
                                           HStack {
                                               Image(systemName: "person.badge.plus")
                                               Text("Spieler hinzufügen")
                                           }
                                           .foregroundColor(AppColors.accent)
                                       }
                                   }
                                   .padding(.horizontal)
                                   
                                   LazyVStack(spacing: 10) {
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
                                   UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                   
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                                   }
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
                           .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 20 : 0)
                       }
                   }
               }
           }
           .navigationTitle("Neues Turnier")
           .navigationBarTitleDisplayMode(.inline)
           .navigationBarItems(trailing: Button("Abbrechen") {
               dismiss()
           })
           .foregroundColor(AppColors.text(for: colorScheme))
           .onAppear {
               // View mit Verzögerung laden
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   isLoaded = true
               }
               
               // Tastaturbenachrichtigungen
               let keyboardWillShow = NotificationCenter.default
                   .publisher(for: UIResponder.keyboardWillShowNotification)
                   .receive(on: RunLoop.main)
               
               let keyboardWillHide = NotificationCenter.default
                   .publisher(for: UIResponder.keyboardWillHideNotification)
                   .receive(on: RunLoop.main)
               
               keyboardWillShow
                   .sink { notification in
                       guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                       withAnimation(.easeOut(duration: 0.16)) {
                           self.keyboardHeight = keyboardFrame.height
                           self.isKeyboardVisible = true
                       }
                   }
                   .store(in: &cancellables)
               
               keyboardWillHide
                   .sink { _ in
                       withAnimation(.easeOut(duration: 0.16)) {
                           self.keyboardHeight = 0
                           self.isKeyboardVisible = false
                       }
                   }
                   .store(in: &cancellables)
           }
           .onDisappear {
               // Bereinigen
               cancellables.removeAll()
           }
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
