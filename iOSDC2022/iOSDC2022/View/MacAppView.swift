#if os(macOS)
import Foundation
import ComposableArchitecture
import SwiftUI

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
    var dayTimetable: DayTimetableState?
    var dayTimetables: [DayTimetable] = []
    var selectedDate: Date?
}


enum AppAction {
    case daySelect(DaySelectAction)
    case dayTimetable(DayTimetableAction)
    case sidebar(SidebarAction)
    case proposal(ProposalAction)
    case schedule(ScheduleAction)
    case loadTimetable
    case timetableResponse(Timetable)
    case navigationPathChanged(NavigationPath)
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
    sidebarReducer.pullback(
        state: \AppState.sidebar,
        action: /AppAction.sidebar,
        environment: { _ in
            SidebarEnvironment()
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
            state.navigationPath.append(proposal)
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
        case .navigationPathChanged(let path):
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
        case .schedule(.clickProposal(let proposal)):
            state.navigationPath.append(proposal)
            return .none
        case .updateProposalState:
            if let dayTimetableState = state.dayTimetable {
                var day = dayTimetableState.dayTimetable
                day.update()
                state.dayTimetable = DayTimetableState(dayTimetable: day)
            }
            return .none
        }
    }
)


struct AppView: View {
    let store: Store<AppState, AppAction>
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationSplitView {
                Sidebar(store: siderbarStore)
            } detail: {
                NavigationStack(
                    path: viewStore.binding(
                        get: \.navigationPath,
                        send: AppAction.navigationPathChanged
                    )
                ) {
                    switch viewStore.sidebar.menu {
                    case .timetable:
                        IfLetStore(dayTimetableStore) { dayTimetableStore in
                            DayTimetableView(store: dayTimetableStore)
                                .navigationDestination(for: Proposal.self) { value in
                                    ProposalView(proposal: value, store: proposalStore)
                                }
                                .toolbar {
                                    
                                    DaySelectionView(store: daySelectStore)
                                }
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

extension AppView {
    var siderbarStore: Store<SidebarState, SidebarAction> {
        store.scope(state: \.sidebar, action: AppAction.sidebar)
    }
}

#endif
