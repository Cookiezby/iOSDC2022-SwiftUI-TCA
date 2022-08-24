import Foundation


extension Date {
    var siderBarString: String {
        let style = Date.FormatStyle()
            .month(.abbreviated)
            .day(.twoDigits)
            .locale(Locale(identifier: "ja_JP"))
        return formatted(style)
    }
}
