import Foundation

extension Date {    
    var dayString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        return "\(components.day!)日" 
    }
}
