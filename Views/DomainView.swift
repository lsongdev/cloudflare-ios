//
//  DomainView.swift
//  CloudflareApp
//
//  Created by Lsong on 8/3/23.
//

import SwiftUI

struct DomainView: View {
    var body: some View {
        List{
            
        }
        .navigationTitle("Domains")
        .navigationBarItems(trailing: Button(action:{}) {
            Image(systemName: "plus")
        })
        
    }
}

#Preview {
    DomainView()
}
