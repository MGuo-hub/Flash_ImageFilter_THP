//
// FilterApplier.swift
// ImageProcessor
//
//  Created by Max Guo on 9/22/24.
//
import UIKit
import CoreImage

class FilterApplier {
    // better performance
    static let context: CIContext = {
        let options: [CIContextOption: Any] = [
            .useSoftwareRenderer: false // Ensures GPU is used
        ]
        return CIContext(options: options)
    }()
    
    static func applyHalation(to image: UIImage, intensity: Float) -> UIImage? {
           guard let ciImage = CIImage(image: image) else { return nil }
           
           // 1.blurr
           let blurRadius = CGFloat(intensity * 10)
           guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
           blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
           blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
           
           guard let blurredImage = blurFilter.outputImage else { return nil }
           
           // 2.brightness
           guard let brightnessFilter = CIFilter(name: "CIColorControls") else { return nil }
           brightnessFilter.setValue(blurredImage, forKey: kCIInputImageKey)
           brightnessFilter.setValue(-0.5, forKey: kCIInputBrightnessKey)
           brightnessFilter.setValue(0.0, forKey: kCIInputContrastKey)
           
           guard let darkenedBlur = brightnessFilter.outputImage else { return nil }
           
           // 3.blend with darken image
           guard let blendFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
           blendFilter.setValue(darkenedBlur, forKey: kCIInputImageKey)
           blendFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
           
           guard let blendedImage = blendFilter.outputImage else { return nil }
           
           // 4.hala adjust effect opacity
           guard let opacityFilter = CIFilter(name: "CIColorMatrix") else { return nil }
           opacityFilter.setValue(blendedImage, forKey: kCIInputImageKey)
           opacityFilter.setValue(CIVector(x: 1, y: 1, z: 1, w: CGFloat(intensity)), forKey: "inputAVector")
           opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
           
           guard let finalHalation = opacityFilter.outputImage else { return nil }
           
           // 5. final blend rendeing the pic
           guard let finalBlendFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
           finalBlendFilter.setValue(finalHalation, forKey: kCIInputImageKey)
           finalBlendFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
           
           guard let outputImage = finalBlendFilter.outputImage else { return nil }
           
    
           if let cgImage = context.createCGImage(outputImage, from: ciImage.extent) {
               return UIImage(cgImage: cgImage)
           }
           
           return nil
       }

    static func applyGrain(to image: UIImage, intensity: Float) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // 1. noise filter
        guard let noiseFilter = CIFilter(name: "CIRandomGenerator") else { return nil }
        guard let noiseImage = noiseFilter.outputImage else { return nil }
        
        // 2. scale of the filter
        let scale = CGFloat(intensity * 3.5) // grain size
        guard let transformFilter = CIFilter(name: "CIAffineTransform") else { return nil }
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        transformFilter.setValue(noiseImage, forKey: kCIInputImageKey)
        transformFilter.setValue(transform, forKey: kCIInputTransformKey)
        
        guard let scaledNoise = transformFilter.outputImage else { return nil }
        
        // 3. noise adjustment
        let croppedNoise = scaledNoise.cropped(to: ciImage.extent)
        
        // 4. opacity
        guard let opacityFilter = CIFilter(name: "CIColorMatrix") else { return nil }
        opacityFilter.setValue(croppedNoise, forKey: kCIInputImageKey)
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity * 0.15)), forKey: "inputAVector") // More subtle
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        
        guard let grainNoise = opacityFilter.outputImage else { return nil }
        
        // 5. blend
        guard let blendFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        blendFilter.setValue(grainNoise, forKey: kCIInputImageKey)
        blendFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        
        guard let blendedImage = blendFilter.outputImage else { return nil }
        
        // 6. rendering the pic
        if let cgImage = context.createCGImage(blendedImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}
