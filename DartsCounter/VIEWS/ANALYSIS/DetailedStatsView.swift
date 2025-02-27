//
//  DetailedStatsView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct DetailedStatsView: View {
    let stats: PlayerStatistics
    @State private var showingCheckoutDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detaillierte Statistiken")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            DetailStatRow(
                title: "Siegquote",
                value: String(format: "%.1f%%", stats.winPercentage)
            )
            
            DetailStatRow(
                title: "Bester Average",
                value: String(format: "%.2f", stats.highestAverage)
            )
            
            DetailStatRow(
                title: "First 9 Average",
                value: String(format: "%.2f", stats.first9Average)
            )
            
            DetailStatRow(
                title: "Checkout Rate",
                value: String(format: "%.1f%%", stats.checkoutRate)
            )
            
            DetailStatRow(
                title: "Höchster Checkout",
                value: "\(stats.highestCheckout)"
            )
            
            DetailStatRow(
                title: "Legs gewonnen",
                value: "\(stats.totalLegsWon)/\(stats.totalLegsPlayed)"
            )
            
            Button(action: { showingCheckoutDetails = true }) {
                HStack {
                    Text("Checkouts anzeigen")
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(15)
        .sheet(isPresented: $showingCheckoutDetails) {
            CheckoutDetailsView(checkouts: stats.checkouts)
        }
    }
}

struct CheckoutDetailsView: View {
    let checkouts: [Int]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Checkout-Verteilung")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    
                    if checkouts.isEmpty {
                        Text("Keine Checkouts verfügbar")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach([40, 80, 120, 170], id: \.self) { threshold in
                                let count = checkouts.filter { $0 <= threshold }.count
                                HStack {
                                    Text("Bis \(threshold)")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(count) (\(percentage(count))%)")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Section(header: Text("Höchste Checkouts").foregroundColor(.white)) {
                                ForEach(checkouts.sorted(by: >).prefix(5), id: \.self) { checkout in
                                    Text("\(checkout)")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationBarTitle("Checkouts", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fertig") {
                dismiss()
            })
        }
    }
    
    private func percentage(_ count: Int) -> String {
        guard !checkouts.isEmpty else { return "0" }
        return String(format: "%.1f", (Double(count) / Double(checkouts.count)) * 100)
    }
}

struct DetailStatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
