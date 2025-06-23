//
//  File.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 20/02/25.
//

import SwiftUI
import AVKit

struct ZoomableVideoView: View {
    let videoURL: URL
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VideoPlayer(player: player)
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale *= delta
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                scale = (scale > 1.0) ? 1.0 : 2.5
                            }
                        }
                )

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            setupVideoPlayer()
        }
    }
    
    private func setupVideoPlayer() {
        player = AVPlayer(url: videoURL)
        player?.play() 
    }
}
