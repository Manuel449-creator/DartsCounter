import SwiftUI

// MARK: - Base Models
struct Player: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    var gamesPlayed: Int
    var gamesWon: Int
    
    init(id: UUID = UUID(), name: String, gamesPlayed: Int = 0, gamesWon: Int = 0) {
        self.id = id
        self.name = name
        self.gamesPlayed = gamesPlayed
        self.gamesWon = gamesWon
    }
}



struct Match: Codable, Identifiable {
    let id: UUID
    let date: Date
    let player1: String
    let player2: String
    let gameMode: GameMode
    let legs: [Leg]
    let winner: String?
    let isCompleted: Bool
    let gameState: SavedGameState?
    
    var averagePlayer1: Double {
        let playerTurns = legs.flatMap { leg in
            leg.turns.filter { turn in
                turn.isPlayer1
            }
        }
        
        let totalScore = playerTurns.reduce(0) { sum, turn in
            sum + turn.score
        }
        
        let totalDarts = playerTurns.reduce(0) { sum, turn in
            sum + turn.dartsThrown
        }
        
        return totalDarts > 0 ? Double(totalScore) / (Double(totalDarts) / 3.0) : 0
    }
    
    var averagePlayer2: Double {
        let playerTurns = legs.flatMap { leg in
            leg.turns.filter { turn in
                !turn.isPlayer1
            }
        }
        
        let totalScore = playerTurns.reduce(0) { sum, turn in
            sum + turn.score
        }
        
        let totalDarts = playerTurns.reduce(0) { sum, turn in
            sum + turn.dartsThrown
        }
        
        return totalDarts > 0 ? Double(totalScore) / (Double(totalDarts) / 3.0) : 0
    }
}



struct PlayerStatistics {
    let id: UUID
    let name: String
    var matches: Int
    var wins: Int
    var averageScore: Double
    var highestAverage: Double
    var lowestAverage: Double
    var totalLegsWon: Int
    var totalLegsPlayed: Int
    
    // Neue Statistiken
    var first9Average: Double
    var checkoutRate: Double
    var checkouts: [Int]
    var highestCheckout: Int
    
    var winPercentage: Double {
        guard matches > 0 else { return 0 }
        return Double(wins) / Double(matches) * 100
    }
    
    var legWinPercentage: Double {
        guard totalLegsPlayed > 0 else { return 0 }
        return Double(totalLegsWon) / Double(totalLegsPlayed) * 100
    }
}





// MARK: - Managers
class PlayerManager: ObservableObject {
    @Published var players: [Player] = []
    private let saveKey = "SavedPlayers"
    
    init() {
        loadPlayers()
    }
    
    func addPlayer(name: String) {
        let newPlayer = Player(name: name)
        DispatchQueue.main.async {
            self.players.append(newPlayer)
            self.savePlayers()
            // Force UI update
            self.objectWillChange.send()
        }
    }
    
    func deletePlayer(id: UUID) {
        players.removeAll { $0.id == id }
        savePlayers()
    }
    
    func updatePlayerStats(playerName: String, won: Bool) {
        if let index = players.firstIndex(where: { $0.name == playerName }) {
            var player = players[index]
            player.gamesPlayed += 1
            if won {
                player.gamesWon += 1
            }
            players[index] = player
            savePlayers()
        }
    }
    
    private func savePlayers() {
        if let encoded = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func loadPlayers() {
            if let data = UserDefaults.standard.data(forKey: saveKey),
               let decoded = try? JSONDecoder().decode([Player].self, from: data) {
                players = decoded
        }
    }
}

class MatchHistoryManager: ObservableObject {
    @Published var matches: [Match] = []
    private let saveKey = "DartMatchHistory"
    
    init() {
        loadMatches()
    }
    
    func saveMatch(_ match: Match) {
        matches.append(match)
        saveMatches()
    }
    
    func updateMatch(_ updatedMatch: Match) {
        if let index = matches.firstIndex(where: { $0.id == updatedMatch.id }) {
            matches[index] = updatedMatch
            saveMatches()
        }
    }
    
    func deleteMatch(id: UUID) {
        matches.removeAll { $0.id == id }
        saveMatches()
    }
    
    func deleteMatchesForPlayer(name: String) {
        matches.removeAll { $0.player1 == name || $0.player2 == name }
        saveMatches()
    }
    
    func getPlayerStatistics(for playerName: String) -> PlayerStatistics {
        let playerMatches = matches.filter { $0.player1 == playerName || $0.player2 == playerName }
        let wins = playerMatches.filter { $0.winner == playerName }.count
        
        let averages = playerMatches.map { match in
            if match.player1 == playerName {
                return match.averagePlayer1
            } else {
                return match.averagePlayer2
            }
        }
        
        let legsWon = matches.flatMap { $0.legs }.filter { $0.winner == playerName }.count
        let legsPlayed = matches.flatMap { match -> [Leg] in
            // Für jedes Match bekommen wir die Legs
            return match.legs.filter { leg in
                // Für jedes Leg prüfen, ob der Spieler teilgenommen hat
                leg.turns.contains { turn in
                    (turn.isPlayer1 && match.player1 == playerName) ||
                    (!turn.isPlayer1 && match.player2 == playerName)
                }
            }
        }.count
        
        // Berechnung für First 9 Average
        var first9TotalScore = 0
        var first9DartCount = 0

        for match in playerMatches {
            let isPlayer1 = match.player1 == playerName
            
            for leg in match.legs {
                // Filtere die Turns für diesen Spieler
                let playerTurns = leg.turns.filter { turn in
                    return isPlayer1 ? turn.isPlayer1 : !turn.isPlayer1
                }
                
                // Nimm nur die ersten 3 Turns (= 9 Darts)
                let first3Turns = playerTurns.prefix(3)
                
                for turn in first3Turns {
                    first9TotalScore += turn.score
                    first9DartCount += turn.dartsThrown // Üblicherweise 3 Darts pro Turn
                }
                
                // Wenn weniger als 3 Turns vorhanden sind, haben wir bereits alle für dieses Leg
                if playerTurns.count < 3 {
                    continue
                }
            }
        }

        // Berechne den Durchschnitt pro Dart
        let first9Average = first9DartCount > 0 ? (Double(first9TotalScore) / Double(first9DartCount)) * 3 : 0
        
        // Berechnung für Checkout Rate und Checkouts
        var successfulCheckouts = 0
        var checkoutAttempts = 0
        var checkoutValues: [Int] = []
        
        for match in playerMatches {
            for leg in match.legs {
                let isPlayer1 = match.player1 == playerName
                let playerTurns = leg.turns.filter { isPlayer1 ? $0.isPlayer1 : !$0.isPlayer1 }
                
                if leg.winner == playerName && !playerTurns.isEmpty {
                    // Der letzte Wurf ist der Checkout
                    if let lastTurn = playerTurns.last {
                        successfulCheckouts += 1
                        checkoutValues.append(lastTurn.score)
                    }
                }
                
                // Zähle Checkout-Versuche (wenn Score <= 170)
                for turn in playerTurns {
                    // Annahme: Ein Turn mit Score <= 170 könnte ein Checkout-Versuch sein
                    // Dies ist eine Annäherung, da wir nicht wissen, ob tatsächlich auf ein Doppel gezielt wurde
                    if turn.score <= 170 {
                        checkoutAttempts += 1
                    }
                }
            }
        }
        
        let checkoutRate = checkoutAttempts > 0 ? (Double(successfulCheckouts) / Double(checkoutAttempts)) * 100 : 0
        let highestCheckout = checkoutValues.max() ?? 0
        
        return PlayerStatistics(
            id: UUID(),
            name: playerName,
            matches: playerMatches.count,
            wins: wins,
            averageScore: averages.isEmpty ? 0 : averages.reduce(0, +) / Double(averages.count),
            highestAverage: averages.max() ?? 0,
            lowestAverage: averages.min() ?? 0,
            totalLegsWon: legsWon,
            totalLegsPlayed: legsPlayed,
            first9Average: first9Average,
            checkoutRate: checkoutRate,
            checkouts: checkoutValues,
            highestCheckout: highestCheckout
        )
    }
    
    private func saveMatches() {
        if let encoded = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadMatches() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Match].self, from: data) {
            matches = decoded
        }
    }
    
    func reloadMatches() {
        loadMatches()
        // Optional: Benachrichtigung über Änderungen
        objectWillChange.send()
    }
}

struct ContentView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var historyManager = MatchHistoryManager()
    @StateObject private var playerManager = PlayerManager()
    @State private var selectedTab = 0
    @State private var selectedGameMode: GameMode = .fiveZeroOne
    @State private var opponentType: OpponentType = .human
    @State private var botDifficulty: BotDifficulty = .easy
    @State private var guestName: String = ""
    @State private var homeName: String = ""
    @State private var showingGuestPlayerSelection = false
    @State private var showingHomePlayerSelection = false
    @State private var selectedSets = SetConfiguration.options[1]
    @State private var showingThemeSettings = false
    @State private var isTournamentMode = false
    
    // Berechne das effektive Farbschema basierend auf den Benutzereinstellungen
    private var effectiveColorScheme: ColorScheme {
        switch themeManager.theme {
        case .system: return colorScheme
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    GameSetupView(
                        selectedGameMode: $selectedGameMode,
                        opponentType: $opponentType,
                        botDifficulty: $botDifficulty,
                        guestName: $guestName,
                        homeName: $homeName,
                        showingGuestPlayerSelection: $showingGuestPlayerSelection,
                        showingHomePlayerSelection: $showingHomePlayerSelection,
                        selectedSets: $selectedSets,
                        historyManager: historyManager,
                        playerManager: playerManager
                    )
                    .tabItem {
                        Label("Spiel", systemImage: "gamecontroller")
                    }
                    .tag(0)
                    
                    AnalysisView(historyManager: historyManager, playerManager: playerManager)
                        .tabItem {
                            Label("Analyse", systemImage: "chart.bar")
                        }
                        .tag(1)
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(
                    effectiveColorScheme == .dark ? Color.black : Color.white,
                    for: .tabBar
                )
                .tint(AppColors.accent)
                // Wichtig: Stellen Sie sicher, dass Inhalt nicht unter die TabBar scrollt
                .safeAreaInset(edge: .bottom) {
                    // Diese leere View sorgt für den korrekten Abstand am unteren Rand
                    Color.clear.frame(height: 0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingThemeSettings = true
                    }) {
                        Image(systemName: themeManager.theme.icon)
                            .foregroundColor(AppColors.text(for: colorScheme))
                    }
                }
            }
            .sheet(isPresented: $showingThemeSettings) {
                ThemeSettingsView()
                    .presentationDetents([.height(250)])
            }
            .onChange(of: colorScheme) { _, _ in }
            .onChange(of: themeManager.theme) { _, _ in }
        }
        .accentColor(AppColors.accent)
        .preferredColorScheme(themeManager.theme.colorScheme == .dark ? .dark : themeManager.theme.colorScheme == .light ? .light : nil)
    }
}

// Neue View für die Theme-Einstellungen
struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AppTheme.allCases) { theme in
                    Button(action: {
                        themeManager.theme = theme
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: theme.icon)
                                .foregroundColor(AppColors.accent)
                            
                            Text(theme.rawValue)
                                .foregroundColor(AppColors.text(for: colorScheme))
                            
                            Spacer()
                            
                            if themeManager.theme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.accent)
                            }
                        }
                    }
                    .listRowBackground(AppColors.cardBackground(for: colorScheme))
                }
            }
            .navigationTitle("Erscheinungsbild")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .background(AppColors.background(for: colorScheme))
        }
        .preferredColorScheme(themeManager.theme.colorScheme)
    }
}
struct GameSetupView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedGameMode: GameMode
    @Binding var opponentType: OpponentType
    @Binding var botDifficulty: BotDifficulty
    @Binding var guestName: String
    @Binding var homeName: String
    @Binding var showingGuestPlayerSelection: Bool
    @Binding var showingHomePlayerSelection: Bool
    @Binding var selectedSets: String
    @State private var isTournamentMode = false
    let historyManager: MatchHistoryManager
    let playerManager: PlayerManager
    
    private var numberOfSetsFromSelection: Int {
        switch selectedSets {
        case "Best of 3": return 3
        case "Best of 5": return 5
        case "Best of 7": return 7
        default: return 5
        }
    }
    
    private var shouldEnableStartButton: Bool {
        if opponentType == .bot {
            return !homeName.isEmpty
        } else {
            return !homeName.isEmpty && !guestName.isEmpty && homeName != guestName
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    TitleSection()
                    GameModeSection(selectedGameMode: $selectedGameMode)

                    NavigationLink(destination: TournamentView(playerManager: playerManager)) {
                        HStack {
                            Image(systemName: "trophy")
                                .foregroundColor(AppColors.secondaryText(for: colorScheme))
                            Text("Turniermodus")
                                .foregroundColor(AppColors.text(for: colorScheme))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.cardBackground(for: colorScheme))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    SetSelectionSection(selectedSets: $selectedSets)
                    PlayerSelectionSection(
                        homeName: $homeName,
                        showingHomePlayerSelection: $showingHomePlayerSelection
                    )
                    OpponentSection(
                        opponentType: $opponentType,
                        botDifficulty: $botDifficulty,
                        guestName: $guestName,
                        showingGuestPlayerSelection: $showingGuestPlayerSelection
                    )
                    StartGameButton(
                        homeName: homeName,
                        guestName: guestName,
                        opponentType: opponentType,
                        botDifficulty: botDifficulty,
                        numberOfSets: numberOfSetsFromSelection,
                        selectedGameMode: selectedGameMode,
                        historyManager: historyManager,
                        playerManager: playerManager,
                        isEnabled: shouldEnableStartButton
                    )
                }
                .padding()
                .padding(.bottom, 90)
            }
        }
        .sheet(isPresented: $showingGuestPlayerSelection) {
            PlayerSelectionSheet(
                playerManager: playerManager,
                historyManager: historyManager,
                selectedPlayerName: $guestName,
                excludePlayerName: homeName
            )
        }
        .sheet(isPresented: $showingHomePlayerSelection) {
            PlayerSelectionSheet(
                playerManager: playerManager,
                historyManager: historyManager,
                selectedPlayerName: $homeName,
                excludePlayerName: guestName
            )
        }
    }
}

struct TitleSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Text("Dart Counter")
            .font(.largeTitle)
            .foregroundColor(AppColors.text(for: colorScheme))
            .padding()
    }
}

struct GameModeSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedGameMode: GameMode
    
    var body: some View {
        VStack {
            Text("Spielmodus auswählen")
                .font(.headline)
                .foregroundColor(AppColors.text(for: colorScheme))
            
            Picker("Spielmodus", selection: $selectedGameMode) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
    }
}

struct SetSelectionSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedSets: String
    
    var body: some View {
        VStack {
            Text("Sätze")
                .font(.headline)
                .foregroundColor(AppColors.text(for: colorScheme))
            
            Picker("Sätze", selection: $selectedSets) {
                ForEach(SetConfiguration.options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
    }
}

struct PlayerSelectionSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var homeName: String
    @Binding var showingHomePlayerSelection: Bool
    
    var body: some View {
        VStack {
            Text("Heimspieler")
                .font(.headline)
                .foregroundColor(AppColors.text(for: colorScheme))
            
            Button(action: {
                showingHomePlayerSelection = true
            }) {
                Text(homeName.isEmpty ? "Spieler auswählen" : homeName)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.cardBackground(for: colorScheme))
                    .foregroundColor(AppColors.text(for: colorScheme))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

struct OpponentSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var opponentType: OpponentType
    @Binding var botDifficulty: BotDifficulty
    @Binding var guestName: String
    @Binding var showingGuestPlayerSelection: Bool
    
    var body: some View {
        VStack {
            Text("Gegenspieler auswählen")
                .font(.headline)
                .foregroundColor(AppColors.text(for: colorScheme))
            
            Picker("Gegenspieler", selection: $opponentType) {
                ForEach(OpponentType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if opponentType == .bot {
                VStack {
                    Text("Bot-Schwierigkeitsstufe")
                        .font(.headline)
                        .foregroundColor(AppColors.text(for: colorScheme))
                    
                    Picker("Bot-Schwierigkeit", selection: $botDifficulty) {
                        ForEach(BotDifficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
            } else {
                VStack {
                    Text("Gegner")
                        .font(.headline)
                        .foregroundColor(AppColors.text(for: colorScheme))
                    
                    Button(action: {
                        showingGuestPlayerSelection = true
                    }) {
                        Text(guestName.isEmpty ? "Spieler auswählen" : guestName)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.cardBackground(for: colorScheme))
                            .foregroundColor(AppColors.text(for: colorScheme))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct StartGameButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let homeName: String
    let guestName: String
    let opponentType: OpponentType
    let botDifficulty: BotDifficulty
    let numberOfSets: Int
    let selectedGameMode: GameMode
    let historyManager: MatchHistoryManager
    let playerManager: PlayerManager
    let isEnabled: Bool
    
    var body: some View {
        NavigationLink {
            GameView(
                gameMode: selectedGameMode,
                opponentType: opponentType,
                botDifficulty: botDifficulty,
                guestName: guestName,
                homeName: homeName,
                historyManager: historyManager,
                playerManager: playerManager,
                numberOfSets: numberOfSets,
                startingScore: GamePoints.fiveOOne.rawValue,
                savedGameState: nil
            )
        } label: {
            Text("Spiel starten")
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isEnabled ? AppColors.accent : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!isEnabled)
        .padding()
    }
}


struct AddPlayerSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var playerManager: PlayerManager
    @Binding var selectedPlayerName: String
    @State private var newPlayerName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
                
                VStack {
                    TextField("Spielername", text: $newPlayerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if !newPlayerName.isEmpty {
                            playerManager.addPlayer(name: newPlayerName)
                            selectedPlayerName = newPlayerName
                            playerManager.loadPlayers() // Laden Sie die Spieler neu
                            dismiss()
                        }
                    }) {
                        Text("Spieler hinzufügen")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(newPlayerName.isEmpty ? Color.gray : AppColors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(newPlayerName.isEmpty)
                }
            }
            .navigationTitle("Neuer Spieler")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Abbrechen") {
                dismiss()
            })
        }
    }
}
