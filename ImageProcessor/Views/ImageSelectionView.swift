//
//  ImageSelectionView.swift
//  ImageProcessor
//
//  Created by Max Guo on 9/18/24.
//
import SwiftUI

struct ImageSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: String?
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    let sampleImages = ["samplePic1", "samplePic2", "samplePic3", "samplePic4","samplePic5"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(sampleImages, id: \.self) { imageName in
                        ImageSelectionItem(imageName: imageName, isSelected: selectedImage == imageName)
                            .onTapGesture {
                                if selectedImage == imageName {
                                    selectedImage = nil
                                } else {
                                    selectedImage = imageName
                                }
                            }
                    }
                }
                .padding(2)
            }
            .background(Color.white)
            .navigationTitle("Select your picture")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let selected = selectedImage {
                        NavigationLink(value: selected) {
                            Text("Next")
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { imageName in
                AdjustImageView(selectedImage: imageName)
            }
        }
    }
}

struct ImageSelectionItem: View {
    let imageName: String
    let isSelected: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .clipped()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Color.white.clipShape(Circle()))
                        .padding(8)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .cornerRadius(4)
            .padding(1)
            .background(Color.white)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
#Preview {
   ImageSelectionView()
}
