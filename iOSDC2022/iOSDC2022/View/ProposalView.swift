import SwiftUI
import ComposableArchitecture

struct ProposalState: Equatable {
    var myTimetable: MyTimetable
}

enum ProposalAction {
    case saveToMyTimetable(proposal: Proposal)
    case removeFromMyTimetable(proposal: Proposal)
}

struct ProposalEnvironment {}


let proposalReducer: Reducer<ProposalState, ProposalAction, ProposalEnvironment> = .init{ state, action, environment in
    switch action {
    case .saveToMyTimetable(let proposal):
        state.myTimetable.add(proposal: proposal)
        return .none
    case .removeFromMyTimetable(let proposal):
        state.myTimetable.remove(proposal: proposal)
        return .none
    }
}

struct ProposalView: View {
    var proposal: Proposal
    var store: Store<ProposalState, ProposalAction>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading){
                HStack {
                    if let avatarUrl = proposal.speaker.avatarURL, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url, content: { image in
                                image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                        },
                        placeholder: {
                            Circle()
                        }).frame(width: 40, height: 40)
                    }
                    Text(proposal.speaker.name)
                    Spacer()
                    Link(destination: URL(string: "https://www.apple.com")!) {
                        Image("TwitterIcon")
                            .resizable()
                    }
                    .frame(width: 30, height: 30)
                    .buttonStyle(PlainButtonStyle())

                }
                Text(proposal.title)
                    .font(Font.system(size: 20, weight: .bold))
                ScrollView {
                    Text(proposal.abstract)
                        .font(Font.system(size: 15))
                        .lineSpacing(2)
                }
                Spacer()
                HStack {
                    Spacer()
                    if viewStore.myTimetable.contains(proposal: proposal) {
                        Button {
                            viewStore.send(.removeFromMyTimetable(proposal: proposal))
                        } label: {
                            Text("リストから削除")
                        }
                    } else {
                        Button {
                            viewStore.send(.saveToMyTimetable(proposal: proposal))
                        } label: {
                            Text("リストに追加")
                        }
                    }
                }
            }
            .padding(5)
            .background(Color.white)
            .toolbar {
                EmptyView()
            }
        }
        
    }
}

struct ProposalView_Previews: PreviewProvider {
    static var previews: some View {
        ProposalView(proposal: MockData.shared.proposal, store: Store(initialState: ProposalState(myTimetable: MyTimetable()), reducer: proposalReducer, environment: ProposalEnvironment()))
    }
}
