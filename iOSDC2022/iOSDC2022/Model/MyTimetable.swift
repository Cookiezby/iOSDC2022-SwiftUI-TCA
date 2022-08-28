import Foundation

enum LocalDataKey: String {
    case myTimetable
}

struct LocalData {
    private let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let shared = LocalData()
    var myTimetable: MyTimetable
    private init() {
        let path = fileURL.appending(components: LocalDataKey.myTimetable.rawValue)
        if FileManager.default.fileExists(atPath: path.absoluteString) {
            let data = try! Data(contentsOf: path)
            self.myTimetable = try! JSONDecoder().decode(MyTimetable.self, from: data)
        } else {
            self.myTimetable = MyTimetable()
            let data = try! JSONEncoder().encode(self.myTimetable)
            try! data.write(to: path)
        }
    }
    
    func save() {
        let path = fileURL.appending(components: LocalDataKey.myTimetable.rawValue)
        let data = try! JSONEncoder().encode(self.myTimetable)
        try! data.write(to: path)
    }
}

struct MyTimetable: Codable, Equatable {
    var dayTimetables: [MyDayTimetable] = []
}

struct MyDayTimetable: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var proposals: [Proposal]
}
