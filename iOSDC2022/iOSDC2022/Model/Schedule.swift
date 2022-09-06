import Foundation

struct Schedule {
    var daySchedules: [DaySchedule] = []
    var proposalIds = Set<String>()
    
    init() {
        load()
    }
}

extension Schedule {
    func overlapped(proposal: Proposal) -> [Proposal] {
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let daySchedule = daySchedules.first(where: {$0.date == startDate}) {
            return daySchedule.proposals.filter({$0.overlay(proposal: proposal)})
        } else {
            return []
        }
    }
    
    mutating func add(proposal: Proposal) {
        overlapped(proposal: proposal).forEach {
            self.remove(proposal: $0)
        }
        
        proposalIds.insert(proposal.uuid)
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let index = daySchedules.firstIndex(where: {$0.date == startDate }) {
            daySchedules[index].proposals.append(proposal)
            daySchedules[index].proposals = daySchedules[index].proposals.sorted()
        } else {
            daySchedules.append(DaySchedule(date: startDate, proposals: [proposal]))
        }
        save()
    }
    
    mutating func remove(proposal: Proposal) {
        proposalIds.remove(proposal.uuid)
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let index = daySchedules.firstIndex(where: {$0.date == startDate }) {
            daySchedules[index].proposals = daySchedules[index].proposals.filter {
                $0.uuid != proposal.uuid
            }
        }
        save()
    }
    
    mutating func add(day: Date) {
        daySchedules.append(DaySchedule(date: day, proposals: []))
        save()
    }
}

extension Schedule {
    private func getLocalDataPath() -> String {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathComponent = fileURL.appendingPathComponent("schedule")
        return pathComponent.path(percentEncoded: true)
    }
    
    mutating func load() {
        let path = getLocalDataPath()
        if FileManager.default.fileExists(atPath: path) {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            self.daySchedules = try! JSONDecoder().decode([DaySchedule].self, from: data)
            for day in daySchedules {
                for proposal in day.proposals {
                    self.proposalIds.insert(proposal.uuid)
                }
            }
        }
    }
    
    private func save() {
        let path = getLocalDataPath()
        let data = try! JSONEncoder().encode(daySchedules)
        try! data.write(to: URL(fileURLWithPath: path))
    }
}

extension Schedule {
    func contains(proposal: Proposal) -> Bool {
        proposalIds.contains(proposal.uuid)
    }
}

extension Schedule: Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.daySchedules == rhs.daySchedules
    }
}

struct DaySchedule: Codable, Equatable, Identifiable {
    let id: UUID
    var date: Date
    var proposals: [Proposal]
    var finished: [Proposal]
    
    init(date: Date, proposals: [Proposal]) {
        self.date = date
        self.id = UUID()
        self.proposals = proposals
        self.finished = []
    }
    
    static func == (lhs: DaySchedule, rhs: DaySchedule) -> Bool {
        lhs.proposals == rhs.proposals
    }
}

