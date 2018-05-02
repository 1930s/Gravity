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
    
    private func ribbonPoints(from transform: SCNMatrix4) -> (SCNMatrix4, SCNMatrix4) {
        let upDirection = transform.upDirection().inverted()
        let offset = Float(width / 2.0)
        let top = upDirection.multiplied(by: offset)
        let bottom = upDirection.multiplied(by: -offset)
        let topPoint = transform.translated(top)
        let bottomPoint = transform.translated(bottom)
        return (topPoint, bottomPoint)
    }
    
    public func append(rawTransform: SCNMatrix4) {
        let transform = smoothedTransform(rawTransform)
        let (topPoint, bottomPoint) = ribbonPoints(from: transform)
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
        previousTransform = transforms.first ?? SCNMatrix4Identity
        for (idx, rawTransform) in transforms.enumerated() {
            let transform = smoothedTransform(rawTransform)
            let (topPoint, bottomPoint) = ribbonPoints(from: transform)
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
        let smoothFactor: Float = 0.35
        let _m11 = previousTransform.m11
        let _m12 = previousTransform.m12
        let _m13 = previousTransform.m13
        let _m14 = previousTransform.m14
        let _m21 = previousTransform.m21
        let _m22 = previousTransform.m22
        let _m23 = previousTransform.m23
        let _m24 = previousTransform.m24
        let _m31 = previousTransform.m31
        let _m32 = previousTransform.m32
        let _m33 = previousTransform.m33
        let _m34 = previousTransform.m34
        let _m41 = previousTransform.m41
        let _m42 = previousTransform.m42
        let _m43 = previousTransform.m43
        let _m44 = previousTransform.m44
        let m11 = transform.m11
        let m12 = transform.m12
        let m13 = transform.m13
        let m14 = transform.m14
        let m21 = transform.m21
        let m22 = transform.m22
        let m23 = transform.m23
        let m24 = transform.m24
        let m31 = transform.m31
        let m32 = transform.m32
        let m33 = transform.m33
        let m34 = transform.m34
        let m41 = transform.m41
        let m42 = transform.m42
        let m43 = transform.m43
        let m44 = transform.m44
        var updatedTransform = transform
        updatedTransform.m11 = smoothFactor*m11 + (1-smoothFactor) * _m11
        updatedTransform.m12 = smoothFactor*m12 + (1-smoothFactor) * _m12
        updatedTransform.m13 = smoothFactor*m13 + (1-smoothFactor) * _m13
        updatedTransform.m14 = smoothFactor*m14 + (1-smoothFactor) * _m14
        updatedTransform.m21 = smoothFactor*m21 + (1-smoothFactor) * _m21
        updatedTransform.m22 = smoothFactor*m22 + (1-smoothFactor) * _m22
        updatedTransform.m23 = smoothFactor*m23 + (1-smoothFactor) * _m23
        updatedTransform.m24 = smoothFactor*m24 + (1-smoothFactor) * _m24
        updatedTransform.m31 = smoothFactor*m31 + (1-smoothFactor) * _m31
        updatedTransform.m32 = smoothFactor*m32 + (1-smoothFactor) * _m32
        updatedTransform.m33 = smoothFactor*m33 + (1-smoothFactor) * _m33
        updatedTransform.m34 = smoothFactor*m34 + (1-smoothFactor) * _m34
        updatedTransform.m41 = smoothFactor*m41 + (1-smoothFactor) * _m41
        updatedTransform.m42 = smoothFactor*m42 + (1-smoothFactor) * _m42
        updatedTransform.m43 = smoothFactor*m43 + (1-smoothFactor) * _m43
        updatedTransform.m44 = smoothFactor*m44 + (1-smoothFactor) * _m44
        return updatedTransform
    }
}
