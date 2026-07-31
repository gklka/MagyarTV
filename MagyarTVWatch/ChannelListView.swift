//
//  ChannelListView.swift
//  MagyarTVWatch
//
//  Copyright © 2026. GKSoftware. All rights reserved.
//

import SwiftUI

struct ChannelListView: View {
    var body: some View {
        NavigationStack {
            List(Channel.all) { channel in
                NavigationLink(value: channel) {
                    HStack(spacing: 12) {
                        Image(channel.logoName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 28)
                        Text(channel.title)
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Magyar TV")
            .navigationDestination(for: Channel.self) { channel in
                PlayerView(channel: channel)
            }
        }
    }
}

#Preview {
    ChannelListView()
}
