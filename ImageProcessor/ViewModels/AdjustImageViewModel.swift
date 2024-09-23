//
//  AdjustImageViewModel.swift
//  ImageProcessor
//
//  Created by Max Guo on 9/18/24.

import SwiftUI
import Combine
import UIKit

class AdjustImageViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var adjustedImage: UIImage?
    @Published var lutIntensity: Double = 0.0
    @Published var selectedLUT: String = "PRESET_Fujicolor_SuperHR100"
    @Published var halationIntensity: Double = 0.0
    @Published var grainIntensity: Double = 0.0
    @Published var isProcessing: Bool = false // loading respnose bool
    
    // lut files on set
    let availableLUTs = ["PRESET_Fujicolor_SuperHR100", "Polaroid 600"]
    
    // combine cancels
    private var cancellables = Set<AnyCancellable>()
    
    init(selectedImageName: String) {
        loadOriginalImage(named: selectedImageName)
        setupBindings()
    }
    
    func loadOriginalImage(named imageName: String) {
        if let image = UIImage(named: imageName)?.resized(toMaxDimension: 1080) { // gpu
            self.originalImage = image
            print("Loaded image: \(imageName)")
            applyFilterEffects()
        } else {
            print("failed to load selected image.")
        }
    }
    
    // auto filter application when properties changes
    private func setupBindings() {
        // watch for changes
        Publishers.CombineLatest4($selectedLUT, $lutIntensity, $halationIntensity, $grainIntensity)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // delay filter response
            .sink { [weak self] (lut, lutInt, halInt, grainInt) in
                self?.applyFilterEffects()
            }
            .store(in: &cancellables)
    }
    
    func applyFilterEffects() {
        guard let image = originalImage else {
            print("No image available")
            return
        }

        DispatchQueue.main.async {
            self.isProcessing = true
        }
        
        //   image processing in BG
        DispatchQueue.global(qos: .userInitiated).async {
            var processedImage: UIImage? = image
            
            // 1. lut applicaton
            if let lutAppliedImage = LUTLoader.applyLUT(to: image, lutName: self.selectedLUT, intensity: Float(self.lutIntensity)) {
                processedImage = lutAppliedImage
            } else {
                print("using lut'\(self.selectedLUT)' lut applied with intensity bar: \(self.lutIntensity)")

            }
            
            // 2.halation
            if self.selectedLUT == "Polaroid 600", self.halationIntensity > 0.0 {
                if let halationAppliedImage = FilterApplier.applyHalation(to: processedImage!, intensity: Float(self.halationIntensity)) {
                    processedImage = halationAppliedImage
                } else {
                    print("Failed to apply Halation to the image.")
                }
            }
            
            // 3. Apply Grain
            if self.selectedLUT == "Polaroid 600", self.grainIntensity > 0.0 {
                if let grainAppliedImage = FilterApplier.applyGrain(to: processedImage!, intensity: Float(self.grainIntensity)) {
                    processedImage = grainAppliedImage
                } else {
                    print("Failed to apply Grain to the image.")
                }
            }
            
            // ui mainthread update
            DispatchQueue.main.async {
                self.adjustedImage = processedImage
                self.isProcessing = false
                print("Applied lut: \(self.selectedLUT), Lut: \(self.lutIntensity), Halation: \(self.halationIntensity), grain: \(self.grainIntensity)")
            }
        }
    }
    

    func resetAdjustments() {
        lutIntensity = 0.0
        halationIntensity = 0.0
        grainIntensity = 0.0
    }
}

extension UIImage {
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if aspectRatio > 1 {
          
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
          
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
