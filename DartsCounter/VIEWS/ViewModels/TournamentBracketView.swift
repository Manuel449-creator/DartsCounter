import SwiftUI

// Connection Line Base Component

// Connection Line Base Component
struct TournamentBracketConnectionLine: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let startX = 0
                let endX = geometry.size.width
                let centerY = geometry.size.height / 2
                path.move(to: CGPoint(x: Double(startX), y: centerY))
                path.addLine(to: CGPoint(x: Double(endX), y: centerY))
            }
            .stroke(AppColors.secondaryText(for: colorScheme).opacity(0.5), lineWidth: 1)
        }
    }
}

// Main Bracket View
struct TournamentBracketView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var tournamentManager: TournamentManager
    let tournament: Tournament
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .center, spacing: 0) {
                let phases = tournament.matches.map { $0.phase }.unique()
                ForEach(phases, id: \.self) { phase in
                    HStack(spacing: 0) {
                        let phaseMatches = tournament.matches.filter { $0.phase == phase }
                        VStack(spacing: calculateSpacing(for: phase)) {
                            ForEach(phaseMatches) { match in
                                TournamentMatchView(
                                    tournamentManager: tournamentManager,
                                    tournament: tournament,
                                    match: match,
                                    nextMatch: tournamentManager.getNextMatch(for: match)
                                )
                                .frame(width: 200)
                            }
                        }
                        
                        if phase != .final {
                            VStack(spacing: calculateConnectionSpacing(for: phase)) {
                                ForEach(0..<(phaseMatches.count/2), id: \.self) { index in
                                    TournamentMatchConnector(
                                        match: phaseMatches[index * 2],
                                        nextMatch: tournamentManager.getNextMatch(for: phaseMatches[index * 2])
                                    )
                                }
                            }
                            .padding(.vertical, calculateVerticalPadding(for: phase))
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppColors.background(for: colorScheme))
    }
    
    private func calculateSpacing(for phase: TournamentPhase) -> CGFloat {
        switch phase {
        case .round256: return 10
        case .round128: return 20
        case .round64: return 40
        case .round32: return 80
        case .firstRound: return 160
        case .quarterFinal: return 320
        case .semiFinal: return 640
        case .final, .thirdPlace: return 0
        }
    }
    
    private func calculateConnectionSpacing(for phase: TournamentPhase) -> CGFloat {
        calculateSpacing(for: phase) * 2 + 50
    }
    
    private func calculateVerticalPadding(for phase: TournamentPhase) -> CGFloat {
        calculateSpacing(for: phase) / 2
    }
}

// Animated Connection Line
struct AnimatedConnectionLine: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationProgress: CGFloat = 0
    let isActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let startX = Double(0)
                let endX = Double(geometry.size.width)
                let centerY = Double(geometry.size.height / 2)
                path.move(to: CGPoint(x: startX, y: centerY))
                path.addLine(to: CGPoint(x: endX * Double(animationProgress), y: centerY))
            }
            .stroke(isActive ? Color.green : AppColors.secondaryText(for: colorScheme).opacity(0.5), lineWidth: 1)
        }
    }
}

// Tournament Bracket Connection
struct TournamentBracketConnection: View {
    @Environment(\.colorScheme) private var colorScheme
    let match: TournamentMatch
    let nextMatch: TournamentMatch?
    @State private var animationProgress: CGFloat = 0
    
    var connectionStatus: ConnectionStatus {
        if match.isCompleted {
            return .completed
        } else if match.isBye {
            return .bye
        } else {
            return .pending
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base Line (always visible)
                Path { path in
                    drawConnectionPath(&path, for: geometry)
                }
                .stroke(AppColors.secondaryText(for: colorScheme).opacity(0.3), lineWidth: 1)
                
                // Animated Progress Line
                Path { path in
                    drawConnectionPath(&path, for: geometry)
                }
                .trim(from: 0, to: animationProgress)
                .stroke(connectionStatus.color, lineWidth: 2)
            }
        }
        .onChange(of: match.isCompleted) { _, completed in
            if completed {
                withAnimation(.easeOut(duration: 0.8)) {
                    animationProgress = 1
                }
            }
        }
        .onAppear {
            if match.isCompleted || match.isBye {
                animationProgress = 1
            }
        }
    }

    private func drawConnectionPath(_ path: inout Path, for geometry: GeometryProxy) {
        let startX = Double(0)
        let endX = Double(geometry.size.width)
        let centerY = Double(geometry.size.height / 2)
        let controlPointX = Double(endX * 0.5)
        
        path.move(to: CGPoint(x: startX, y: centerY))
        path.addCurve(
            to: CGPoint(x: endX, y: centerY),
            control1: CGPoint(x: controlPointX, y: centerY),
            control2: CGPoint(x: controlPointX, y: centerY)
        )
    }
}

// Connection Status Enum
enum ConnectionStatus {
    case pending
    case completed
    case bye
    
    var color: Color {
        switch self {
        case .pending: return .gray
        case .completed: return .green
        case .bye: return .blue
        }
    }
}

// Match Connector
struct TournamentMatchConnector: View {
    @Environment(\.colorScheme) private var colorScheme
    let match: TournamentMatch
    let nextMatch: TournamentMatch?
    
    var body: some View {
        VStack {
            TournamentBracketConnection(match: match, nextMatch: nextMatch)
                .frame(width: 30, height: 50)
        }
    }
}

// Utility Extension
extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
