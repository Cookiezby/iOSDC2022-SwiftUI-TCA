import ComposableArchitecture
import SwiftUI

struct DaySelectState: Equatable {
    var selectedDate: Date?
    var days: [Date] = []
}

enum DaySelectAction: Equatable {
    case selectDate(Date)
}

struct DaySelectEnvironment: Equatable {}

let daySelectReducer = Reducer<DaySelectState, DaySelectAction, DaySelectEnvironment>.init { state, action, environement in
    switch action {
    case .selectDate(let date):
        state.selectedDate = date
        return .none
    }
}

struct DaySelectionView: View {
    let store: Store<DaySelectState, DaySelectAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            ForEach(Array(viewStore.days.enumerated()), id: \.offset) { index, element in
                Button {
                    viewStore.send(.selectDate(element))
                } label: {
                    Text(element.dayString)
                        .foregroundColor(Color(hex: 0x4A4A4A))
                        .frame(width: 50)
                }
                .background(isSelected(date: element) ? Color(hex: 0xEDEDED) : Color.white)
                .cornerRadius(3)
                
            }
        }
    }
    
    func isSelected(date: Date) -> Bool {
        if let selected = ViewStore(self.store).selectedDate, date == selected {
            return true
        } else {
            return false
        }
    }
}
