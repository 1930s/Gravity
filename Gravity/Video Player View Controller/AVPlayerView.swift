//
//  AVPlayerView.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import AVKit

class AVPlayerView: UIView {
    var player: AVPlayer? { didSet { playerLayer.player = player }}
    private var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
