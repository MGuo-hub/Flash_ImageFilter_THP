//
//  ImageProcessorApp.swift
//  ImageProcessor
//
//  Created by Max Guo on 9/18/24.
//
import UIKit
import CoreImage

class LUTLoader {
    var lutSize: Int = 0
    var lutData: Data?

    init?(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "cube") else {
            print("lut file not found")
            return nil
        }

        do {
            let fileContents = try String(contentsOf: url)
            parseCubeFile(contents: fileContents)
        } catch {
            print("Error reading LUT file: \(error)")
            return nil
        }
    }

    private func parseCubeFile(contents: String) {
        let lines = contents
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }

        var dataPoints: [Float] = []

        for line in lines {
            let components = line
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }

            if components.isEmpty { continue }

            if components[0].uppercased() == "LUT_3D_SIZE", components.count > 1,
               let size = Int(components[1]) {
                lutSize = size
                print("LUT size find: \(lutSize)")
            } else if components.count == 3,
                      let r = Float(components[0]),
                      let g = Float(components[1]),
                      let b = Float(components[2]) {
                dataPoints.append(contentsOf: [r, g, b, 1.0]) // alpha
            }
        }

        let expectedDataCount = lutSize * lutSize * lutSize * 4 // RGBA
        guard dataPoints.count == expectedDataCount else {
            print("Invalid LUt counts. need: \(expectedDataCount) but has: \(dataPoints.count)")
            return
        }

        lutData = Data(bytes: dataPoints, count: dataPoints.count * MemoryLayout<Float>.size)
        print("LUT data parrsed. Data count: \(dataPoints.count)")
    }

    static func applyLUT(to image: UIImage, lutName: String, intensity: Float) -> UIImage? {
        print("applied LUT with intensity: \(intensity)")

        guard let lutLoader = LUTLoader(fileName: lutName),
              let ciImage = CIImage(image: image),
              let lutData = lutLoader.lutData else {
            print("Fail to load LUT File in func applyLut")
            return nil
        }

        let filter = CIFilter(name: "CIColorCube")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(lutLoader.lutSize, forKey: "inputCubeDimension")
        filter?.setValue(lutData, forKey: "inputCubeData")

        if let outputImage = filter?.outputImage {
            let blendedImage = blendImages(ciImage1: ciImage, ciImage2: outputImage, intensity: intensity)
            let context = CIContext()
            if let cgImage = context.createCGImage(blendedImage, from: blendedImage.extent) {
                print("Successful blended the images.")
                return UIImage(cgImage: cgImage)
            } else {
                print("Failed to apply cgiimage")
            }
        } else {
            print("no Output")
        }

        return nil
    }

    static func blendImages(ciImage1: CIImage, ciImage2: CIImage, intensity: Float) -> CIImage {
        let alphaAdjustedImage = ciImage2.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
            "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
            "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
            "inputAVector": CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity)),
            "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0)
        ])

        return alphaAdjustedImage.composited(over: ciImage1)
    }
}
