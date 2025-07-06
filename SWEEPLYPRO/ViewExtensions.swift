//
//  ViewExtensions.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

// Extension to add placeholder to TextField
extension View {
    func placeholderText<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Extension for hex color conversion
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// StatusBarBlurView - Creates a blurred area at the top of the screen for the status bar
struct StatusBarBlurView: View {
    var height: CGFloat? = nil
    var style: UIBlurEffect.Style = .systemThinMaterial
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    // Blur effect with system material
                    BlurView(style: style)
                        .frame(width: geometry.size.width, height: height ?? geometry.safeAreaInsets.top)
                }
                .frame(height: height ?? geometry.safeAreaInsets.top)
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
        }
        .frame(height: 0) // Zero height so it doesn't take up space in the layout
    }
}

// UIViewRepresentable for UIBlurEffect to get native blur effect
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// Extension to apply the status bar blur to any view
extension View {
    func withStatusBarBlur(style: UIBlurEffect.Style = .systemThinMaterial) -> some View {
        ZStack(alignment: .top) {
            self
            StatusBarBlurView(style: style)
        }
    }
    
    // Function to add padding equal to the safe area top inset
    func statusBarPadding() -> some View {
        modifier(StatusBarPaddingModifier())
    }
}

// Modifier to add padding equal to the safe area top inset
struct StatusBarPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.top, geometry.safeAreaInsets.top)
        }
    }
} // Test comment for GitHub auto-push
// Another test comment for GitHub auto-push
