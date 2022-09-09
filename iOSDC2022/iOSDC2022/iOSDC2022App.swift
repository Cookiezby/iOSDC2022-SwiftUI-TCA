import SwiftUI
import ComposableArchitecture

@main
struct iOSDC2022App: App {
    @State var store = Store<AppState, AppAction>(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment(fetchTimetable: APIClient().getTimetable)
    )
    
    init() {
        #if os(iOS)
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        #endif
    }
    
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            AppView(store: store)
                .frame(minWidth: 1200, minHeight: 700)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        #else
        WindowGroup {
            AppView(store: store)
        }
        #endif
    }
}
