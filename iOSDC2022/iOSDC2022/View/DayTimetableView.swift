import SwiftUI
import ComposableArchitecture
import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct DayTimetableState: Equatable {
    var dayTimetable: DayTimetable
}
 
extension DayTimetableState: Identifiable {
    var id: Double {
        dayTimetable.id
    }
}

enum DayTimetableAction: Equatable {
    case clickProposal(Proposal)
}

struct DayTimetableEnvironment: Equatable {}

let dayTimetableReducer = Reducer<DayTimetableState, DayTimetableAction, DayTimetableEnvironment>.init { state, action, environement in
    switch action {
    case .clickProposal:
        return .none
    }
}

struct DayTimetableView: View {
    let store:Store<DayTimetableState, DayTimetableAction>
    var body: some View {
#if os(macOS)
        HStack(spacing: 0) {
            TrackView(store: store)
        }
        .padding(.leading, 5)
        .padding(.trailing, 5)
        .background(Color.white)
#elseif os(iOS)
        MobileDayTimetableView(content: { TrackView(store: store)})
#endif
    }

#if os(iOS)
    @ViewBuilder
    func MobileDayTimetableView<Content>(content: @escaping () -> Content) -> some View where Content: View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView {
                content()
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            .tabViewStyle(PageTabViewStyle())
        } else {
            HStack {
                content()
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
        }
    }
#endif
}

struct TrackView: View {
    var store: Store<DayTimetableState, DayTimetableAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ForEach(viewStore.dayTimetable.trackTimetables) { timetable in
                VStack(spacing: 0){
                    HStack {
                        Text(timetable.track.name.displayName)
                            .font(Font.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 8)
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 10) {
                            ForEach(Array(timetable.proposals.enumerated()), id: \.offset) { index, proposal in
                                Button(action: {
                                    viewStore.send(.clickProposal(proposal))
                                }, label: {
                                    ProposalCell(proposal: proposal)
                                        .frame(height: 80)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                            FinishedProposalView(store: store, proposals: timetable.finished)
                        }
                    }
                }
            }
            .padding(.leading, 5)
            .padding(.trailing, 5)
        }
    }
}

struct FinishedProposalView: View {
    var store: Store<DayTimetableState, DayTimetableAction>
    var proposals: [Proposal]
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                HStack {
                    Text("終了したトーク")
                        .font(Font.system(size: 12, weight: .bold))
                        .foregroundColor(Color.gray)
                        .padding(.leading, 3)
                    Spacer()
                }
                Divider()
            }.opacity(proposals.count > 0 ? 1:0)
            ForEach(Array(proposals.enumerated()), id: \.offset) { index, proposal in
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
