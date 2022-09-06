import SwiftUI
import ComposableArchitecture

struct ScheduleState: Equatable {
    var schedule: Schedule
}

enum ScheduleAction {
    case clickProposal(Proposal)
}

struct ScheduleEnvironment {}

let scheduleReducer: Reducer<ScheduleState, ScheduleAction, ScheduleEnvironment> = .init({ state, action, environment in
    switch action {
    case .clickProposal:
        return .none
    }
})

struct ScheduleView: View {
    var store: Store<ScheduleState, ScheduleAction>
    var body: some View {
#if os(macOS)
            HStack(spacing: 5){
                ScheduleTrackView(store: store)
                Spacer(minLength: 0)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .background(Color.white)
#elseif os(iOS)
            MobileScheduleView {
                ScheduleTrackView(store: store)
            }
#endif
        }

#if os(iOS)
    @ViewBuilder
    func MobileScheduleView<Content>(
        content: @escaping () -> Content
    ) -> some View where Content: View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView {
                content()
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            .tabViewStyle(PageTabViewStyle())

        } else {
            HStack(spacing: 5){
                content()
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
        }
    }
#endif
}

struct ScheduleTrackView: View {
    var store: Store<ScheduleState, ScheduleAction>
    var body: some View {
        WithViewStore(store){ viewStore in
            ForEach(viewStore.schedule.daySchedules) { daySchedule in
                VStack(spacing: 5){
                    HStack {
                        Text(daySchedule.date.dayString)
                            .padding(.leading, 3)
                            .font(Font.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Spacer(minLength: 0)
                    }
                    ScrollView {
                        ForEach(Array(daySchedule.proposals.enumerated()), id: \.offset) { index, proposal in
                            Button(action: {
                                viewStore.send(.clickProposal(proposal))
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
    }
}

struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(store: Store<ScheduleState, ScheduleAction>.init(
            initialState: ScheduleState(schedule: Schedule()),
            reducer: scheduleReducer,
            environment: ScheduleEnvironment())
        )
    }
}
