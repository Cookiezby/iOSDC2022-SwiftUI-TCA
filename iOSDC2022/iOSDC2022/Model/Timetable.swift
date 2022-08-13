// Generated by https://quicktype.io

import Foundation

struct Timetable: Codable {
    let timetable: [TimetableElement]
}

struct TimetableElement: Codable {
    let type: TimetableType
    let uuid: String
    let url: String?
    let title: String
    let abstract: String?
    let accepted: Bool?
    let track: Track?
    let startsAt: Date?
    let lengthMin: Int?
    let tags: [Tag]?
    let speaker: Speaker?
    let favCount: Int?
    let feedback: Feedback?
}

struct Feedback: Codable {
    let feedbackOpen: Bool
}

struct Speaker: Codable {
    let name, kana: String
    let twitter: String?
    let avatarURL: String?
}

struct Tag: Codable {
    let name: String
    let colorText: String
    let colorBackground: String
}

struct Track: Codable {
    let name: TrackName
    let sort: Int
}

enum TrackName: Codable {
    case trackA
    case trackB
    case trackC
    case trackD
    case trackE
}

enum TimetableType: Codable {
    case talk
    case timeslot
}

