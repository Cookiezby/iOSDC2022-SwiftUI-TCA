import SwiftUI
import ComposableArchitecture

@main
struct iOSDC2022App: App {
    let api = APIClient()
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
        }
    }
}
