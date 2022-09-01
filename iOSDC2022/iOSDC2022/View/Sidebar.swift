import SwiftUI
import ComposableArchitecture

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
                        Image(systemName: "timer")
                    }
                }
                
                Button {
                    viewStore.send(.selectSideMenu(.about))
                } label: {
                    Label {
                        Text("About")
                    } icon: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

//struct Siderbar_Previews: PreviewProvider {
//    static var previews: some View {
//        Siderbar(store: Store(initialState: <#T##State#>, reducer: <#T##Reducer<State, Action, Environment>#>, environment: <#T##Environment#>))
//    }
//}
