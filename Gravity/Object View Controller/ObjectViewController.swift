//
//  ObjectViewController.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 5/3/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

protocol ObjectViewControllerDelegate {
    func objectViewController(didSelect object: Object)
    func objectViewController(didDelete object: Object)
}

class ObjectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var navigationBar: UINavigationBar!
    var delegate: ObjectViewControllerDelegate?
    var objects: [Object] = []
    private var imageCache: NSCache<NSUUID, UIImage> = NSCache()
    
    init(recentObjects: [Object]) {
        super.init(nibName: "ObjectViewController", bundle: nil)
        objects = recentObjects
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let objectCellNib = UINib(nibName: "ObjectCollectionViewCell", bundle: nil)
        collectionView.register(objectCellNib, forCellWithReuseIdentifier: "Object")
        let ribbonObject = Object(type: .text(.ribbon))
        let arrowObject = Object(type: .shape(.arrow))
        let locationObject = Object(type: .shape(.location))
        let imageObject = Object(type: .media(.image))
        objects = [ribbonObject, arrowObject, locationObject, imageObject] + objects
        //collectionView.contentInset.top = navigationBar.frame.height
        collectionView.backgroundColor = nil
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        imageCache.removeAllObjects()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Object", for: indexPath) as! ObjectCollectionViewCell
        let object = objects[indexPath.item]
        cell.button.isHidden = indexPath.row < 4
        cell.buttonAction = { sender in
            guard !sender.isHidden else { return }
            self.objects.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            self.delegate?.objectViewController(didDelete: object)
        }
        switch object.type {
        case .text:
            cell.imageView.image = #imageLiteral(resourceName: "text")
            cell.imageView.tintColor = object.textColor()
            cell.label.text = indexPath.row < 4 ? "Text" : object.text
        case .shape(let shapeType):
            switch shapeType {
            case .arrow:
                cell.imageView.image = #imageLiteral(resourceName: "arrow")
                cell.imageView.tintColor = object.backgroundColor ?? UIColor.gravityBlue()
                cell.label.text = "Arrow"
            case .location:
                cell.imageView.image = #imageLiteral(resourceName: "location")
                cell.imageView.tintColor = object.backgroundColor ?? UIColor.gravityBlue()
                cell.label.text = "Location"
            }
        case .media(let mediaType):
            switch mediaType {
            case .image:
                cell.imageView.image = #imageLiteral(resourceName: "image")
                if let image = imageCache.object(forKey: object.identifier as NSUUID) {
                    cell.imageView.image = image
                } else {
                    DispatchQueue.global(qos: .background).async {
                        if let mediaURL = object.mediaURL, let imageData = try? Data(contentsOf: mediaURL), let image = UIImage(data: imageData)?.fixedOrientation().scaled(to: CGSize(width: 300, height: 300), scalingMode: .aspectFit) {
                            self.imageCache.setObject(image, forKey: object.identifier as NSUUID)
                            DispatchQueue.main.async {
                                if let cell = collectionView.cellForItem(at: indexPath) as? ObjectCollectionViewCell {
                                    cell.imageView.image = image
                                    cell.setNeedsLayout()
                                    cell.layoutIfNeeded()
                                }
                            }
                        }
                    }
                }
                cell.imageView.tintColor = object.backgroundColor ?? UIColor.gravityBlue()
                cell.label.text = "Image"
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.objectViewController(didSelect: objects[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/2.0, height: collectionView.bounds.width/2.0)
    }
    
    @IBAction func cancel(sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
