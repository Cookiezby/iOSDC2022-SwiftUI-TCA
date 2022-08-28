import SwiftUI
import ComposableArchitecture

@main
struct iOSDC2022App: App {
    @State var store = Store<AppState, AppAction>(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(fetchTimetable: APIClient().getTimetable))
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            AppView(store: store)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        #else
        WindowGroup {
            AppView(store: store)
        }
        #endif
    }
}
