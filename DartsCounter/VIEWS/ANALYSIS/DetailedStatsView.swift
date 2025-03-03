//
//  DetailedStatsView.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 30.01.25.
//
import SwiftUI

struct DetailedStatsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let stats: PlayerStatistics
    @State private var showingCheckoutDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detaillierte Statistiken")
                .font(.headline)
                .foregroundColor(AppColors.text(for: colorScheme))
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
                        .foregroundColor(AppColors.accent)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.secondaryText(for: colorScheme))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground(for: colorScheme))
        .cornerRadius(15)
        .sheet(isPresented: $showingCheckoutDetails) {
            CheckoutDetailsView(checkouts: stats.checkouts)
        }
    }
}

struct CheckoutDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    let checkouts: [Int]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background(for: colorScheme).edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Checkout-Verteilung")
                        .font(.headline)
                        .foregroundColor(AppColors.text(for: colorScheme))
                        .padding()
                    
                    if checkouts.isEmpty {
                        Text("Keine Checkouts verfügbar")
                            .foregroundColor(AppColors.secondaryText(for: colorScheme))
                            .padding()
                    } else {
                        List {
                            ForEach([40, 80, 120, 170], id: \.self) { threshold in
                                let count = checkouts.filter { $0 <= threshold }.count
                                HStack {
                                    Text("Bis \(threshold)")
                                        .foregroundColor(AppColors.text(for: colorScheme))
                                    Spacer()
                                    Text("\(count) (\(percentage(count))%)")
                                        .foregroundColor(AppColors.text(for: colorScheme))
                                }
                                .listRowBackground(AppColors.cardBackground(for: colorScheme))
                            }
                            
                            Section(header: Text("Höchste Checkouts").foregroundColor(AppColors.text(for: colorScheme))) {
                                ForEach(checkouts.sorted(by: >).prefix(5), id: \.self) { checkout in
                                    Text("\(checkout)")
                                        .foregroundColor(AppColors.text(for: colorScheme))
                                }
                                .listRowBackground(AppColors.cardBackground(for: colorScheme))
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
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(AppColors.secondaryText(for: colorScheme))
            Spacer()
            Text(value)
                .foregroundColor(AppColors.text(for: colorScheme))
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
