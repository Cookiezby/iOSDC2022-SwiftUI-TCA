import Foundation

// MARK: Proposal
struct Proposal: Equatable, Identifiable, Codable {
    var id: String { uuid }
    var uuid: String
    var url: String?
    var title: String
    var abstract: String
    var track: Track
    var startsDate: Date
    var lengthMin: Int
    var tags: [Tag]?
    var speaker: Speaker
    var timeRangeText: String
    var isFinished: Bool {
        startsDate.timeIntervalSince1970 + Double(lengthMin) * 60 < Date().timeIntervalSince1970
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = .current
        formatter.dateFormat = "a HH:mm"
        return formatter
    }()
    
    static func genTimeRangeText(startsDate: Date, lengthMin: Int) -> String {
        let start = dateFormatter.string(from: startsDate)
        let endDate = Calendar.current.date(byAdding: .minute, value: lengthMin, to: startsDate)!
        let end = dateFormatter.string(from: endDate)
        return "\(start) ~ \(end)"
    }
}

extension Proposal: Comparable {
    static func < (lhs: Proposal, rhs: Proposal) -> Bool {
        lhs.startsDate < rhs.startsDate
    }
}

extension Proposal: Hashable {
    static func == (lhs: Proposal, rhs: Proposal) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

extension Proposal {
    func overlay(proposal: Proposal) -> Bool {
        guard proposal.id != id else { return false }
        let start = startsDate.timeIntervalSince1970
        let end = start + Double(lengthMin * 60)
        let proposalStart = proposal.startsDate.timeIntervalSince1970
        let proposalEnd = proposalStart + Double(proposal.lengthMin * 60)
        return !(proposalEnd <= start || proposalStart >= end)
    }
}
