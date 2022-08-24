import SwiftUI
import ComposableArchitecture
import Foundation

struct DayTimetableState: Equatable, Identifiable {
    var id = UUID()
    var selectedProposal: Proposal?
    var dayTimetable: DayTimetable?
    
    init(
        selectedProposal: Proposal? = nil,
        dayTimetable: DayTimetable? = nil
    ) {
        self.selectedProposal = selectedProposal
        self.dayTimetable = dayTimetable
    }
}

enum DayTimetableAction: Equatable {
    case selectElement(TimetableElement)
    case clickProposal(Proposal)
}

struct DayTimetableEnvironment: Equatable {}

let dayTimetableReducer = Reducer<DayTimetableState, DayTimetableAction, DayTimetableEnvironment>.init { state, action, environement in
    switch action {
    case .selectElement(let element):
        return .none
    case .clickProposal:
        return .none
    }
}


struct DayTimetableView: View {
    let store:Store<DayTimetableState, DayTimetableAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                
                if let timetables = viewStore.dayTimetable?.trackTimetables {
                    HStack {
                        ForEach(timetables) { timetable in
                            VStack {
                                Text(timetable.track.name.rawValue)
                                ForEach(timetable.proposals) { proposal in
                                    Button(proposal.title, action: {
                                        viewStore.send(.clickProposal(proposal))
                                    })
                                }
                            }
                        }
                    }
                } else {
                    EmptyView()
                }
                HStack {
                    Spacer()
                    if let proposal = viewStore.selectedProposal {
                        ProposalView(proposal: proposal).frame(width: 300)
                    }
                    
                }
            }
            
        }
    }
}


struct DayTimetableView_Previews: PreviewProvider {
    static var previews: some View {
        DayTimetableView(
            store: Store(
                initialState: DayTimetableState(selectedProposal: nil, dayTimetable: MockData.shared.dayTimetable),
                reducer: dayTimetableReducer,
                environment: DayTimetableEnvironment()
            )
        )
    }
}
