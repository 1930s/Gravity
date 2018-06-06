//
//  VideosViewController.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 5/30/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideosViewControllerDelegate {
    func videosViewController(_ viewController: VideosViewController, didSelectVideo url: URL)
}

class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct Video: Equatable {
        var url: URL
        var duration: TimeInterval
        var date: Date
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!
    var delegate: VideosViewControllerDelegate?
    var videos: [Video] = []
    var thumbnailCache: NSCache = NSCache<NSURL, UIImage>()
    private var thumbnailQueue: DispatchQueue = DispatchQueue(label: "thumbnail")
    private var dateFormatter: DateFormatter = DateFormatter()
    private var dateComponentsFormatter: DateComponentsFormatter = DateComponentsFormatter()
    
    init() {
        super.init(nibName: "VideosViewController", bundle: nil)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateComponentsFormatter.zeroFormattingBehavior = .pad
        dateComponentsFormatter.allowedUnits = [.minute, .second]
        dateComponentsFormatter.unitsStyle = .positional
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancel(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        let nib = UINib(nibName: "VideoTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        do {
            let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let files = try FileManager.default.contentsOfDirectory(at: documents, includingPropertiesForKeys: [URLResourceKey.creationDateKey], options: []).sorted(by: { (url1, url2) in
                var keys = Set<URLResourceKey>()
                keys.insert(URLResourceKey.creationDateKey)
                guard let date1 = try url1.resourceValues(forKeys: keys).creationDate,
                    let date2 = try url2.resourceValues(forKeys: keys).creationDate else { return false }
                return date1 > date2
            })
            videos = try files.compactMap({
                let asset = AVURLAsset(url: $0)
                let duration = asset.duration
                guard let date = try $0.resourceValues(forKeys: [.creationDateKey]).creationDate else { return nil }
                return Video(url: $0, duration: duration.seconds, date: date)
            })
        } catch {
            print(error)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.thumbnailCache.removeAllObjects()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VideoTableViewCell
        let video = videos[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: video.date)
        cell.durationLabel.text = dateComponentsFormatter.string(from: video.duration)
        cell.thumbnailView.image = thumbnailCache.object(forKey: video.url as NSURL)
        if cell.thumbnailView.image == nil {
            generateThumbnail(for: video)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.videosViewController(self, didSelectVideo: videos[indexPath.row].url)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = videos[indexPath.row]
            do {
                try FileManager.default.removeItem(at: video.url)
                videos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print(error)
            }
        }
    }
    
    private func generateThumbnail(for video: Video) {
        let url = video.url
        self.thumbnailQueue.async {
            autoreleasepool {
                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                do {
                    let image = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
                    let thumb = UIImage(cgImage: image).scaled(to: CGSize(width: 100.0, height: 100.0))
                    DispatchQueue.main.async {
                        self.thumbnailCache.setObject(thumb, forKey: url as NSURL)
                        self.reloadRow(for: video)
                    }
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    private func reloadRow(for video: Video) {
        guard let row = videos.index(of: video) else { return }
        if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? VideoTableViewCell {
            cell.thumbnailView.image = thumbnailCache.object(forKey: video.url as NSURL)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
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
