import SwiftUI
import ComposableArchitecture

struct ScheduleState: Equatable {
    var schedule: Schedule
}

enum ScheduleAction {
    case selectProposal(proposal: Proposal)
}

struct ScheduleEnvironment {}

let scheduleReducer: Reducer<ScheduleState, ScheduleAction, ScheduleEnvironment> = .init({ state, action, environment in
    switch action {
    case .selectProposal(let proposal):
        return .none
    }
})

struct ScheduleView: View {
    var store: Store<ScheduleState, ScheduleAction>
    var body: some View {
        WithViewStore(store){ viewStore in
#if os(macOS)
            HStack(spacing: 5){
                ForEach(viewStore.schedule.daySchedules) { daySchedule in
                    VStack {
                        HStack {
                            Text(daySchedule.date.dayString)
                                .padding(.leading, 3)
                                .font(Font.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        ScrollView {
                            ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                                Button(action: {
                                    viewStore.send(.selectProposal(proposal: proposal))
                                }, label: {
                                    ProposalCell(proposal: proposal)
                                        .frame(height: 80)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.leading, 10)
            .background(Color.white)
#elseif os(iOS)
            iOSScheduleView(usePageTab: UIDevice.current.userInterfaceIdiom == .phone) {
                ForEach(viewStore.schedule.daySchedules) { daySchedule in
                    VStack(spacing: 5){
                        HStack {
                            Text(daySchedule.date.dayString)
                                .padding(.leading, 3)
                                .font(Font.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        ScrollView {
                            ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                                Button(action: {
                                    viewStore.send(.selectProposal(proposal: proposal))
                                }, label: {
                                    ProposalCell(proposal: proposal)
                                        .frame(height: 80)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .background(Color.white)
            }
#endif
        }
        
    }
    
    @ViewBuilder
    func iOSScheduleView<Content>(
        usePageTab: Bool,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        if usePageTab {
            TabView {
                content()
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
#if os(iOS)
            .tabViewStyle(PageTabViewStyle())
#endif
        } else {
            HStack(spacing: 5){
                content()
            }
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
}

struct MyListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(store: Store<ScheduleState, ScheduleAction>.init(initialState: ScheduleState(schedule: Schedule()), reducer: scheduleReducer, environment: ScheduleEnvironment()))
    }
}
