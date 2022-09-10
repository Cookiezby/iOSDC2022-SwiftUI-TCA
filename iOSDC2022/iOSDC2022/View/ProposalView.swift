import SwiftUI
import ComposableArchitecture

struct ProposalState: Equatable {
    var schedule: Schedule
}

enum ProposalAction {
    case clickProposal(Proposal)
    case addToSchedule(Proposal)
    case removeFromSchedule(Proposal)
}

struct ProposalEnvironment {}

let proposalReducer: Reducer<ProposalState, ProposalAction, ProposalEnvironment> = .init{ state, action, environment in
    switch action {
    case .clickProposal(let proposal):
        return .none
    case .addToSchedule(let proposal):
        state.schedule.add(proposal: proposal)
        return .none
    case .removeFromSchedule(let proposal):
        state.schedule.remove(proposal: proposal)
        return .none
    }
}

struct ProposalView: View {
    var proposal: Proposal
    var store: Store<ProposalState, ProposalAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: 8){
                HStack {
                    Text(proposal.track.name.rawValue)
                    Text(proposal.timeRangeText)
                    Spacer()
                }
                .font(Font.system(size: 13))
                Text(proposal.title)
                    .font(Font.system(size: 20, weight: .bold))
                    .lineSpacing(2)
                    .padding(.bottom, 5)
                Divider()
                HStack {
                    AvatarView(urlString: proposal.speaker.avatarURL, tintColor: Color.gray)
                        .frame(width: 40, height: 40)
                    Text(proposal.speaker.name)
                        .font(Font.system(size: 15))
                        .padding(.leading, 4)
                    Spacer(minLength: 0)
                }
                .padding(.bottom, 10)
                ScrollView(showsIndicators: true) {
                    HStack {
                        Text(proposal.abstract)
                            .font(Font.system(size: 16))
                            .lineSpacing(4)
                        Spacer(minLength: 0)
                    }.frame(maxWidth: .infinity)
                }
                #if os(macOS)
                .padding(.bottom, 10)
                #endif
                Spacer(minLength: 0)
                if let overlapped = viewStore.schedule.overlapped(proposal: proposal), !overlapped.isEmpty {
                    ProposalScheduleOverlapView(overlapped: overlapped, store: store)
                }
            }
            #if os(macOS)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
            #elseif os(iOS)
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
            #endif
            .background(Color.white)
            .toolbar {
                #if os(macOS)
                Spacer(minLength: 0)
                #endif
                ProposalToolbar(
                    proposal: proposal,
                    store: store,
                    fontSize: 12,
                    buttonType: viewStore.schedule.contains(proposal) ? .remove : .add
                )
            }
        }
        
    }
}

struct ProposalScheduleOverlapView: View {
    var overlapped: [Proposal]
    var store: Store<ProposalState, ProposalAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                Color(hex: 0xF2F2F2)
                    .cornerRadius(5)
                VStack(alignment: .leading, spacing: 0){
                    Text("スケジュールと被ったトーク")
                        .foregroundColor(Color(hex: 0xA5A3A3))
                        .font(Font.system(size: 12, weight: .bold))
                        .padding(.bottom, 5)
                    HStack {
                        ScrollView(.horizontal) {
                            ForEach(overlapped) { proposal in
                                Button(action: {
                                    viewStore.send(.clickProposal(proposal))
                                }, label: {
                                    ProposalCell(proposal: proposal)
                                        .frame(width: 250, height: 80)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(height: 100)
            .padding(.bottom, 20)
        }
    }
}

enum ProposalScheduleButtonType {
    case add
    case remove
    
    var buttonTitle: String {
        switch self {
        case .add:      return "スケジュールに追加"
        case .remove:   return "スケジュールから削除"
        }
    }
    
    var buttonBackgroundColor: Color {
        switch self {
        case .add:      return Color(hex:0xD9D9D9)
        case .remove:   return Color(hex:0xF96464)
        }
    }
    
    var buttonTitleColor: Color {
        switch self {
        case .add:      return Color(hex: 0x4A4A4A)
        case .remove:   return Color.white
        }
    }
}

struct ProposalToolbar: View {
    var proposal: Proposal
    var store: Store<ProposalState, ProposalAction>
    var fontSize: CGFloat
    var buttonType: ProposalScheduleButtonType
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Button {
                switch buttonType {
                case .add:    viewStore.send(.addToSchedule(proposal))
                case .remove: viewStore.send(.removeFromSchedule(proposal))
                }
            } label: {
                Text(buttonType.buttonTitle)
                    .foregroundColor(buttonType.buttonTitleColor)
                    .font(Font.system(size: fontSize, weight: .bold))
                    #if os(macOS)
                    .padding(2)
                    #elseif os(iOS)
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 8))
                    #endif
            }
            .background(buttonType.buttonBackgroundColor)
            .cornerRadius(4)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}


struct ProposalView_Previews: PreviewProvider {
    static var previews: some View {
        ProposalView(
            proposal: MockData.shared.proposal,
            store: Store(
                initialState: ProposalState(schedule: Schedule()),
                reducer: proposalReducer,
                environment: ProposalEnvironment()
            )
        )
    }
}
