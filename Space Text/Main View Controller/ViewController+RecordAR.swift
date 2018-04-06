//
//  ViewController+RecordAR.swift
//  Space Text
//
//  Created by Alexander Pagliaro on 4/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import ARVideoKit

extension ViewController: RecordARDelegate {
    func recorder(didFailRecording error: Error?, and status: String) {
        
    }
    func recorder(didEndRecording path: URL, with noError: Bool) {
        
    }
    func recorder(willEnterBackground status: RecordARStatus) {
        
    }
}
