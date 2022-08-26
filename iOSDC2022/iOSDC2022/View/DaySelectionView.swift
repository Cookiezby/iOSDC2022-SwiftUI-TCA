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
        WithViewStore(self.store) { viewStore in
            HStack {
                ForEach(Array(viewStore.days.enumerated()), id: \.offset) { index, element in
                    Button {
                        viewStore.send(.selectDate(element))
                    } label: {
                        Text(element.dayString)
                    }
                }
            }
            
            .padding()
            .clipped()
            .frame(width: 150, height: 40)
            .cornerRadius(10)
            .background(Capsule().foregroundColor(Color.red))
            .opacity(viewStore.days.isEmpty ? 0.0 : 1.0)
            
        }
    }
}

//struct DaySelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        DaySelectionView(store: )
//    }
//}
