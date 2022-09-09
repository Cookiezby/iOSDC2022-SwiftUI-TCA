import Foundation

final class MockData {
    static let shared = MockData()
    var timetable: Timetable
    var dayTimetable: DayTimetable
    var days: [Date]
    var trackTimetable: TrackProposal
    var proposal: Proposal {
        trackTimetable.pendingProposals.first!
    }
    
    
    init() {
        let path = Bundle.main.path(forResource: "timetable", ofType: "json")
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        let timetable = try! JSONDecoder().decode(Timetable.self, from: jsonData)
        self.timetable = timetable
        let dayTimetables = timetable.extractDayTimetables()
        self.dayTimetable = dayTimetables.first!
        self.trackTimetable = self.dayTimetable.tracks.first!
        self.days = dayTimetables.map { $0.date }
        //self.proposal = self.trackTimetable.proposals.first!
    }
}
