//
//  ContentView.swift
//  ImageProcessor
//
//  Created by Max Guo on 9/18/24.
//
import SwiftUI

struct AdjustImageView: View {
    @StateObject private var viewModel: AdjustImageViewModel

    init(selectedImage: String) {
        _viewModel = StateObject(wrappedValue: AdjustImageViewModel(selectedImageName: selectedImage))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Image Section
                if let adjustedImage = viewModel.adjustedImage {
                    Image(uiImage: adjustedImage)
                        .resizable()
                        .scaledToFit() // pic stays aspect ratio
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.75) 
                } else if let image = viewModel.originalImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit() // pic stays aspect ratio
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                } else {
                    Color.gray
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                }

                // added Filter Picker
                VStack {
                 
                    Picker("Select Filter", selection: $viewModel.selectedLUT) {
                        ForEach(viewModel.availableLUTs, id: \.self) { lut in
                            Text(lut.replacingOccurrences(of: "_", with: " ")).tag(lut)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing], 30)
                    .onChange(of: viewModel.selectedLUT) {
                        viewModel.applyLUT()
                    }

                    // slider part of the code
                    VStack {
                        Text("LUT Intensity: \(String(format: "%.2f", viewModel.lutIntensity))")
                        Slider(value: $viewModel.lutIntensity, in: 0.0...1.0, onEditingChanged: { editing in
                            if !editing {
                                print("Slider editing ended. Value: \(viewModel.lutIntensity)")
                                viewModel.applyLUT()
                            }
                        })
                        .padding([.leading, .trailing], 30)
                    }
                }
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height * 0.3) // Slider takes up 30% of the screen
            }
            .navigationBarTitle("Adjust Image", displayMode: .inline)
        }
    }
}

#Preview {
    AdjustImageView(selectedImage: "samplePic1")
}
