//
//  AboutView.swift
//  CloudflareApp
//
//  Created by Lsong on 8/3/23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack{
            Text("Cloudflare").font(.largeTitle)
            List{
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
