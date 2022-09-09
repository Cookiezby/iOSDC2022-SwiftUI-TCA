import Foundation

// MARK: TrackProposal
struct TrackProposal: Equatable, Identifiable {
    var id = UUID()
    var track: Track
    var pendingProposals: [Proposal]
    var expiredProposals: [Proposal]
}
