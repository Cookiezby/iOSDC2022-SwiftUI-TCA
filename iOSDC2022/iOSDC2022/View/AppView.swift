import SwiftUI
import ComposableArchitecture

enum AppSideMenu {
    case timetable
    case myTimetable
    case about
}

struct AppState: Equatable {
    var sideMenu: AppSideMenu = .timetable
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
    case selectSideMenu(AppSideMenu)
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
            print(proposal.title)
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
            
            return .none
        case .sendNavigationPathChanged(let path):
            state.navigationPath = path
            return .none
        case .selectSideMenu(let menu):
            state.sideMenu = menu
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
                List {
                    Button {
                        viewStore.send(.selectSideMenu(.timetable))
                    } label: {
                        Label {
                            Text("Timetable")
                        } icon: {
                            Image(systemName: "rectangle.grid.3x2")
                        }
                    }.buttonStyle(PlainButtonStyle())
                    
                    Button {
                        viewStore.send(.selectSideMenu(.myTimetable))
                    } label: {
                        Label {
                            Text("MyTimetable")
                        } icon: {
                            Image(systemName: "rectangle.grid.3x2")
                        }
                    }.buttonStyle(PlainButtonStyle())
                    
                    Button {
                        viewStore.send(.selectSideMenu(.about))
                    } label: {
                        Label {
                            Text("About")
                        } icon: {
                            Image(systemName: "questionmark.circle")
                        }
                    }.buttonStyle(PlainButtonStyle())
                }.background(Color.white)
            } detail: {
                switch viewStore.sideMenu {
                case .timetable:
                    NavigationStack(path: viewStore.binding(get: \.navigationPath, send: AppAction.sendNavigationPathChanged)) {
                        DayTimetableView(store: dayTimetableStore)
                            .onAppear(perform: {
                                viewStore.send(.loadTimetable)
                            })
                            .navigationDestination(for: Proposal.self) { value in
                                ProposalView(proposal: value)
                            }
                    }
                case .myTimetable:
                    MyTimetableView()
                case .about:
                    Text("About")
                }
                
            }.toolbar {
                DaySelectionView(store: daySelectStore)
            }
        }
#else
        
        WithViewStore(self.store) { viewStore in
            NavigationSplitView(columnVisibility: $columnVisibility){
                List {
                    Label {
                        Text("Timetable")
                    } icon: {
                        Image(systemName: "rectangle.split.3x3")
                    }

                    Label {
                        Text("Help")
                    } icon: {
                        Image(systemName: "questionmark.circle")
                    }
                }.background(Color.white)
            } detail: {
                NavigationStack(path: viewStore.binding(get: \.navigationPath, send: AppAction.sendNavigationPathChanged)) {
                    DayTimetableView(store: dayTimetableStore)
                        .onAppear(perform: {
                            viewStore.send(.loadTimetable)
                        })
                        .navigationDestination(for: Proposal.self) { value in
                            ProposalView(proposal: value)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
                
            }
        }
        
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
