//
//  CIImage+Extension.swift
//  deltatick
//
//  Created by Jimmy Arts on 22/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    
    static func createSyncImageForCode(_ code: String, size: CGSize) -> NSImage? {
        let stringData = code.data(using: .isoLatin1)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        guard let outputImage = qrFilter?.outputImage else {
            return nil
        }
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let transformedImage = outputImage.transformed(by: transform)
        let rep: NSCIImageRep = NSCIImageRep(ciImage: transformedImage)
        let nsImage = NSImage(size: size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
