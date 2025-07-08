//
//  ZoomableVideoView.swift
//  Kipp
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
        ZoomableVideoUIKitView(videoURL: videoURL)
            .ignoresSafeArea()
    }
}

struct ZoomableVideoUIKitView: UIViewControllerRepresentable {
    let videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        playerVC.player = player
        playerVC.showsPlaybackControls = true
        playerVC.entersFullScreenWhenPlaybackBegins = false
        playerVC.exitsFullScreenWhenPlaybackEnds = false
        playerVC.videoGravity = .resizeAspect
        player.play()
        return playerVC
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No-op
    }
}
