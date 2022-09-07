import Foundation
import ComposableArchitecture
import Combine

class APIClient {
    var getTimetable: @Sendable (Int) async throws -> Timetable = { _ in
        let url = URL(string: "https://fortee.jp/iosdc-japan-2022/api/timetable")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(Timetable.self, from: data)
        return response
    }
}
