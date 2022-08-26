import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var navigationPath = NavigationPath()
    var daySelect = DaySelectState()
    var selectedProposal: Proposal?
    var dayTimetable = DayTimetableState()
    var selectedDate: Date?
    var dayTimetables: [DayTimetable] = []
}

enum AppAction {
    case daySelect(DaySelectAction)
    case dayTimetable(DayTimetableAction)
    case loadTimetable
    case timetableResponse(Timetable)
    case sendNavigationPathChanged(NavigationPath)
}

struct AppEnvironment {
    var fetchTimetable: @Sendable (Int) async throws -> Timetable
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    daySelectReducer.pullback(
        state: \AppState.daySelect,
        action: /AppAction.daySelect,
        environment: { _ in
            DaySelectEnvironment()
        }
    ),
    dayTimetableReducer.pullback(
        state: \AppState.dayTimetable,
        action: /AppAction.dayTimetable,
        environment: { _ in
            DayTimetableEnvironment()
        }
    ),
    .init { state, action, environment in
        switch action {
        case .daySelect(.selectDate(let date)):
            state.selectedDate = date
            let dayTimetable = state.dayTimetables.first(where: {$0.date == date})
            state.dayTimetable = DayTimetableState(dayTimetable: dayTimetable)
            return .none
        case .daySelect:
            return .none
        case .dayTimetable(.clickProposal(let proposal)):
//            state.navigationPath.append(proposal)
//            print(state.navigationPath)
            state.dayTimetable.selectedProposal = proposal
            return .none
        case .dayTimetable:
            return .none
        case .loadTimetable:
            return .task {
                let timetable = try await environment.fetchTimetable(5)
                let action = AppAction.timetableResponse(timetable)
                return action
            }
        case let .timetableResponse(timetable):
            let dayTimetables = timetable.extractDayTimetables()
            let dates = dayTimetables.map { $0.date }
            state.dayTimetables = dayTimetables
            state.selectedDate = dates.first
            state.daySelect = DaySelectState(selectedDate: dates.first, days: dates)
            state.dayTimetable = DayTimetableState(dayTimetable: dayTimetables[0])
            
            return .none
        case .sendNavigationPathChanged(let path):
            state.navigationPath = path
            return .none
        }
    }
)


struct AppView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        #if os(macOS)
            WithViewStore(self.store) { viewStore in
                DayTimetableView(store: dayTimetableStore)
                    .navigationDestination(for: Proposal.self, destination: { value in
                        ProposalView(proposal: value)
                    }).overlay {
                        VStack {
                            Spacer()
                            DaySelectionView(store: daySelectStore)
                                .padding(.bottom, 20)
                        }
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
    private var daySelectStore: Store<DaySelectState, DaySelectAction> {
        store.scope(state: \.daySelect, action: AppAction.daySelect)
    }
    
    private var dayTimetableStore: Store<DayTimetableState, DayTimetableAction> {
        store.scope(state: \.dayTimetable, action: AppAction.dayTimetable)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: AppEnvironment(fetchTimetable: APIClient().getTimetable)
            )
        )
    }
}
