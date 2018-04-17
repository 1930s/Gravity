//
//  SCNRibbon.swift
//  ARKitBasics
//
//  Created by Alexander Pagliaro on 4/4/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import SceneKit

class SCNRibbon {
    
    public var width: CGFloat = 1.0 { didSet { updateGeometry() }}
    public var geometry: SCNGeometry { return SCNGeometry(sources: sources, elements: elements) }
    private var transforms: [SCNMatrix4] = []
    private var vertexes: [SCNVector3] = []
    private var normals: [SCNVector3] = []
    private var textureCoord: [CGPoint] = []
    private var indices: [UInt32] = []
    private var index: UInt32 = 0
    private var length: Double = 0
    private var previousTransform: SCNMatrix4 = SCNMatrix4Identity
    // keep track of total length to calculate tex coordinates
    private var sources: [SCNGeometrySource] {
        get {
            let positionSource = SCNGeometrySource(vertices: vertexes)
            let normalSource = SCNGeometrySource(normals: normals)
            let textureSource = SCNGeometrySource(textureCoordinates: textureCoord)
            return [positionSource, normalSource, textureSource]
        }
    }
    private var elements: [SCNGeometryElement] {
        get {
            return [SCNGeometryElement(indices: indices, primitiveType: .triangleStrip)]
        }
    }
    
    init(width: CGFloat, transforms: [SCNMatrix4]) {
        self.width = width
        self.transforms = transforms
        updateGeometry()
    }
    
    public func append(transform: SCNMatrix4) {
        //guard index < 3 else { return }
        let topPoint = SCNMatrix4Translate(transform, 0.0, Float(width / 2.0), 0.0)
        let bottomPoint = SCNMatrix4Translate(transform, 0.0, Float(-width / 2.0), 0.0)
        vertexes.append(SCNVector3(topPoint.m41, topPoint.m42, topPoint.m43))
        vertexes.append(SCNVector3(bottomPoint.m41, bottomPoint.m42, bottomPoint.m43))
        normals.append(SCNVector3(topPoint.m31, topPoint.m32, topPoint.m33))
        normals.append(SCNVector3(bottomPoint.m31, bottomPoint.m32, bottomPoint.m33))
        length += Double((transform.position() - previousTransform.position()).magnitude())
        previousTransform = transform
        //let texX = 0.01 * Double(index)
        let texX = length
        textureCoord.append(CGPoint(x: texX, y: 0))
        textureCoord.append(CGPoint(x: texX, y: 1))
        index += 1
        indices.append(index)
        index += 1
        indices.append(index)
    }
    
    private func updateGeometry() {
        // calculate vertexes from transforms + width
        vertexes = []
        normals = []
        textureCoord = []
        indices = []
        index = 0
        length = 0
        previousTransform = SCNMatrix4Identity
        for (idx, transform) in transforms.enumerated() {
            let topPoint = SCNMatrix4Translate(transform, 0.0, Float(width / 2.0), 0.0)
            let bottomPoint = SCNMatrix4Translate(transform, 0.0, Float(-width / 2.0), 0.0)
            //let rightPoint = SCNMatrix4Translate(transform, Float(width), 0.0, 0.0)
            vertexes.append(SCNVector3(topPoint.m41, topPoint.m42, topPoint.m43))
            vertexes.append(SCNVector3(bottomPoint.m41, bottomPoint.m42, bottomPoint.m43))
            textureCoord.append(CGPoint(x: 0, y: 0))
            textureCoord.append(CGPoint(x:0, y: 1))
            //vertexes.append(SCNVector3(rightPoint.m41, rightPoint.m42, rightPoint.m43))
            normals.append(SCNVector3(topPoint.m31, topPoint.m32, topPoint.m33))
            normals.append(SCNVector3(bottomPoint.m31, bottomPoint.m32, bottomPoint.m33))
            //normals.append(SCNVector3(rightPoint.m31, rightPoint.m32, rightPoint.m33))
            if idx != 0 {
                index += 1
                length += Double((transform.position() - previousTransform.position()).magnitude())
            }
            previousTransform = transform
            indices.append(index)
            index += 1
            indices.append(index)
            //index = UInt8(idx+2)
            //indices.append(index)
        }
    }
}
