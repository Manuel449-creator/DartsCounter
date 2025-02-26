import SwiftUI

struct TournamentPlayerRow: View {
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(player.name)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(10)
        }
    }
}