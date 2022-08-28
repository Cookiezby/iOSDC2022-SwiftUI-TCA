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
                    HStack(spacing: 0) {
                        
                        ForEach(timetables) { timetable in
                            VStack(spacing: 0){
                                HStack {
                                    Text(timetable.track.name.displayName)
                                        .font(Font.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.gray)
                                    Spacer()
                                }
                                .padding(.bottom, 8)
                        
                                ScrollView(showsIndicators: false){
                                    VStack(spacing: 10){
                                        ForEach(Array(timetable.proposals.enumerated()), id: \.offset) { index, proposal in
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
                        }
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                } else {
                    EmptyView()
                }
                if let proposal =
                    viewStore.selectedProposal {
                    GeometryReader { geo in
                        ProposalView(proposal: proposal).frame(width: max(geo.size.width * 0.5, 300))
                    }
                    
                }
            }
            .background(Color.white)
        }
    }
    
    func select(proposals: [Proposal], index: Int) {
        print(index)
        ViewStore(self.store).send(.clickProposal(proposals[index]))
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
