import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var sidebarState = SidebarState()
    var dayTimetables = IdentifiedArrayOf<DayTimetableState>()
}

enum AppAction {
    case sidebar(SidebarAction)
    case requestTimetable
    case receiveTimetableResponse(TaskResult<Timetable>)
}

struct AppEnvironment {
    var timetableAPI: TimetableAPI
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
        case .requestTimetable:
            return .task {
                await .receiveTimetableResponse(TaskResult{
                    let result = try await environment.timetableAPI.getTimetable()
                    switch result {
                    case .success(let response):
                        print(response)
                        return response
                    case .failure(let failure):
                        return Timetable(timetable: [])
                    }
                })
            }
        case let .receiveTimetableResponse(.success(timetable)):
            let dates = timetable.extractDayTimetables().map { $0.date }
            state.sidebarState = SidebarState(days: dates)
            return .none
        case .receiveTimetableResponse(.failure):
            return .none
        }
    }
)
