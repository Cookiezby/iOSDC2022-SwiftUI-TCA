import SwiftUI
import ComposableArchitecture

#if os(macOS)
struct SidebarState: Equatable {
    var menu: AppSideMenu
}

enum SidebarAction {
    case selectSideMenu(AppSideMenu)
}

struct SidebarEnvironment {}

let sidebarReducer = Reducer<SidebarState, SidebarAction, SidebarEnvironment>.init({ state, action, environment in
    switch action {
    case .selectSideMenu(let menu):
        state.menu = menu
        return .none
    }
})

struct Sidebar: View {
    let store: Store<SidebarState, SidebarAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                Button {
                    viewStore.send(.selectSideMenu(.timetable))
                } label: {
                    Label {
                        Text("Timetable")
                    } icon: {
                        Image(systemName: "calendar.circle")
                    }
                }
                Button {
                    viewStore.send(.selectSideMenu(.schedule))
                } label: {
                    Label {
                        Text("Schedule")
                    } icon: {
                        Image(systemName: "timer.circle")
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
#endif
