import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    @State private var path = NavigationPath()
    @State private var day: Int  = 1
    
    var body: some View {
        #if os(macOS)
            WithViewStore(self.store) { viewStore in
                NavigationSplitView {
                    Sidebar(store: sidebarStore)
                } detail: {
                    NavigationStack(path: $path){
                        Text("Empty")
                    }
                }
                .onChange(of: day) { _ in
                    path.removeLast(path.count)
                }
                .onAppear(perform: {
                    viewStore.send(.requestTimetable)
                })
            }
        #else
            Text("Hello")
        #endif
    }
}

extension ContentView {
    private var sidebarStore: Store<SidebarState, SidebarAction> {
        store.scope(state: { $0.sidebarState }, action: AppAction.sidebar)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(timetableAPI: APIClient())))
    }
}
