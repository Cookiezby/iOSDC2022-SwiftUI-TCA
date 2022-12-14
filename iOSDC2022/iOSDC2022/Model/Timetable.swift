import SwiftUI
import Foundation

struct Timetable: Codable {
    let timetable: [TimetableElement]
}

extension Timetable {
    func extractDayTimetables() -> [DayTimetable] {
        let proposals = timetable.compactMap(Proposal.init).sorted()
        
        var dic = [Date: [Track: [Proposal]]]()
        var dayTimetables: [DayTimetable] = []
      
        for proposal in proposals {
            let startOfDate = Calendar.current.startOfDay(for: proposal.startsDate)
            var dayDic = dic[startOfDate] ?? [Track: [Proposal]]()
            dayDic[proposal.track, default: []].append(proposal)
            dic[startOfDate] = dayDic
        }
        
        for (day, dayDic) in dic {
            let trackProposals = dayDic.keys
                .sorted()
                .map { track in
                TrackProposal(track: track, proposals: dayDic[track] ?? [])
            }
            dayTimetables.append(DayTimetable(date: day, tracks: trackProposals))
        }
        
        return dayTimetables.sorted()
    }
}


struct TimetableElement: Codable, Equatable {
    static func == (lhs: TimetableElement, rhs: TimetableElement) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    let type: TimetableElementType
    let uuid: String
    let url: String?
    let title: String
    let abstract: String?
    let accepted: Bool?
    let track: Track?
    let startsAt: String?
    let lengthMin: Int?
    let tags: [Tag]?
    let speaker: Speaker?
    let favCount: Int?
    let feedback: Feedback?
    
    enum CodingKeys: String, CodingKey {
        case type
        case uuid
        case url
        case title
        case abstract
        case accepted
        case track
        case startsAt = "starts_at"
        case lengthMin = "length_min"
        case tags
        case speaker
        case favCount = "fav_count"
        case feedback
    }
}

struct Feedback: Codable {
    let open: Bool
}

struct Speaker: Codable {
    let name, kana: String
    let twitter: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case kana
        case twitter
        case avatarURL = "avatar_url"
    }
}

struct Tag: Codable {
    let name: String
    let colorText: String
    let colorBackground: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case colorText = "color_text"
        case colorBackground = "color_background"
    }
}


// MARK: Track
struct Track: Codable, Hashable, Comparable {
    static func < (lhs: Track, rhs: Track) -> Bool {
        lhs.sort < rhs.sort
    }
    
    let name: TrackName
    let sort: Int
}

enum TrackName: String, Codable {
    case trackA = "Track A"
    case trackB = "Track B"
    case trackC = "Track C"
    case trackD = "Track D"
    case trackE = "Track E"
    case trackF = "Track F"
    
    var displayName: String {
        switch self {
        case .trackA:
            return "A"
        case .trackB:
            return "B"
        case .trackC:
            return "C"
        case .trackD:
            return "D"
        case .trackE:
            return "E"
        case .trackF:
            return "F"
        }
    }
}

enum TimetableElementType: String, Codable {
    case talk
    case timeslot
}

extension Track {
    var background: LinearGradient {
        LinearGradient(
            gradient: graident,
            startPoint: UnitPoint(x: 0.0, y: 0.5),
            endPoint: UnitPoint(x: 1.0, y: 0.5)
        )
    }
    
    private var graident: Gradient {
        switch self.name {
        case .trackA:
            return Gradient(colors: [Color(hex: 0x02aab0), Color(hex: 0x00cdac)])
        case .trackB:
            return Gradient(colors: [Color(hex: 0xff758c), Color(hex: 0xff7eb3)])
        case .trackC:
            return Gradient(colors: [Color(hex: 0xF76B1C), Color(hex: 0xFEAD3F)])
        case .trackD:
            return Gradient(colors: [Color(hex: 0x56ab2f), Color(hex: 0xa8e063)])
        case .trackE, .trackF:
            return Gradient(colors: [Color(hex: 0xA707DF), Color(hex: 0xC816A1)])
        }
    }
}
