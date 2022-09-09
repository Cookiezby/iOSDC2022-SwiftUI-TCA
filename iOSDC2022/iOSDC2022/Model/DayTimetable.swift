import Foundation

// MARK: DayTimetable
struct DayTimetable: Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var tracks: [TrackTimetable]
    
    mutating func update() {
        self.tracks = tracks.map {
            let total = $0.proposals + $0.finished
            let proposals = total.filter { !$0.isFinished }
            let finished = total.filter {$0.isFinished }
            return TrackTimetable(track: $0.track, proposals: proposals, finished: finished)
        }
    }
}
