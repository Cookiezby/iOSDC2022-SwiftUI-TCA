import SwiftUI
import ComposableArchitecture
import Foundation
#if canImport(UIKit)
import UIKit
#endif

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
#if os(macOS)
            if let timetables = viewStore.dayTimetable?.trackTimetables {
                HStack(spacing: 0) {
                    ForEach(timetables) { timetable in
                        VStack(spacing: 0){
                            HStack {
                                Text(timetable.track.name.displayName)
                                    .font(Font.system(size: 15, weight: .semibold))
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
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                .background(Color.white)
            } else {
                Color.white
            }
#elseif os(iOS)
            if let timetables = viewStore.dayTimetable?.trackTimetables {
                iOSDayTimetableView(
                    usePageTab: UIDevice.current.userInterfaceIdiom == .phone,
                    content: {
                    ForEach(timetables) { timetable in
                        VStack(spacing: 0){
                            HStack {
                                Text(timetable.track.name.displayName)
                                    .font(Font.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color.gray)
                                    .padding(.leading, 3)
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
                })
            } else {
                Color.white
            }
#endif
        }
    }
    
    @ViewBuilder
    func iOSDayTimetableView<Content>(
        usePageTab: Bool,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        if usePageTab {
            TabView {
                content()
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            #if os(iOS)
            .tabViewStyle(PageTabViewStyle())
            #endif
        } else {
            HStack {
                content()
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            }
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
    
    func select(proposals: [Proposal], index: Int) {
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
