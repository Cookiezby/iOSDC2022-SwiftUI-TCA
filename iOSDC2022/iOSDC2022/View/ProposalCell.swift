import SwiftUI

struct ProposalCell: View {
    var proposal: Proposal
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(proposal.timeRangeText)
                    .foregroundColor(Color.white)
                    .font(Font.system(size: 12, weight: .semibold))
                Spacer(minLength: 0)
            }
            .frame(height: 15)
            .padding(.leading, 12)
            .padding(.top, 8)
            VStack(spacing: 0){
                HStack(alignment: .top){
                    Group {
                        if let avatarURL = proposal.speaker.avatarURL,
                            let url = URL(string: avatarURL){
                            AsyncImage(url: url, content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                },
                            placeholder: {
                                EmptyView()
                            })
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 30, height: 30)
                    .padding(.leading, 10)
                    .padding(.top, 5)
                    
                    Text(proposal.title)
                        .lineLimit(2)
                        .lineSpacing(2)
                        .font(Font.system(size: 13, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                }
                Spacer()
            }
            Spacer()
        }
        .background(background())
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder func background() -> some View {
        if proposal.isFinished {
            Color.gray
        } else {
            proposal.track.background
        }
    }
}

struct ProposalCell_Previews: PreviewProvider {
    static var previews: some View {
        ProposalCell(proposal: MockData.shared.proposal)
            .frame(width: 200, height: 70)
            .previewLayout(.sizeThatFits)
    }
}
