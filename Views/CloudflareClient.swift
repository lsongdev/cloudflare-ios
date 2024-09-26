import Foundation
import Combine

// MARK: - Models

struct Domain: Identifiable, Codable {
    let id: String
    let name: String
    let status: String
    let paused: Bool
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, paused, type
    }
}

struct DNSRecord: Identifiable, Codable {
    let id: String
    let type: String
    let name: String
    let content: String
    let proxiable: Bool
    let proxied: Bool
    let ttl: Int
    let zoneId: String
    let zoneName: String
    let createdOn: String
    let modifiedOn: String
    let locked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, type, name, content, proxiable, proxied, ttl, locked
        case zoneId = "zone_id"
        case zoneName = "zone_name"
        case createdOn = "created_on"
        case modifiedOn = "modified_on"
    }
}

// MARK: - CloudflareClient

class CloudflareClient: ObservableObject {
    @Published var email: String {
        didSet { UserDefaults.standard.set(email, forKey: "email") }
    }
    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "apiKey") }
    }
    
    private let baseURL = "https://api.cloudflare.com/client/v4"
    private let jsonDecoder = JSONDecoder()
    
    init() {
        self.email = UserDefaults.standard.string(forKey: "email") ?? ""
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    }
    
    // MARK: - API Requests
    
    func fetchDomains() -> AnyPublisher<[Domain], Error> {
        return makeRequest("/zones")
            .decodeCloudflareResponse([Domain].self)
    }
    
    func fetchDNSRecords(for domain: Domain) -> AnyPublisher<[DNSRecord], Error> {
        return makeRequest("/zones/\(domain.id)/dns_records")
            .decodeCloudflareResponse([DNSRecord].self)
    }
    
    func addDNSRecord(to domain: Domain, name: String, type: String, content: String, ttl: Int) -> AnyPublisher<DNSRecord, Error> {
        let body: [String: Any] = ["type": type, "name": name, "content": content, "ttl": ttl]
        return makeRequest("/zones/\(domain.id)/dns_records", method: "POST", body: body)
            .decodeCloudflareResponse(DNSRecord.self)
    }
    
    func updateDNSRecord(_ record: DNSRecord, in domain: Domain, name: String, type: String, content: String, ttl: Int) -> AnyPublisher<DNSRecord, Error> {
        let body: [String: Any] = ["type": type, "name": name, "content": content, "ttl": ttl]
        return makeRequest("/zones/\(domain.id)/dns_records/\(record.id)", method: "PUT", body: body)
            .decodeCloudflareResponse(DNSRecord.self)
    }
    
    func deleteDNSRecord(_ record: DNSRecord, in domain: Domain) -> AnyPublisher<Bool, Error> {
            return makeRequest("/zones/\(domain.id)/dns_records/\(record.id)", method: "DELETE")
                .decode(type: CloudflareDeleteResponse.self, decoder: jsonDecoder)
                .map(\.success)
                .eraseToAnyPublisher()
        }
    
    // MARK: - Helper Methods
    
    private func makeRequest(_ endpoint: String, method: String = "GET", body: [String: Any]? = nil) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(email, forHTTPHeaderField: "X-Auth-Email")
        request.addValue(apiKey, forHTTPHeaderField: "X-Auth-Key")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

// MARK: - Response Helpers

struct CloudflareResponse<T: Decodable>: Decodable {
    let result: T
    let success: Bool
}

struct CloudflareDeleteResponse: Decodable {
    let success: Bool
    // 注意：这里没有 result 字段
}

extension Publisher where Output == Data {
    func decodeCloudflareResponse<T: Decodable>(_ type: T.Type) -> AnyPublisher<T, Error> {
        return decode(type: CloudflareResponse<T>.self, decoder: JSONDecoder())
            .map(\.result)
            .eraseToAnyPublisher()
    }
}
