import SwiftUI
import ComposableArchitecture

struct ProposalState: Equatable {
    var schedule: Schedule
}

enum ProposalAction {
    case clickProposal(proposal: Proposal)
    case addToSchedule(proposal: Proposal)
    case removeFromSchedule(proposal: Proposal)
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
                    .font(Font.system(size: 18, weight: .bold))
                    .padding(.bottom, 5)
                HStack {
                    if let avatarUrl = proposal.speaker.avatarURL, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url, content: { image in
                                image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        },
                        placeholder: {
                            Circle()
                        }).frame(width: 30, height: 30)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: 40, height: 40)
                    }
                    Text(proposal.speaker.name)
//
//
//                    Link(destination: URL(string: "https://www.apple.com")!) {
//                        Image("TwitterIcon")
//                            .resizable()
//                    }
//                    .frame(width: 30, height: 30)
//                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: true) {
                    Text(proposal.abstract)
                        .font(Font.system(size: 15))
                        .lineSpacing(3)
                }
                .padding(.bottom, 10)
                Spacer()
                #if os(macOS)
                if !viewStore.schedule.overlapped(proposal: proposal).isEmpty {
                    ZStack {
                        Color(hex: 0xF2F2F2)
                            .cornerRadius(5)
                        VStack(alignment: .leading){
                            Text("スケジュールと被ったトーク")
                                .foregroundColor(Color(hex: 0xA5A3A3))
                                .font(Font.system(size: 11, weight: .bold))
                            HStack {
                                ScrollView(.horizontal) {
                                    ForEach(viewStore.schedule.overlapped(proposal: proposal)) { overlapped in
                                        Button(action: {
                                            viewStore.send(.clickProposal(proposal: overlapped))
                                        }, label: {
                                            ProposalCell(proposal: overlapped)
                                                .frame(width: 250, height: 80)
                                        })
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                               
                            }
                        }
                        .padding()
                    }
                    .frame(height: 100)
                    .padding(.bottom, 20)
                }
                #elseif os(iOS)
                
                #endif
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
            .background(Color.white)
            .toolbar {
                Spacer()
                if viewStore.schedule.contains(proposal: proposal) {
                    Button {
                        viewStore.send(.removeFromSchedule(proposal: proposal))
                    } label: {
                        Text("スケジュールから削除")
                            .foregroundColor(Color.white)
                            .font(Font.system(size: 11, weight: .bold))
                           
                    }
                    .background(Color(hex:0xF96464))
                    .cornerRadius(3)
                    .padding(.trailing, 10)
                } else {
                    Button {
                        viewStore.send(.addToSchedule(proposal: proposal))
                    } label: {
                        Text("スケジュールに追加")
                            .foregroundColor(Color(hex: 0x4A4A4A))
                            .font(Font.system(size: 11, weight: .bold))
    
                    }
                    .background(Color(hex:0xD9D9D9))
                    .cornerRadius(3)
                    .padding(.trailing, 10)
                }
            }
        }
    }
}


struct ProposalView_Previews: PreviewProvider {
    static var previews: some View {
        ProposalView(proposal: MockData.shared.proposal, store: Store(initialState: ProposalState(schedule: Schedule()), reducer: proposalReducer, environment: ProposalEnvironment()))
    }
}
