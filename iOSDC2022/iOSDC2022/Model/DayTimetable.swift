import Foundation

// MARK: DayTimetable
struct DayTimetable: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var tracks: [TrackProposal]
    
    /// Update each track's proposal, separte them to pending and expired proposal
    func refresh() -> DayTimetable {
        let updatedTrack = tracks.map {
             TrackProposal(track: $0.track, proposals: $0.pendingProposals + $0.expiredProposals)
        }
        return DayTimetable(date: date, tracks: updatedTrack)
    }
}

extension DayTimetable: Comparable {
    static func < (lhs: DayTimetable, rhs: DayTimetable) -> Bool {
        lhs.date < rhs.date
    }
}
