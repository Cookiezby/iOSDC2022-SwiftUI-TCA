//
//  ProposalCell.swift
//  iOSDC2022
//
//  Created by 朱冰一 on 2022/08/26.
//

import SwiftUI

struct ProposalCell: View {
    var proposal: Proposal
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text(proposal.track.name.rawValue)
                Text("午前10:50 ~ 午前11:50")
                Spacer()
            }
            .foregroundColor(Color.white)
            HStack {
                if let avatarURL = proposal.speaker.avatarURL, let url = URL(string: avatarURL){
                    AsyncImage(url: url, content: { image in
                            image.aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                            
                    },
                    placeholder: {
                        Circle()
                    }).frame(width: 20, height: 20)
 
                }
                Text(proposal.title)
                    .font(Font.system(size: 15, weight: .bold))
                    .foregroundColor(Color.white)
            }
            .frame(height: 50)
            Spacer()
        }
        .padding(5)
        .frame(width: 300, height: 90)
        .background(proposal.track.background)
    }
}

struct ProposalCell_Previews: PreviewProvider {
    static var previews: some View {
        ProposalCell(proposal: MockData.shared.proposal)
    }
}
