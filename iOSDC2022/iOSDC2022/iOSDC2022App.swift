import SwiftUI
import ComposableArchitecture

@main
struct iOSDC2022App: App {
    @State var store = Store<AppState, AppAction>(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(timetableAPI: APIClient()))
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
//                .onAppear {
//                    Task {
//                        let result = try await APIClient().getTimetable()
//                        switch result {
//                        case .success(let timetable):
//                            let days = timetable.getDays()
//                            for day in days {
//                                print(day.date)
//                            }
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
//                }
        }
    }
}
