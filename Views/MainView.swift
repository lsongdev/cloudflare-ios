//
//  ContentView.swift
//  cfdash
//
//  Created by Lsong on 8/3/23.
//

import SwiftUI

struct ContentView: View {
    @State var showingSetting = false
    var body: some View {
        NavigationView {
            List() {
                NavigationLink(destination: DomainView()){
                    Text("Domains")
                }
            }
            .navigationTitle("Cloudflare")
            .navigationBarItems(trailing: Button(action: {
                showingSetting = true
            }){
                Image(systemName: "gear")
            })
            .sheet(isPresented: $showingSetting, content: {
                SettingView(isPresented: $showingSetting)
            })
        }
        
    }
}

#Preview {
    ContentView()
}
