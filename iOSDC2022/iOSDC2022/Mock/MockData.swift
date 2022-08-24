import Foundation

class MockData {
    static let shared = MockData()
    var timetable: Timetable
    var dayTimetable: DayTimetable
    var trackTimetable: TrackTimetable
    var proposal: Proposal
    
    
    init() {
        let path = Bundle.main.path(forResource: "timetable", ofType: "json")
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!))
        let timetable = try! JSONDecoder().decode(Timetable.self, from: jsonData)
        self.timetable = timetable
        self.dayTimetable = timetable.extractDayTimetables().first!
        self.trackTimetable = self.dayTimetable.trackTimetables.first!
        self.proposal = self.trackTimetable.proposals.first!
    }
}
