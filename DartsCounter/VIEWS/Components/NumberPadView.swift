import SwiftUI

struct NumberPadView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var inputScore: String
    let onUndo: () -> Void
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<3) { row in
                HStack(spacing: 1) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        NumberButton(text: "\(number)") {
                            if inputScore.count < 3 {
                                inputScore += "\(number)"
                            }
                        }
                    }
                }
            }
            
            HStack(spacing: 1) {
                NumberButton(text: "←") {
                    onUndo()
                }
                
                NumberButton(text: "0") {
                    if inputScore.count < 3 {
                        inputScore += "0"
                    }
                }
                
                NumberButton(text: "") { }
            }
        }
    }
}

struct NumberButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 32, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(AppColors.text(for: colorScheme))
                .background(AppColors.cardBackground(for: colorScheme))
        }
        .frame(height: 60)
    }
}
