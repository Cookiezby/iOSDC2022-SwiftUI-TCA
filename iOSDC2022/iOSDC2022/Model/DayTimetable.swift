import Foundation

// MARK: DayTimetable
struct DayTimetable: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var tracks: [TrackProposal]
    
    mutating func update() {
        self.tracks = tracks.map {
            let total = $0.pendingProposals + $0.expiredProposals
            let proposals = total.filter { !$0.isFinished }
            let finished = total.filter {$0.isFinished }
            return TrackProposal(track: $0.track, pendingProposals: proposals, expiredProposals: finished)
        }
    }
}
