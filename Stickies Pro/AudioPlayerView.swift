//
//  AudioPlayerView.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit

struct AudioPlayerView: View {
    let audioURL: URL
    @State private var player: AVAudioPlayer?

    var body: some View {
        HStack {
            Button(action: playAudio) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }

            Text(audioURL.lastPathComponent)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private func playAudio() {
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
