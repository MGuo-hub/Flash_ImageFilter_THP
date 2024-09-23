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
            ZStack {
                VStack(spacing: 0) {
                    // Image Section
                    if let adjustedImage = viewModel.adjustedImage {
                        Image(uiImage: adjustedImage)
                            .resizable()
                            .scaledToFit() // pic stays aspect ratio
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    } else if let image = viewModel.originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit() // pic stays aspect ratio
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    } else {
                        Color.gray
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    }

                    // seperator image / picker +sliders
                    Divider()
                        .background(Color.gray)
                        .padding(.vertical, 10)

                    // picker +sliders
                    ScrollView {
                        VStack(spacing: 20) {
                           // added Filter Picker
                            Picker("Select Filter", selection: $viewModel.selectedLUT) {
                                ForEach(viewModel.availableLUTs, id: \.self) { lut in
                                    Text(lut.replacingOccurrences(of: "_", with: " ")).tag(lut)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding([.leading, .trailing], 30)

                            // slider
                            VStack(alignment: .leading) {
                                Text("LUT Intensity: \(String(format: "%.2f", viewModel.lutIntensity))")
                                    .padding(.horizontal, 30)
                                Slider(value: $viewModel.lutIntensity, in: 0.0...1.0, step: 0.01)
                                    .padding([.leading, .trailing], 30)
                            }

                            // 2 extra conditional slider for polaroid file
                            if viewModel.selectedLUT == "Polaroid 600" {
                                // halation bar
                                VStack(alignment: .leading) {
                                    Text("Halation Intensity: \(String(format: "%.2f", viewModel.halationIntensity))")
                                        .padding(.horizontal, 30)
                                    Slider(value: $viewModel.halationIntensity, in: 0.0...1.0, step: 0.01)
                                        .padding([.leading, .trailing], 30)
                                }

                                // Grain bar
                                VStack(alignment: .leading) {
                                    Text("Grain Intensity: \(String(format: "%.2f", viewModel.grainIntensity))")
                                        .padding(.horizontal, 30)
                                    Slider(value: $viewModel.grainIntensity, in: 0.0...1.0, step: 0.01)
                                        .padding([.leading, .trailing], 30)
                                }
                            }

                            // reset button
                            if viewModel.selectedLUT == "Polaroid 600" {
                                Button(action: {
                                    viewModel.resetAdjustments()
                                }) {
                                    Text("Reset")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                                .padding([.leading, .trailing], 30)
                            }
                        }
                        .padding(.top, 20)
                    }
                }

                // loading response
                if viewModel.isProcessing {
                    ZStack {
                        Color.black.opacity(0.5)
                        
                        ProgressView("Processing...")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.3)
                }
            }
            .navigationBarTitle("Adjust Image", displayMode: .inline)
        }
    }
}
#Preview {
   AdjustImageView(selectedImage: "samplePic3" )
}

