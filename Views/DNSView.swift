import SwiftUI

struct DNSView: View {
    let domain: Domain
    @EnvironmentObject var viewModel: DomainViewModel
    @State private var selectedRecord: DNSRecord?
    
    var body: some View {
        List {
            ForEach(viewModel.dnsRecords) { record in
                DNSRecordRow(record: record)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteDNSRecord(record, in: domain)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            selectedRecord = record
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .navigationTitle("DNS Records")
        .toolbar {
            Button(action: {
                selectedRecord = nil
            }) {
                Image(systemName: "plus")
            }
        }
        .onAppear {
            viewModel.fetchDNSRecords(for: domain)
        }
        .sheet(item: $selectedRecord) { record in
            DNSRecordFormView(viewModel: viewModel, domain: domain, record: record)
        }
    }
}

struct DNSRecordRow: View {
    let record: DNSRecord
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(record.name)
                .font(.headline)
            Text("\(record.type) - \(record.content)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct DNSRecordFormView: View {
    @ObservedObject var viewModel: DomainViewModel
    let domain: Domain
    let record: DNSRecord?
    @State private var name: String
    @State private var type: String
    @State private var content: String
    @State private var ttl: Int
    @Environment(\.presentationMode) var presentationMode
    
    let recordTypes = ["A", "AAAA", "CNAME", "MX", "TXT"]
    
    init(viewModel: DomainViewModel, domain: Domain, record: DNSRecord?) {
        self.viewModel = viewModel
        self.domain = domain
        self.record = record
        _name = State(initialValue: record?.name ?? "")
        _type = State(initialValue: record?.type ?? "A")
        _content = State(initialValue: record?.content ?? "")
        _ttl = State(initialValue: record?.ttl ?? 3600)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $type) {
                    ForEach(recordTypes, id: \.self) { Text($0) }
                }
                TextField("Content", text: $content)
                Stepper("TTL: \(ttl)", value: $ttl, in: 60...86400)
            }
            .navigationTitle(record == nil ? "Add DNS Record" : "Edit DNS Record")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(record == nil ? "Add" : "Update") {
                        if let record = record {
                            viewModel.updateDNSRecord(record, in: domain, name: name, type: type, content: content, ttl: ttl)
                        } else {
                            viewModel.addDNSRecord(to: domain, name: name, type: type, content: content, ttl: ttl)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

