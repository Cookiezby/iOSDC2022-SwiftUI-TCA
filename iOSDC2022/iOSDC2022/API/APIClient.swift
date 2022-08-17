import Foundation

enum APIClientError: Error {
    case invalidURL
    case unknow
}

protocol TimetableAPI {
    func getTimetable() async throws -> Result<Timetable, APIClientError>
}

final class APIClient: TimetableAPI {
    private let baseURL = "https://fortee.jp/iosdc-japan-2022/api/"
    
    func getTimetable() async throws -> Result<Timetable, APIClientError> {
        guard let url = URL(string: baseURL + "timetable") else {
            throw APIClientError.invalidURL
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(Timetable.self, from: data)
            return .success(response)
        } catch {
            return .failure(.unknow)
        }
    }
    
}
