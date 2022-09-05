import SwiftUI
import ComposableArchitecture


#if os(macOS)
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
    
    var scheduleState: ScheduleState {
        get { ScheduleState(schedule: schedule) }
        set { self.schedule = newValue.schedule}
    }
}

enum AppAction {
    case daySelect(DaySelectAction)
    case dayTimetable(DayTimetableAction)
    case sidebar(SidebarAction)
    case proposal(ProposalAction)
    case schedule(ScheduleAction)
    case loadTimetable
    case timetableResponse(Timetable)
    case sendNavigationPathChanged(NavigationPath)
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
    scheduleReducer.pullback(state: \AppState.scheduleState, action: /AppAction.schedule, environment: { _ in
        ScheduleEnvironment()
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
        case .proposal(.clickProposal(let proposal)):
            state.navigationPath.append(proposal)

            return .none
        case .schedule(.selectProposal(let proposal)):
            state.navigationPath.append(proposal)
            return .none
        }
    }
)

#elseif os(iOS)
enum AppTab {
    case timetable
    case schedule
    case about
}

struct TabNavigationPath: Equatable {
    var timetable = NavigationPath()
    var schedule = NavigationPath()
    var about = NavigationPath()
}

struct AppState: Equatable {
    var tabNavigationPath = TabNavigationPath()
    var selectedTab: AppTab = .timetable
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
    
    var scheduleState: ScheduleState {
        get { ScheduleState(schedule: schedule) }
        set { self.schedule = newValue.schedule}
    }
}

enum AppAction {
    case daySelect(DaySelectAction)
    case dayTimetable(DayTimetableAction)
    case proposal(ProposalAction)
    case schedule(ScheduleAction)
    case loadTimetable
    case timetableResponse(Timetable)
    case selectTab(AppTab)
    case updateTimetableNavigationPath(NavigationPath)
    case updateScheduleNavigationPath(NavigationPath)
    case updateAboutNavigationPath(NavigationPath)
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
    scheduleReducer.pullback(state: \AppState.scheduleState, action: /AppAction.schedule, environment: { _ in
        ScheduleEnvironment()
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
            switch state.selectedTab {
            case .schedule:
                state.tabNavigationPath.schedule.append(proposal)
            case .timetable:
                state.tabNavigationPath.timetable.append(proposal)
            default:
                break
            }
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
        case .proposal(.addToSchedule):
            return .none
        case .proposal(.removeFromSchedule):
            return .none
        case .proposal(.clickProposal(let proposal)):
            switch state.selectedTab {
            case .schedule:
                state.tabNavigationPath.schedule.append(proposal)
            case .timetable:
                state.tabNavigationPath.timetable.append(proposal)
            default:
                break
            }
            return .none
        case .schedule(.selectProposal(let proposal)):
            switch state.selectedTab {
            case .schedule:
                state.tabNavigationPath.schedule.append(proposal)
            case .timetable:
                state.tabNavigationPath.timetable.append(proposal)
            default:
                break
            }
            return .none
        case .selectTab(let tab):
            state.selectedTab = tab
            return .none
        case .updateTimetableNavigationPath(let value):
            state.tabNavigationPath.timetable = value
            return .none
        case .updateScheduleNavigationPath(let value):
            state.tabNavigationPath.schedule = value
            return .none
        case .updateAboutNavigationPath(let value):
            state.tabNavigationPath.about = value
            return .none
        }
    }
)
#endif

struct AppEnvironment {
    var fetchTimetable: @Sendable (Int) async throws -> Timetable
}

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
                        ScheduleView(store: scheduleStore)
                            .navigationDestination(for: Proposal.self) { value in
                                ProposalView(proposal: value, store: proposalStore)
                            }
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
            TabView(selection: viewStore.binding(get: \.selectedTab, send: AppAction.selectTab)){
                NavigationStack(path: viewStore.binding(get: \.tabNavigationPath.timetable, send: AppAction.updateTimetableNavigationPath)){
                    DayTimetableView(store: dayTimetableStore)
                        .toolbar {
                            DaySelectionView(store: daySelectStore)
                        }
                        .navigationDestination(for: Proposal.self) { value in
                            ProposalView(proposal: value, store: proposalStore)
                        }
                }.tabItem {
                    Label("Timetable", systemImage: "calendar.circle")
                }.tag(AppTab.timetable)
                NavigationStack(path: viewStore.binding(get: \.tabNavigationPath.schedule, send: AppAction.updateScheduleNavigationPath)){
                    ScheduleView(store: scheduleStore)
                        .navigationDestination(for: Proposal.self) { value in
                            ProposalView(proposal: value, store: proposalStore)
                        }
                }
                .tabItem {
                    Label("Schedule", systemImage: "timer")
                }.tag(AppTab.schedule)
                NavigationStack(path: viewStore.binding(get: \.tabNavigationPath.about, send: AppAction.updateAboutNavigationPath)){
                    Text("About")
                }
                .tabItem {
                    Label("About", systemImage: "questionmark.circle")
                }.tag(AppTab.about)
            }
            .onAppear(perform: {
                viewStore.send(.loadTimetable)
            })
        }
#endif
    }
}

extension AppView {
    #if os(macOS)
    private var siderbarStore: Store<SidebarState, SidebarAction> {
        store.scope(state: \.sidebar, action: AppAction.sidebar)
    }
    #endif
    
    private var daySelectStore: Store<DaySelectState, DaySelectAction> {
        store.scope(state: \.daySelect, action: AppAction.daySelect)
    }
    
    private var dayTimetableStore: Store<DayTimetableState, DayTimetableAction> {
        store.scope(state: \.dayTimetable, action: AppAction.dayTimetable)
    }
    
    private var proposalStore: Store<ProposalState, ProposalAction> {
        store.scope(state: \.proposalDetail, action: AppAction.proposal)
    }
    
    private var scheduleStore: Store<ScheduleState, ScheduleAction> {
        store.scope(state: \.scheduleState, action: AppAction.schedule)
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
