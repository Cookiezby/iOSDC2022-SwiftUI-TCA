import Foundation

struct Schedule {
    var daySchedules: [DaySchedule] = []
    var proposalIds = Set<String>()
    
    init() {
        loadLocalData()
    }
    
    mutating func refresh() {
        daySchedules = daySchedules.map{$0.refresh()}
        save()
    }
}

// MARK: DaySchedule
struct DaySchedule: Codable, Equatable, Identifiable {
    let id: UUID
    var date: Date
    var pendingProposals: [Proposal]
    var expiredProposals: [Proposal]
    
    init(date: Date, proposals: [Proposal]) {
        self.date = date
        self.id = UUID()
        self.pendingProposals = []
        self.expiredProposals = []
        
        for proposal in proposals {
            if proposal.isExpired {
                self.expiredProposals.append(proposal)
            } else {
                self.pendingProposals.append(proposal)
            }
        }
    }
    
    static func == (lhs: DaySchedule, rhs: DaySchedule) -> Bool {
        lhs.pendingProposals == rhs.pendingProposals
    }
    
    func refresh() -> DaySchedule {
        let proposals = pendingProposals + expiredProposals
        return DaySchedule(date: date, proposals: proposals)
    }
}

extension Schedule {
    func overlapped(proposal: Proposal) -> [Proposal]? {
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let daySchedule = daySchedules.first(where: {$0.date == startDate}) {
            let proposals = daySchedule.pendingProposals + daySchedule.expiredProposals
            return proposals.filter({$0.overlay(proposal: proposal)})
        }
        return nil
    }
    
    mutating func add(day: Date) {
        daySchedules.append(DaySchedule(date: day, proposals: []))
        save()
    }
    
    mutating func add(proposal: Proposal) {
        overlapped(proposal: proposal)?.forEach {
            remove(proposal: $0)
        }
        
        proposalIds.insert(proposal.uuid)
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let index = daySchedules.firstIndex(where: {$0.date == startDate }) {
            if proposal.isExpired {
                daySchedules[index].expiredProposals.append(proposal)
                daySchedules[index].expiredProposals = daySchedules[index].pendingProposals.sorted()
            } else {
                daySchedules[index].pendingProposals.append(proposal)
                daySchedules[index].pendingProposals = daySchedules[index].pendingProposals.sorted()
            }
        } else {
            daySchedules.append(DaySchedule(date: startDate, proposals: [proposal]))
        }
        save()
    }
    
    mutating func remove(proposal: Proposal) {
        proposalIds.remove(proposal.uuid)
        let startDate = Calendar.current.startOfDay(for: proposal.startsDate)
        if let index = daySchedules.firstIndex(where: {$0.date == startDate }) {
            if proposal.isExpired {
                daySchedules[index].expiredProposals = daySchedules[index].expiredProposals.filter {
                    $0.uuid != proposal.uuid
                }
            } else {
                daySchedules[index].pendingProposals = daySchedules[index].pendingProposals.filter {
                    $0.uuid != proposal.uuid
                }
            }
        }
        save()
    }
}

extension Schedule {
    func contains(_ proposal: Proposal) -> Bool {
        proposalIds.contains(proposal.uuid)
    }
}

extension Schedule: Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.daySchedules == rhs.daySchedules
    }
}

// MARK: Scheule Persist
extension Schedule {
    private func getLocalDataPath() -> String {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathComponent = fileURL.appendingPathComponent("schedule")
        return pathComponent.path(percentEncoded: true)
    }
    
    mutating private func loadLocalData() {
        let path = getLocalDataPath()
        if FileManager.default.fileExists(atPath: path) {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            self.daySchedules = try! JSONDecoder().decode([DaySchedule].self, from: data)
            self.daySchedules = self.daySchedules.map { $0.refresh() }
            for day in daySchedules {
                for proposal in day.pendingProposals {
                    self.proposalIds.insert(proposal.uuid)
                }
                
                for proposal in day.expiredProposals {
                    self.proposalIds.insert(proposal.uuid)
                }
            }
        }
    }
    
    private func save() {
        let path = getLocalDataPath()
        let data = try! JSONEncoder().encode(daySchedules)
        try? data.write(to: URL(fileURLWithPath: path))
    }
}
