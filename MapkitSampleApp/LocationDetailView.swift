//
//  LocationDetailView.swift
//  MapkitSampleApp
//
//  Created by Prathamesh on 7/13/24.
//

import MapKit
import SwiftUI

struct LocationDetailView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirections: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text(mapSelection?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button(action: {
                    show.toggle()
                    mapSelection = nil
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(.systemGray6))
                })
            }
            
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            } else {
                ContentUnavailableView("No Preview AValiable",systemImage: "eye.slash")
            }
            
            HStack(spacing: 24) {
                Button {
                    if let mapSelection {
                        mapSelection.openInMaps()
                    }
                }label: {
                    Text ("Open in Maps")
                        .font (.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height:48)
                        .background (.green)
                        .cornerRadius (12)
                }
                
                Button {
                    getDirections = true
                    show = false
                } label: {
                    Text ("Get Directions")
                        .font (.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height:48)
                        .background (.blue)
                        .cornerRadius (12)
                }
            }
            .padding(.horizontal)
        }
        .onAppear(perform: {
            fetchLookAroundPreview()
        })
        .onChange(of: mapSelection) { oldValue, newValue in
            fetchLookAroundPreview()
        }
        .padding()
    }
}

extension LocationDetailView {
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    LocationDetailView(mapSelection: .constant(nil), show: .constant(false), getDirections: .constant(false))
}
