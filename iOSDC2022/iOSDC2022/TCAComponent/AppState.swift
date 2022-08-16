import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var timetables: [TimetableElement] = []
}

enum AppAction {

}

struct AppEnvironment {
    
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { start, action, environemnt in
    switch action {}
}
