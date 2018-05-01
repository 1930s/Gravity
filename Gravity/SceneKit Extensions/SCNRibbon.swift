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
    public var textureHorizontalScale: Double = 1.0
    public var geometry: SCNGeometry { return SCNGeometry(sources: sources, elements: elements) }
    private var transforms: [SCNMatrix4] = []
    private var vertexes: [SCNVector3] = []
    private var normals: [SCNVector3] = []
    private var textureCoord: [CGPoint] = []
    private var indices: [UInt32] = []
    private var index: UInt32 = 0
    private var length: Double = 0
    private var previousTransform: SCNMatrix4 = SCNMatrix4Identity
    private var smoothBox: [SCNMatrix4] = []
    private var smoothWidth: Int = 10
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
    
    public func append(rawTransform: SCNMatrix4) {
        //guard index < 3 else { return }
        let transform = smoothedTransform(rawTransform)
        let topPoint = SCNMatrix4Translate(transform, 0.0, Float(width / 2.0), 0.0)
        let bottomPoint = SCNMatrix4Translate(transform, 0.0, Float(-width / 2.0), 0.0)
        vertexes.append(SCNVector3(topPoint.m41, topPoint.m42, topPoint.m43))
        vertexes.append(SCNVector3(bottomPoint.m41, bottomPoint.m42, bottomPoint.m43))
        normals.append(SCNVector3(topPoint.m31, topPoint.m32, topPoint.m33))
        normals.append(SCNVector3(bottomPoint.m31, bottomPoint.m32, bottomPoint.m33))
        length += Double((transform.position() - previousTransform.position()).magnitude())
        previousTransform = transform
        //let texX = 0.01 * Double(index)
        let texX = length*textureHorizontalScale
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
        smoothBox = [previousTransform]
        for (idx, rawTransform) in transforms.enumerated() {
            let transform = smoothedTransform(rawTransform)
            let topPoint = SCNMatrix4Translate(transform, 0.0, Float(width / 2.0), 0.0)
            let bottomPoint = SCNMatrix4Translate(transform, 0.0, Float(-width / 2.0), 0.0)
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
    
    private func smoothedTransform(_ transform: SCNMatrix4) -> SCNMatrix4 {
        let smoothFactor: Float = 0.2
        let previousX = previousTransform.m41
        let previousY = previousTransform.m42
        let previousZ = previousTransform.m43
        let x = transform.m41
        let y = transform.m42
        let z = transform.m43
        var updatedTransform = transform
        updatedTransform.m41 = smoothFactor*x + (1-smoothFactor) * previousX
        updatedTransform.m42 = smoothFactor*y + (1-smoothFactor) * previousY
        updatedTransform.m43 = smoothFactor*z + (1-smoothFactor) * previousZ
        return updatedTransform
    }
}
