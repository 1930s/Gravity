//
//  TextInputViewController.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 4/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

fileprivate var keyboardObserver: NSObjectProtocol?

protocol TextInputViewControllerDelegate {
    func textInput(didFinishWith text: String, font: UIFont, color: UIColor, backgroundColor: UIColor?)
}

class TextInputViewController: UIViewController, UITextViewDelegate {
    
    var font: UIFont {
        if let textAttributes = object.textAttributes {
            return UIFont(name: textAttributes.fontName ?? fontNames.first!, size: textAttributes.fontSize ?? 50.0)!
        }
        return UIFont(name: fontNames.first!, size: 50.0)!
    }
    var textColor: UIColor {
        if let textAttributes = object.textAttributes {
            return textAttributes.textColor ?? UIColor.white
        }
        return UIColor.white
    }
    var backgroundColor: UIColor {
        return object.backgroundColor ?? UIColor.clear
    }
    var text: String = "Hello World" {
        didSet {
            textView.font = font
            textView.textColor = textColor
            textView.text = text
            fontButton.setTitle(font.familyName, for: .normal)
        }
    }
    var object: Object {
        didSet {
            text = object.text ?? "Hello World"
        }
    }

    @IBOutlet weak var fontButton: BorderedButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var colorsButton: UIBarButtonItem!
    @IBOutlet weak var backgroundColorButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var textView: UIVerticallyCenteredTextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var textViewBottomLayoutConstraint: NSLayoutConstraint!
    
    var delegate: TextInputViewControllerDelegate?
    
    init(object: Object) {
        self.object = object
        super.init(nibName: "TextInputViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { (notification) in
            guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            self.textViewBottomLayoutConstraint.constant = keyboardFrame.height
        }
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        let object = self.object
        self.object = object
        textView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let contentSize = self.textView.contentSize
        self.textView.contentSize = contentSize
    }

    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func didPressDone(sender: Any) {
        delegate?.textInput(didFinishWith: textView.text, font: font, color: textColor, backgroundColor: backgroundColor)
    }
    
    @IBAction func fontButtonPressed(sender: Any) {
        let fontName = font.fontName
        if let index = fontNames.index(of: fontName) {
            let newIndex = (index == fontNames.count-1) ? 0 : index+1
            object.setFontName(fontNames[newIndex])
        } else {
            object.setFontName(fontNames[0])
        }
    }
    
    // MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 140
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
