import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    let exportText: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text(exportText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("Turnier Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: exportText,
                        subject: Text("Turnier Export"),
                        message: Text("Hier sind die Turnierdaten:")
                    )
                }
            }
        }
    }
}