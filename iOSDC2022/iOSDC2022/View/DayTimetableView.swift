import SwiftUI
import ComposableArchitecture
import Foundation

struct DayTimetableState: Equatable, Identifiable {
    var id = UUID()
    var dayTimetable: DayTimetable?
}

enum DayTimetableAction: Equatable {
    case selectElement(TimetableElement)
}


struct DayTimetableEnvironment: Equatable {}

let dayTimetableReducer = Reducer<DayTimetableState, DayTimetableAction, DayTimetableEnvironment>.init { state, action, environement in
    switch action {
    case .selectElement(let element):
        return .none
    }
}


struct DayTimetableView: View {
    let store:Store<DayTimetableState, DayTimetableAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            if let timetables = viewStore.dayTimetable?.timetables {
                List {
                    ForEach(timetables) { timetable in
                        Text(timetable.title)
                    }
                }
            } else {
                Text("Empty")
            }
        }
    }
}


//struct DayTimetableView_Previews: PreviewProvider {
//    static var previews: some View {
//        DayTimetableView()
//    }
//}
