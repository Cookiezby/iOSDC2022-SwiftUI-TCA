import Foundation
import ComposableArchitecture
import Combine

enum APIClientError: Error {
    case invalidURL
    case invalieResponse(String)
    case unknow
}

final class APIClient {
    var getTimetable: (Int) async throws -> Timetable = { _ in
        let url = URL(string: "https://fortee.jp/iosdc-japan-2022/api/timetable")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(Timetable.self, from: data)
        return response
    }
}
