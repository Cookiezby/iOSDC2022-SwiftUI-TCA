//
//  DayTimetableProposalView.swift
//  iOSDC2022
//
//  Created by 朱冰一 on 2022/08/24.
//

import SwiftUI

struct DayTimetableProposalView: View {
    var proposal: Proposal
    var body: some View {
        Text(proposal.title)
    }
}

struct DayTimetableProposalView_Previews: PreviewProvider {
    static var previews: some View {
        DayTimetableProposalView(proposal: MockData.shared.proposal)
    }
}
