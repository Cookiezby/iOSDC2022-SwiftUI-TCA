//
//  ProposalView.swift
//  iOSDC2022
//
//  Created by 朱冰一 on 2022/08/23.
//

import SwiftUI

struct ProposalView: View {
    var proposal: Proposal
    var body: some View {
        ScrollView {
            Text(proposal.abstract)
        }.background(Color.white)
        
    }
}

//struct ProposalView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProposalView()
//    }
//}
