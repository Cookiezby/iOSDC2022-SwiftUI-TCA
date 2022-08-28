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
                Text("午前10:50 ~ 午前11:50")
                Spacer()
            }
            .frame(height: 15)
            .font(Font.system(size: 11))
            .foregroundColor(Color.white)
            .padding(.leading, 5)
            .padding(.top, 5)
            VStack(spacing: 0){
                HStack(alignment: .top){
                    if let avatarURL = proposal.speaker.avatarURL, let url = URL(string: avatarURL){
                        AsyncImage(url: url, content: { image in
                                image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                                
                        },
                        placeholder: {
                            Circle().background(Color.clear)
                        })
                        .frame(width: 20, height: 20)
                        .padding(.leading, 5)
                       
                    }
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
        .background(proposal.track.background)
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ProposalCell_Previews: PreviewProvider {
    static var previews: some View {
        ProposalCell(proposal: MockData.shared.proposal)
            .frame(width: 200, height: 70)
            .previewLayout(.sizeThatFits)
    }
}
