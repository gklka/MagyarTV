//
//  PlayerView.swift
//  MagyarTVWatch
//
//  Copyright © 2026. GKSoftware. All rights reserved.
//

import SwiftUI
import AVKit
import AVFoundation

struct PlayerView: View {
    let channel: Channel

    @State private var player: AVPlayer?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else if let errorMessage {
                ScrollView {
                    VStack(spacing: 8) {
                        Text("A csatorna nem tölthető be. Próbálkozz később!")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        Text("(A hiba oka: \(errorMessage))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Újra") {
                            self.errorMessage = nil
                            Task { await load() }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(channel.title)
        .task { await load() }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func load() async {
        do {
            let url = try await StreamResolver.liveStreamURL(forChannel: channel.id)

            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .moviePlayback, policy: .default)

            let player = AVPlayer(url: url)
            self.player = player
            player.play()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PlayerView(channel: Channel.all[0])
}
