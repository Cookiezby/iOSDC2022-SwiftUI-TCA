import SwiftUI
import ComposableArchitecture

@main
struct iOSDC2022App: App {
    @State var store = Store<AppState, AppAction>(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(fetchTimetable: APIClient().getTimetable))
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
