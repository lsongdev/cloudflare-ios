//
//  SettingView.swift
//  CloudflareApp
//
//  Created by Lsong on 8/3/23.
//

import SwiftUI

struct SettingView: View {
    @Binding var isPresented: Bool
    @AppStorage("token") var token: String = "wDy3k0rtaunqwvEhb97WoXYXTEbP8ORjBz2DDNx6"
    var body: some View {
        NavigationStack{
            Form {
                Section("Basic") {
                    TextField("Email", text: $token)
                    TextField("Key", text: $token)
                }
                
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Text("Done")
            })
        }
    }
}
