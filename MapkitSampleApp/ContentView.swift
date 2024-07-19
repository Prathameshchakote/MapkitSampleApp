//
//  ContentView.swift
//  MapkitSampleApp
//
//  Created by Prathamesh on 7/13/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchtext: String = ""
    @State private var result = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State var getDirections: Bool = false
    @State private var routeDisplaying = false
    @State private var routeDestination: MKMapItem?
    @State private var route: MKRoute?
    
    var body: some View {
        
        Map(position: $cameraPosition, selection: $mapSelection){
            Marker("My Position", systemImage: "paperplane" ,coordinate: .userloaction)
                .tint(.blue)
            
            ForEach(result, id: \.self) { item in
                
                if getDirections {
                    if item == routeDestination {
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
                } else {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
            
        }
        .overlay(alignment: .top){
            TextField("Enter the loaction", text: $searchtext)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .cornerRadius(9)
                .shadow(radius: 12)
        }
        .onSubmit(of: .text) {
            print("Search of location of query \(searchtext)")
            Task {await searchPlaces()}
        }
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
        })
        .onChange(of: getDirections, { oldValue, newValue in
            if newValue {
                fetchRoute()
            }
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
        .mapControls {
            MapCompass()
//            MapPitchButton()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
}

extension ContentView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchtext
        request.region = .userRegion
        
        let result = try? await MKLocalSearch(request: request).start()
        self.result = result?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userloaction))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                    
                }
            }
        }
    }
}

extension CLLocationCoordinate2D {
    static var userloaction: CLLocationCoordinate2D {
        return .init(latitude: 25.760, longitude: -80.1959)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userloaction, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}
