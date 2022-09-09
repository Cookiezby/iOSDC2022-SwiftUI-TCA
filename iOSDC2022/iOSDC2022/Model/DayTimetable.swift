import Foundation

// MARK: DayTimetable
struct DayTimetable: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var tracks: [TrackProposal]
    
    mutating func update() {
        self.tracks = tracks.map {
            let proposals = $0.pendingProposals + $0.expiredProposals
            return TrackProposal(track: $0.track, proposals: proposals)
        }
    }
}

extension DayTimetable: Comparable {
    static func < (lhs: DayTimetable, rhs: DayTimetable) -> Bool {
        lhs.date < rhs.date
    }
}
