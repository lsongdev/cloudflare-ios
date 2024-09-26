import SwiftUI


struct MainView: View {
    @State private var showingSetting = false
    @StateObject private var cloudflareClient = CloudflareClient()
    @StateObject private var domainViewModel: DomainViewModel
    
    init() {
        _domainViewModel = StateObject(wrappedValue: DomainViewModel(cloudflareClient: CloudflareClient()))
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: DomainListView()) {
                    Label("Domains", systemImage: "globe")
                }
            }
            .navigationTitle("Cloudflare")
            .toolbar {
                Button(action: { showingSetting = true }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showingSetting) {
                SettingView(isPresented: $showingSetting)
                    .environmentObject(cloudflareClient)
            }
        }
        .environmentObject(cloudflareClient)
        .environmentObject(domainViewModel)
    }
}
