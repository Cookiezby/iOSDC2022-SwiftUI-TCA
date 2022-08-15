import Foundation

enum APIClientError: Error {
    case invalidURL
    case unknow
}

final class APIClient {
    func getAllTimetables() async throws -> Result<[TimetableElement], APIClientError> {
        guard let url = URL(string: "https://fortee.jp/iosdc-japan-2022/api/timetable") else {
            throw APIClientError.invalidURL
        }
        do {
            let (data, httpResponse) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(Timetable.self, from: data)
            print(response)
            return .success(response.timetable)
        } catch {
            print(error)
            return .failure(.unknow)
        }
    }
    
}
