import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Track {
    var background: LinearGradient {
        LinearGradient(
            gradient: graident,
            startPoint: UnitPoint(x: 0.0, y: 0.5),
            endPoint: UnitPoint(x: 1.0, y: 0.5)
        )
    }
    
    private var graident: Gradient {
        switch self.name {
        case .trackA:
            return Gradient(colors: [Color(hex: 0x02aab0), Color(hex: 0x00cdac)])
        case .trackB:
            return Gradient(colors: [Color(hex: 0xff758c), Color(hex: 0xff7eb3)])
        case .trackC:
            return Gradient(colors: [Color(hex: 0xF76B1C), Color(hex: 0xFEAD3F)])
        case .trackD:
            return Gradient(colors: [Color(hex: 0x56ab2f), Color(hex: 0xa8e063)])
        case .trackE:
            return Gradient(colors: [Color(hex: 0x56ab2f), Color(hex: 0xa8e063)])
        }
    }
}
