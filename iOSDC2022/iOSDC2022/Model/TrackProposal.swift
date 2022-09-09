import Foundation

// MARK: TrackProposal
struct TrackProposal: Equatable, Identifiable {
    var id = UUID()
    var track: Track
    var pendingProposals: [Proposal]
    var expiredProposals: [Proposal]
    
    init(track: Track, proposals: [Proposal]) {
        self.track = track
        self.pendingProposals = []
        self.expiredProposals = []
        for proposal in proposals {
            if proposal.isExpired {
                expiredProposals.append(proposal)
            } else {
                pendingProposals.append(proposal)
            }
        }
    }
}
