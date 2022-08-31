import SwiftUI
import ComposableArchitecture

enum AppSideMenu {
    case timetable
    case schedule
    case about
}

struct AppState: Equatable {
    var navigationPath = NavigationPath()
    var sidebar = SidebarState(menu: .timetable)
    var schedule = Schedule()
    var daySelect = DaySelectState()
    var dayTimetable = DayTimetableState()
    var selectedDate: Date?
    var dayTimetables: [DayTimetable] = []
}

extension AppState {
    var proposalDetail: ProposalState {
        get { ProposalState(schedule: schedule) }
        set { self.schedule = newValue.schedule }
    }
}

enum AppAction {
    case daySelect(DaySelectAction)
    case dayTimetable(DayTimetableAction)
    case sidebar(SidebarAction)
    case proposal(ProposalAction)
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
    proposalReducer.pullback(
        state: \AppState.proposalDetail,
        action: /AppAction.proposal,
        environment: { _ in
            ProposalEnvironment()
        }),
    sidebarReducer.pullback(
        state: \AppState.sidebar,
        action: /AppAction.sidebar,
        environment: { _ in
            SidebarEnvironment()
        }),
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
            state.navigationPath.append(proposal)
            return .none
        case .dayTimetable:
            return .none
        case .loadTimetable:
            guard state.dayTimetables.isEmpty else {
                return .none
            }
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
            for dayTimetable in dayTimetables {
                if !state.schedule.daySchedules.contains(where: {$0.date == dayTimetable.date}) {
                    state.schedule.add(day: dayTimetable.date)
                }
            }
            
            return .none
        case .sendNavigationPathChanged(let path):
            state.navigationPath = path
            return .none
        case .sidebar(.selectSideMenu(let menu)):
            state.navigationPath.removeLast(state.navigationPath.count)
            return .none
        case .proposal(.addToSchedule):
            return .none
        case .proposal(.removeFromSchedule):
            return .none
        }
    }
)


struct AppView: View {
    let store: Store<AppState, AppAction>
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    var body: some View {
#if os(macOS)
        WithViewStore(self.store) { viewStore in
            NavigationSplitView(columnVisibility: $columnVisibility){
                Sidebar(store: siderbarStore)
            } detail: {
                NavigationStack(
                    path: viewStore.binding(
                        get: \.navigationPath,
                        send: AppAction.sendNavigationPathChanged
                    )
                ) {
                    switch viewStore.sidebar.menu {
                    case .timetable:
                        DayTimetableView(store: dayTimetableStore)
                            .navigationDestination(for: Proposal.self) { value in
                                ProposalView(proposal: value, store: proposalStore)
                            }
                            .toolbar {
                                DaySelectionView(store: daySelectStore)
                            }
                        
                    case .schedule:
                        ScheduleView(schedule: viewStore.schedule)
                    case .about:
                        Text("About")
                    }
                }
                .onAppear(perform: {
                    viewStore.send(.loadTimetable)
                })
            }
        }
#else
        WithViewStore(self.store) { viewStore in
            NavigationSplitView(columnVisibility: $columnVisibility){
                Sidebar(store: siderbarStore)
            } detail: {
                NavigationStack(
                    path: viewStore.binding(
                        get: \.navigationPath,
                        send: AppAction.sendNavigationPathChanged
                    )
                ) {
                    switch viewStore.sidebar.menu {
                    case .timetable:
                        DayTimetableView(store: dayTimetableStore)
                            .navigationDestination(for: Proposal.self) { value in
                                ProposalView(proposal: value, store: proposalStore)
                            }
                            .toolbar {
                                DaySelectionView(store: daySelectStore)
                            }
                        
                    case .schedule:
                        ScheduleView(schedule: viewStore.schedule)
                    case .about:
                        Text("About")
                    }
                }
                .onAppear(perform: {
                    viewStore.send(.loadTimetable)
                })
            }
        }
#endif
    }
}

extension AppView {
    private var siderbarStore: Store<SidebarState, SidebarAction> {
        store.scope(state: \.sidebar, action: AppAction.sidebar)
    }
    private var daySelectStore: Store<DaySelectState, DaySelectAction> {
        store.scope(state: \.daySelect, action: AppAction.daySelect)
    }
    
    private var dayTimetableStore: Store<DayTimetableState, DayTimetableAction> {
        store.scope(state: \.dayTimetable, action: AppAction.dayTimetable)
    }
    
    private var proposalStore: Store<ProposalState, ProposalAction> {
        store.scope(state: \.proposalDetail, action: AppAction.proposal)
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
