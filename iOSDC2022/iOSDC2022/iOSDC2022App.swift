import SwiftUI
import ComposableArchitecture

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { start, action, environemnt in
    switch action {}
}

@main
struct iOSDC2022App: App {
    let api = APIClient()
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment()))
                .onAppear {
                    Task {
                        do {
                            let result = try await api.getAllTimetables()
                        } catch {
                            
                        }
                    }
                }
        }
    }
}
