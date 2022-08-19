import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var sidebarState = SidebarState()
    var dayTimetables = IdentifiedArrayOf<DayTimetableState>()
}

enum AppAction {
    case sidebar(SidebarAction)
    case loadTimetable
    case timetableResponse(TaskResult<Timetable>)
}

struct AppEnvironment {
    var fetchTimetable: () async throws -> Timetable
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    sidebarReducer.pullback(
        state: \AppState.sidebarState,
        action: /AppAction.sidebar,
        environment: { _ in
            SidebarEnvironment()
        }
    ),
    .init { state, action, environment in
        switch action {
        case .sidebar(.selectDate(let date)):
            print(date)
            return .none
        case .sidebar:
            return .none
        case .loadTimetable:
            return Effect.task {
                await .timetableResponse(
                    TaskResult{ try await environment.fetchTimetable() }
                )
            }
        case let .timetableResponse(.success(timetable)):
            let dates = timetable.extractDayTimetables().map { $0.date }
            state.sidebarState = SidebarState(days: dates)
            return .none
        case .timetableResponse(.failure):
            print("load timetable faild")
            return .none
        }
    }
)
