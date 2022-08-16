import SwiftUI
import Foundation

struct TimetableView: View {
    @Binding var day: Int
    var body: some View {
        Text("Timetable \(day)")
    }
}


struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView(day: .constant(1))
    }
}
