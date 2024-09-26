import SwiftUI
import Combine

struct DomainListView: View {
    @EnvironmentObject var viewModel: DomainViewModel
    @State private var showingAddDomain = false
    
    var body: some View {
        List(viewModel.domains) { domain in
            NavigationLink(destination: DomainDetailView(domain: domain)) {
                Text(domain.name)
            }
        }
        .navigationTitle("Domains")
        .toolbar {
            Button(action: { showingAddDomain = true }) {
                Image(systemName: "plus")
            }
        }
        .onAppear {
            viewModel.fetchDomains()
        }
        .sheet(isPresented: $showingAddDomain) {
            // Implement AddDomainView here
        }
    }
}

struct DomainDetailView: View {
    let domain: Domain
    @EnvironmentObject var viewModel: DomainViewModel
    
    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Status", value: domain.status)
                LabeledContent("Type", value: domain.type)
            }
            
            Section {
                NavigationLink(destination: DNSView(domain: domain)) {
                    Label("Manage DNS Records", systemImage: "server.rack")
                }
            }
        }
        .navigationTitle(domain.name)
    }
}

class DomainViewModel: ObservableObject {
    @Published var domains: [Domain] = []
    @Published var dnsRecords: [DNSRecord] = []
    private var cloudflareClient: CloudflareClient
    private var cancellables = Set<AnyCancellable>()
    
    init(cloudflareClient: CloudflareClient) {
        self.cloudflareClient = cloudflareClient
    }
    
    func fetchDomains() {
        cloudflareClient.fetchDomains()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching domains: \(error)")
                    }
                },
                receiveValue: { [weak self] domains in
                    self?.domains = domains
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchDNSRecords(for domain: Domain) {
        cloudflareClient.fetchDNSRecords(for: domain)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching DNS records: \(error)")
                    }
                },
                receiveValue: { [weak self] records in
                    self?.dnsRecords = records
                }
            )
            .store(in: &cancellables)
    }
    
    func addDNSRecord(to domain: Domain, name: String, type: String, content: String, ttl: Int) {
        cloudflareClient.addDNSRecord(to: domain, name: name, type: type, content: content, ttl: ttl)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error adding DNS record: \(error)")
                    }
                },
                receiveValue: { [weak self] newRecord in
                    self?.dnsRecords.append(newRecord)
                }
            )
            .store(in: &cancellables)
    }
    
    func updateDNSRecord(_ record: DNSRecord, in domain: Domain, name: String, type: String, content: String, ttl: Int) {
        cloudflareClient.updateDNSRecord(record, in: domain, name: name, type: type, content: content, ttl: ttl)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error updating DNS record: \(error)")
                    }
                },
                receiveValue: { [weak self] updatedRecord in
                    if let index = self?.dnsRecords.firstIndex(where: { $0.id == updatedRecord.id }) {
                        self?.dnsRecords[index] = updatedRecord
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteDNSRecord(_ record: DNSRecord, in domain: Domain) {
        cloudflareClient.deleteDNSRecord(record, in: domain)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error deleting DNS record: \(error)")
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        self?.dnsRecords.removeAll { $0.id == record.id }
                    }
                }
            )
            .store(in: &cancellables)
    }
}
