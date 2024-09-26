import SwiftUI

@main
struct CloudflareApp: App {
    @StateObject private var cloudflareClient = CloudflareClient()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(cloudflareClient)
        }
    }
}
