import SwiftUI

struct GameViewScoreInput: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: GameViewModel
    @Binding var showImpossibleScoreAlert: Bool
    
    var body: some View {
        VStack {
            // Turn Indicator
            ZStack {
                Color(red: 1, green: 0.3, blue: 0.2)
                Text("\(viewModel.isPlayerTurn ? viewModel.homeName : viewModel.opponentName)'s TURN TO THROW!")
                    .foregroundColor(.white) // Bleibt weiß auf rotem Hintergrund
                    .font(.headline)
                    .padding()
            }
            
            // Score Input
            HStack {
                Button(action: {}) {
                    Image(systemName: "square.grid.3x3.fill")
                        .foregroundColor(AppColors.text(for: colorScheme))
                        .font(.title2)
                }
                .padding()
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.white : Color.white)
                        .frame(height: 36)
                    
                    if viewModel.inputScore.isEmpty {
                        Text("TOTAL SCORE")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                    }
                    
                    Text(viewModel.inputScore)
                        .foregroundColor(.black) // Immer schwarz auf weißem Eingabefeld
                        .padding(.leading, 8)
                }
                
                Button(action: {
                    if let score = Int(viewModel.inputScore) {
                        viewModel.submitScore(score)
                    } else {
                        viewModel.resetInput()
                    }
                }) {
                    Text("SUBMIT\nSCORE")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white) // Bleibt weiß auf grünem Hintergrund
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Number Pad
            NumberPadView(inputScore: $viewModel.inputScore) {
                if viewModel.inputScore.isEmpty {
                    viewModel.undoLastTurn()
                } else {
                    viewModel.inputScore.removeLast()
                }
            }
            .padding(.top)
        }
    }
}
struct GameViewScoreInput_Previews: PreviewProvider {
    static var previews: some View {
        GameViewScoreInput(
            viewModel: GameViewModel(
                savedGameState: nil,
                homeName: "Player 1",
                guestName: "Player 2",
                opponentType: .human,
                botDifficulty: .easy,
                numberOfSets: 5
            ),
            showImpossibleScoreAlert: .constant(false)
        )
    }
}
