
import SwiftUI

struct SettingView: View {
    @Binding var isPresented: Bool
    @AppStorage("email") private var email: String = ""
    @AppStorage("apiKey") private var apiKey: String = ""
    @EnvironmentObject var cloudflareClient: CloudflareClient
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cloudflare Account") {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    SecureField("API Key", text: $apiKey)
                }
                
                Section {
                    Button("Save") {
                        saveCredentials()
                    }
                }
                
                Section {
                    NavigationLink("About", destination: AboutView())
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Cancel") {
                    isPresented = false
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveCredentials() {
        cloudflareClient.email = email
        cloudflareClient.apiKey = apiKey
        showAlert = true
        alertMessage = "Credentials saved successfully"
    }
}
