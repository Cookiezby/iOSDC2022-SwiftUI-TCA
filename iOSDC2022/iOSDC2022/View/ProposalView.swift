import SwiftUI

struct ProposalView: View {
    var proposal: Proposal
    var body: some View {
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
                Button {
                    
                } label: {
                    Text("リストに追加")
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

struct ProposalView_Previews: PreviewProvider {
    static var previews: some View {
        ProposalView(proposal: MockData.shared.proposal)
    }
}
