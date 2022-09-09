import SwiftUI
import ComposableArchitecture


struct AppEnvironment {
    var fetchTimetable: @Sendable () async throws -> Timetable
}

#if os(iOS)
enum AppTab {
    case timetable
    case schedule
}

struct TabNavigationPath: Equatable {
    var timetable = NavigationPath()
    var schedule = NavigationPath()
}

struct AppState: Equatable {
    var tabNavigationPath = TabNavigationPath()
    var selectedTab: AppTab = .timetable
    var schedule = Schedule()
    var daySelect = DaySelectState()
    var dayTimetable: DayTimetableState?
    var selectedDate: Date?
    var timetable: Timetable?
}

enum AppAction {
    case daySelect(DaySelectAction)
    case dayTimetable(DayTimetableAction)
    case proposal(ProposalAction)
    case schedule(ScheduleAction)
    case loadTimetable
    case timetableResponse(Timetable)
    case selectTab(AppTab)
    case timetableNavigationPathChanged(NavigationPath)
    case scheduleNavigationPathChanged(NavigationPath)
    case updateProposalState
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    daySelectReducer.pullback(
        state: \AppState.daySelect,
        action: /AppAction.daySelect,
        environment: { _ in
            DaySelectEnvironment()
        }
    ),
    dayTimetableReducer.optional().pullback(
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
        }
    ),
    scheduleReducer.pullback(
        state: \AppState.scheduleState,
        action: /AppAction.schedule,
        environment: { _ in
            ScheduleEnvironment()
        }
    ),
    .init { state, action, environment in
        switch action {
        case .daySelect(.selectDate(let date)):
            state.selectedDate = date
            if let dayTimetable = state.dayTimetables.first(where: {$0.date == date}) {
                state.dayTimetable = DayTimetableState(dayTimetable: dayTimetable)
            }
            return .none
        case .dayTimetable(.clickProposal(let proposal)):
            switch state.selectedTab {
            case .schedule:
                state.tabNavigationPath.schedule.append(proposal)
            case .timetable:
                state.tabNavigationPath.timetable.append(proposal)
            }
            return .none
        case .loadTimetable:
            guard state.dayTimetables.isEmpty else { return .none }
            return .task {
                let timetable = try await environment.fetchTimetable()
                return AppAction.timetableResponse(timetable)
            }
        case let .timetableResponse(timetable):
            let dayTimetables = timetable.extractDayTimetables()
            state.dayTimetables = dayTimetables
            let dates = dayTimetables.map { $0.date }
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
            }
            return .none
        case .schedule(.clickProposal(let proposal)):
            switch state.selectedTab {
            case .schedule:
                state.tabNavigationPath.schedule.append(proposal)
            case .timetable:
                state.tabNavigationPath.timetable.append(proposal)
            }
            return .none
        case .selectTab(let tab):
            state.selectedTab = tab
            return .none
        case .timetableNavigationPathChanged(let value):
            state.tabNavigationPath.timetable = value
            return .none
        case .scheduleNavigationPathChanged(let value):
            state.tabNavigationPath.schedule = value
            return .none
        case .updateProposalState:
            if let dayTimetableState = state.dayTimetable {
                var refreshedDayTimetable = dayTimetableState.dayTimetable.refresh()
                state.dayTimetable = DayTimetableState(dayTimetable: refreshedDayTimetable)
            }
            return .none
        }
    }
)


struct AppView: View {
    let store: Store<AppState, AppAction>
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        WithViewStore(self.store) { viewStore in
            TabView(selection: viewStore.binding(get: \.selectedTab, send: AppAction.selectTab)){
                NavigationStack(
                    path: viewStore.binding(
                        get: \.tabNavigationPath.timetable,
                        send: AppAction.timetableNavigationPathChanged
                    )
                ){
                    IfLetStore(dayTimetableStore, then: { dayTimetableStore in
                        DayTimetableView(store: dayTimetableStore)
                            .navigationDestination(for: Proposal.self) { value in
                                ProposalView(proposal: value, store: proposalStore)
                            }
                            .toolbar {
                                DaySelectionView(store: daySelectStore)
                            }
                    }) {
                        ProgressView()
                    }
                }
                .tabItem {
                    Label("Timetable", systemImage: "calendar.circle")
                }
                .tag(AppTab.timetable)
                
                NavigationStack(
                    path: viewStore.binding(
                        get: \.tabNavigationPath.schedule,
                        send: AppAction.scheduleNavigationPathChanged
                    )
                ){
                    ScheduleView(store: scheduleStore)
                        .navigationDestination(for: Proposal.self) { value in
                            ProposalView(proposal: value, store: proposalStore)
                        }
                }
                .tabItem {
                    Label("Schedule", systemImage: "timer.circle")
                }
                .tag(AppTab.schedule)
            }
            .onAppear(perform: {
                viewStore.send(.loadTimetable)
            })
            .onReceive(timer, perform: { _ in
                viewStore.send(.updateProposalState)
            })
        }
    }
}
#endif

extension AppView {    
    var daySelectStore: Store<DaySelectState, DaySelectAction> {
        store.scope(state: \.daySelect, action: AppAction.daySelect)
    }
    
    var dayTimetableStore: Store<DayTimetableState?, DayTimetableAction> {
        store.scope(state: \.dayTimetable, action: AppAction.dayTimetable)
    }
    
    var proposalStore: Store<ProposalState, ProposalAction> {
        store.scope(state: \.proposalDetail, action: AppAction.proposal)
    }
    
    var scheduleStore: Store<ScheduleState, ScheduleAction> {
        store.scope(state: \.scheduleState, action: AppAction.schedule)
    }
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

