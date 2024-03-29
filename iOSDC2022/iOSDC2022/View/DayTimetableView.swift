import SwiftUI
import ComposableArchitecture
import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct DayTimetableState: Equatable, Identifiable {
    var id = UUID()
    var dayTimetable: DayTimetable
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
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
            .navigationBarTitleDisplayMode(.inline)
#endif
    }
    

#if os(iOS)
    @ViewBuilder
    func MobileDayTimetableView<Content>(content: @escaping () -> Content) -> some View where Content: View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView {
                content()
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
            }
            .tabViewStyle(PageTabViewStyle())
        } else {
            HStack(spacing: 0){
                content()
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
            ForEach(viewStore.dayTimetable.tracks) { timetable in
                VStack(spacing: 0){
                    HStack {
                        Text(timetable.track.name.displayName)
                            .padding(.leading, 5)
                            .font(Font.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.gray)
                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 8)
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 10) {
                            ForEach(Array(timetable.pendingProposals.enumerated()), id: \.offset) { index, proposal in
                                Button(action: {
                                    viewStore.send(.clickProposal(proposal))
                                }, label: {
                                    ProposalCell(proposal: proposal)
                                        .frame(height: 80)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                            FinishedProposalView(store: store, proposals: timetable.expiredProposals)
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
                .padding(.top, 10)
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
