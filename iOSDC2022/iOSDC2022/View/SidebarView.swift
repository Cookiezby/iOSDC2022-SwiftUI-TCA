import ComposableArchitecture
import SwiftUI

struct SidebarState: Equatable {
    var days: [Date] = []
}

enum SidebarAction: Equatable {
    case selectDate(Date)
}

struct SidebarEnvironment: Equatable {}

let sidebarReducer = Reducer<SidebarState, SidebarAction, SidebarEnvironment>.init { state, action, environement in
    switch action {
    case .selectDate:
        return .none
    }
}

struct SiderbarView: View {
    let store: Store<SidebarState, SidebarAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                ForEach(Array(viewStore.days.enumerated()), id: \.offset) { index, element in
                    Button(action: {
                        viewStore.send(.selectDate(element))
                    }, label: {
                        Text("\(index)")
                    })
                }
            }
        }
    }
}

struct SideBar_Previews: PreviewProvider {
    static var previews: some View {
        SiderbarView(store: Store<SidebarState, SidebarAction>(initialState: SidebarState(), reducer: sidebarReducer, environment: SidebarEnvironment()))
    }
}
