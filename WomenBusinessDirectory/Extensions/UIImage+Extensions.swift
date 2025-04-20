//
//  UIImage+Extensions.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 5/30/24.
//

import UIKit

extension UIImage {
    /// Resizes the image to a maximum dimension while preserving aspect ratio
    /// - Parameter maxDimension: The maximum width or height the image should have
    /// - Returns: A resized image with the same aspect ratio but no larger than maxDimension in either dimension
    func preparingForUpload(maxDimension: CGFloat) -> UIImage {
        // If image is already smaller than max dimension, return original
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        if originalWidth <= maxDimension && originalHeight <= maxDimension {
            return self
        }
        
        // Calculate the scaling factor
        var scaleFactor: CGFloat = 1.0
        if originalWidth > originalHeight {
            scaleFactor = maxDimension / originalWidth
        } else {
            scaleFactor = maxDimension / originalHeight
        }
        
        // Calculate new size
        let newWidth = originalWidth * scaleFactor
        let newHeight = originalHeight * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Create a new UIImage by drawing the original into a context
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
} 