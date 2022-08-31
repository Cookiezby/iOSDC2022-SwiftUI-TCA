// Generated by https://quicktype.io

import Foundation

struct TrackTimetable: Equatable, Identifiable {
    var id: UUID = UUID()
    var track: Track
    var proposals: [Proposal]
}

struct DayTimetable: Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var trackTimetables: [TrackTimetable]
}

struct Timetable: Codable {
    let timetable: [TimetableElement]
}

extension Timetable {
    func extractDayTimetables() -> [DayTimetable] {
        let dateForamt = ISO8601DateFormatter()
        var proposals: [Proposal] = []
        for element in timetable {
            if let startsAt = element.startsAt,
               element.type == .talk,
               let startsDate = dateForamt.date(from: startsAt),
               let abstract = element.abstract,
               let track = element.track,
               let lengthMin = element.lengthMin,
               let speaker = element.speaker {
                let proposal = Proposal(
                    uuid: element.uuid,
                    title: element.title,
                    abstract: abstract,
                    track: track,
                    startsDate: startsDate,
                    lengthMin: lengthMin,
                    speaker: speaker
                )
                proposals.append(proposal)
            }
        }
        
        proposals.sort(){$0.startsDate < $1.startsDate }
        
        var dic = [Date: [Track: [Proposal]]]()
        var result: [DayTimetable] = []
      
        for element in proposals {
            let startOfDate = Calendar.current.startOfDay(for: element.startsDate)
            var trackDic = dic[startOfDate] ?? [Track: [Proposal]]()
            trackDic[element.track, default: []].append(element)
            dic[startOfDate] = trackDic
        }
        
        for (key, value) in dic {
            let tracks = value.keys.sorted()
            var trackTimetables: [TrackTimetable] = []
            for track in tracks {
                trackTimetables.append(TrackTimetable(track: track, proposals: value[track]!))
            }
            result.append(DayTimetable(date: key, trackTimetables: trackTimetables))
        }
        
        result.sort() {$0.date < $1.date}
        return result
    }
}

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
    
    var timeRangeText: String {
        return ""
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
        }
    }
}

enum TimetableElementType: String, Codable {
    case talk
    case timeslot
}

