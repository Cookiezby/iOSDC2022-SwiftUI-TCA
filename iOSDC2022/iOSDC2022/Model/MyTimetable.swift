import Foundation

//enum LocalDataKey: String {
//    case myTimetable
//}

//struct LocalData {
//    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let shared = LocalData()
//    var myTimetable: MyTimetable
//    private init() {
//        let path = fileURL.appending(components: LocalDataKey.myTimetable.rawValue)
//        if FileManager.default.fileExists(atPath: path.absoluteString) {
//            let data = try! Data(contentsOf: path)
//            self.myTimetable = try! JSONDecoder().decode(MyTimetable.self, from: data)
//        } else {
//            self.myTimetable = MyTimetable()
//            let data = try! JSONEncoder().encode(self.myTimetable)
//            try! data.write(to: path)
//        }
//    }
//
//    func save() {
//        let path = fileURL.appending(components: LocalDataKey.myTimetable.rawValue)
//        let data = try! JSONEncoder().encode(self.myTimetable)
//        try! data.write(to: path)
//    }
//}

struct MyTimetable: Codable, Equatable {
    static func == (lhs: MyTimetable, rhs: MyTimetable) -> Bool {
        lhs.dayTimetables == rhs.dayTimetables
    }
    
    var dayTimetables: [MyDayTimetable]
    
    init() {
        self.dayTimetables = []
    }
    
    mutating func add(proposal: Proposal) {
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let index = dayTimetables.firstIndex(where: {$0.date == startDate }) {
            dayTimetables[index].proposals.insert(proposal)
        } else {
            dayTimetables.append(MyDayTimetable(date: startDate, proposals: [proposal]))
        }
    }
    
    mutating func remove(proposal: Proposal) {
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let index = dayTimetables.firstIndex(where: {$0.date == startDate }) {
            dayTimetables[index].proposals.remove(proposal)
        }
    }
}

struct MyDayTimetable: Codable, Equatable, Identifiable {
    let id: UUID
    var date: Date
    var proposals: Set<Proposal>
    
    init(date: Date, proposals: [Proposal]) {
        self.date = date
        self.id = UUID()
        self.proposals = Set(proposals)
    }
    
    static func == (lhs: MyDayTimetable, rhs: MyDayTimetable) -> Bool {
        lhs.proposals == rhs.proposals
    }
}

extension MyTimetable {
    func contains(proposal: Proposal) -> Bool {
        for dayTimetable in dayTimetables {
            if dayTimetable.proposals.first(where: { $0.id == proposal.id }) != nil {
                return true
            }
        }
        return false
    }
}
