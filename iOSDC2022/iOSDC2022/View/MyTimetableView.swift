import SwiftUI
import ComposableArchitecture

struct MyTimetableState: Equatable {
    
}

enum MyTimetableAction {
    
}

struct MyTimatableEnvironment {
    
}


struct MyTimetableView: View {
    var myTimetable: MyTimetable
    var body: some View {
        HStack {
            ForEach(myTimetable.dayTimetables) {
                Text($0.date.dayString)
            }
        }
    }
}

struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        MyTimetableView(myTimetable: MyTimetable())
    }
}
