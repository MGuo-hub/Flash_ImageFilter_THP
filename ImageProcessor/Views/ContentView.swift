//
//  ContentView.swift
//  ImageProcessor
//
//  Created by Max Guo on 9/18/24.
//
import SwiftUI

struct ContentView: View {
    @State private var showImageSelection = false

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 50) {
                Text("Create your cool filter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)

                VStack(alignment: .leading, spacing: 30) {
                    FeatureRow(icon: "square.on.square", title: "One Filter For All", subtitle: "Feel the texture of timeless film.")
                    FeatureRow(icon: "eyedropper.halffull", title: "Retro Radiance", subtitle: "Relive the golden age of analog photography.")
                    FeatureRow(icon: "wand.and.stars", title: "Intensity Slider", subtitle: "Dial in the vibe, from subtle to striking.")
                }
                .padding()

                Spacer()

                Button(action: {
                    showImageSelection = true
                }) {
                    Text("CHOOSE YOUR PICTURE")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showImageSelection) {
            ImageSelectionView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.headline)
                    if let badge = badge {
                        Text(badge)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
#Preview {
    ContentView()
}
