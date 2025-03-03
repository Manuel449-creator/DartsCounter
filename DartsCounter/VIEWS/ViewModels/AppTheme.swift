import SwiftUI

// MARK: - Theme Enum
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "AppTheme")
        }
    }
    
    init() {
        // Load saved theme or use default
        if let savedThemeString = UserDefaults.standard.string(forKey: "AppTheme"),
           let savedTheme = AppTheme(rawValue: savedThemeString) {
            self.theme = savedTheme
        } else {
            self.theme = .dark // Default theme
        }
    }
}

// MARK: - Theme Colors
struct AppColors {
    // Common Colors
    static let accent = Color.blue
    
    // Light Mode Colors
    static let lightBackground = Color(white: 0.95)
    static let lightCardBackground = Color.white
    static let lightText = Color.black
    static let lightSecondaryText = Color.gray
    
    // Dark Mode Colors
    static let darkBackground = Color.black
    static let darkCardBackground = Color(white: 0.15)
    static let darkText = Color.white
    static let darkSecondaryText = Color.gray
    
    // Dynamic Colors
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkBackground : lightBackground
    }
    
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkCardBackground : lightCardBackground
    }
    
    static func text(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkText : lightText
    }
    
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkSecondaryText : lightSecondaryText
    }
}