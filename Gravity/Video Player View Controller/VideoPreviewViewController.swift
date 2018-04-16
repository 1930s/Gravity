//
//  VideoPreviewViewController.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import AVKit

class VideoPreviewViewController: UIViewController {

    @IBOutlet weak var deleteButton: CircularButtonView!
    @IBOutlet weak var saveButton: CircularButtonView!
    @IBOutlet weak var playerView: AVPlayerView!
    
    var url: URL
    private var loopObserver: Any?
    
    init(fileURL: URL) {
        self.url = fileURL
        super.init(nibName: "VideoPreviewViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        playerView.player = player
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
            loopObserver = nil
        }
    }
    
    deinit {
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
            loopObserver = nil
        }
        loopObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { (_) in
            DispatchQueue.main.async { [unowned self] in
                self.playerView.player?.seek(to: kCMTimeZero)
                self.playerView.player?.play()
            }
        })
        playerView.player?.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteVideo(sender: UIButton) {
        try? FileManager.default.removeItem(at: url)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareVideo(sender: UIButton) {
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
