import Foundation

// MARK: TrackTimetable
struct TrackTimetable: Equatable, Identifiable {
    var id = UUID()
    var track: Track
    var proposals: [Proposal]
    var finished: [Proposal]
}
