import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var sidebar = SidebarState()
    var dayTimetable = DayTimetableState()
    var selectedDate: Date?
    var dayTimetables: [DayTimetable] = []
}

enum AppAction {
    case sidebar(SidebarAction)
    case dayTimetable(DayTimetableAction)
    case loadTimetable
    case timetableResponse(TaskResult<Timetable>)
}

struct AppEnvironment {
    var fetchTimetable: @Sendable (Int) async throws -> Timetable
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    sidebarReducer.pullback(
        state: \AppState.sidebar,
        action: /AppAction.sidebar,
        environment: { _ in
            SidebarEnvironment()
        }
    ),
    .init { state, action, environment in
        switch action {
        case .sidebar(.selectDate(let date)):
            state.selectedDate = date
            let dayTimetable = state.dayTimetables.first(where: {$0.date == date})
            state.dayTimetable = DayTimetableState(dayTimetable: dayTimetable)
            return .none
        case .sidebar:
            return .none
        case .loadTimetable:
            return .task {
                await .timetableResponse(
                    TaskResult{ try await environment.fetchTimetable(5) }
                )
            }
        case let .timetableResponse(.success(timetable)):
            let dayTimetables = timetable.extractDayTimetables()
            let dates = dayTimetables.map { $0.date }
            state.dayTimetables = dayTimetables
            state.selectedDate = dates.first
            state.sidebar = SidebarState(days: dates)
            state.dayTimetable = DayTimetableState(dayTimetable: dayTimetables[0])

            return .none
        case .timetableResponse(.failure):
            print("load timetable faild")
            return .none
        case .dayTimetable:
            return .none
        }
    }
)


struct AppView: View {
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
                        DayTimetableView(store: dayTimetableStore)
                    }
                }
                .onChange(of: day) { _ in
                    path.removeLast(path.count)
                }
                .onAppear(perform: {
                    viewStore.send(.loadTimetable)
                })
            }
        #else
            Text("Hello")
        #endif
    }
}

extension AppView {
    private var sidebarStore: Store<SidebarState, SidebarAction> {
        store.scope(state: \.sidebar, action: AppAction.sidebar)
    }
    
    private var dayTimetableStore: Store<DayTimetableState, DayTimetableAction> {
        store.scope(state: \.dayTimetable, action: AppAction.dayTimetable)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(fetchTimetable: APIClient().getTimetable)))
    }
}
