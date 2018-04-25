//
//  ColorPickerViewController.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIColor {
    class func color(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
    }
}

class ColorPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    var didSelectColor: (UIColor) -> Void = { _ in }
    var colors: [UIColor] = [UIColor.clear, UIColor.black, UIColor.white, UIColor.color(63, 153, 237), .color(115, 190, 87), .color(252, 201, 101), .color(251, 140, 63), .color(235, 75, 63), .color(207, 21, 106), .color(162, 29, 184)]
    init() {
        super.init(nibName: "ColorPickerViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let colorCell = UINib(nibName: "ColorCollectionViewCell", bundle: nil)
        collectionView.register(colorCell, forCellWithReuseIdentifier: "ColorCell")
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let cellHeight = view.frame.height - 10
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: cellHeight, height: cellHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCollectionViewCell
        cell.colorView.color = colors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        didSelectColor(colors[indexPath.item])
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
