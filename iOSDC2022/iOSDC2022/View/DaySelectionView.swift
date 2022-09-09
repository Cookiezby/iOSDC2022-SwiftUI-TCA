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
            ForEach(Array(viewStore.days.enumerated()), id: \.offset) { index, day in
                Button {
                    viewStore.send(.selectDate(day))
                } label: {
                    Text(day.dayString)
                        .font(Font.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0x4A4A4A))
                        .padding(3)
                }
                .background(day == viewStore.selectedDate ? Color(hex: 0xEDEDED) : Color.white)
                .cornerRadius(3)
            }
        }
    }
}
