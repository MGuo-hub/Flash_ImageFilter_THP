//
//  AdjustImageViewModel.swift
//  ImageProcessor
//
//  Created by Max Guo on 9/18/24.
//
import SwiftUI
import Combine
import UIKit

class AdjustImageViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    @Published var adjustedImage: UIImage?
    @Published var lutIntensity: Double = 0.0

    private let lutName = "PRESET_Fujicolor_SuperHR100"

    init(selectedImageName: String) {
        loadOriginalImage(named: selectedImageName)
        applyLUT()
    }

    func loadOriginalImage(named imageName: String) {
        if let image = UIImage(named: imageName) {
            self.originalImage = image
            print("Loaded image: \(imageName)")
        } else {
            print("failed to load selected image")
        }
    }

    func applyLUT() {
        guard let image = originalImage else {
            print("No image available")
            return
        }

        // image processing in BG
        DispatchQueue.global(qos: .userInitiated).async {
            if let lutAppliedImage = LUTLoader.applyLUT(to: image, lutName: self.lutName, intensity: Float(self.lutIntensity)) {
        // then update UI on the main thread
                DispatchQueue.main.async {
                    self.adjustedImage = lutAppliedImage
                    print("lut applied with intensity bar: \(self.lutIntensity)")
                }
            } else {
                print("Failed to apply LUt to the image.")
            }
        }
    }
}
