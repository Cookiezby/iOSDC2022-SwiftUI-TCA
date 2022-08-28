import Foundation


extension Date {
    var siderBarString: String {
        let style = Date.FormatStyle()
            .month(.abbreviated)
            .day(.twoDigits)
            .locale(Locale(identifier: "ja_JP"))
        return formatted(style)
    }
    
    var dayString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        return "\(components.day!)日" 
    }
}
