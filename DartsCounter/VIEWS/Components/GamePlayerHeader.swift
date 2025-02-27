//
//  GamePlayerHeader.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//


// In einem neuen File: Views/Game/GamePlayerHeader.swift
import SwiftUI

struct GamePlayerHeader: View {
    let name: String
    let legs: Int
    let sets: Int
    let isActive: Bool
    let isStarting: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(isActive ? Color.red : Color.gray)
                    .frame(width: 10, height: 10)
                
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                
                Text(name)
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text("S\(sets)")
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .background(Color.blue)
                        .cornerRadius(4)
                    
                    Text("L\(legs)")
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .background(Color.green)
                        .cornerRadius(4)
                }
                
                if isStarting {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            if isActive {
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 2)
            }
        }
    }
}
