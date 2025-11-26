//
//  BottomSheet .swift
//  Buzz
//
//  Created by Jay Borania on 27/10/25.
//

import SwiftUI
import MapKit

struct BottomSheet: View {
    var courts: [CourtFinderModel]
    var userCoordinate: CLLocationCoordinate2D? // 👈 Pass from parent view
    @State private var distances: [UUID: String] = [:]

    var body: some View {
        ScrollView {
            ForEach(courts) { court in
                Button {
                    openInAppleMaps(court.mapItem)
                } label: {
                    
                    
                    VStack(alignment: .leading, spacing: 2) {

                        HStack(alignment: .top) {
                            Text(court.mapItem.name ?? "Unnamed Court")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("~\(distanceString(from: userCoordinate, to: court.mapItem))")
                                                           .font(.subheadline)
                                                           .foregroundColor(.secondary)
                        }
                        if let address = court.mapItem.placemark.title {
                            Text(address)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .padding([.top,.leading,.trailing])
                .background(.clear)
            }
            .padding(.top)
            .background(.clear)
        }
        .background(.clear)

    }

    private func distanceString(from userCoordinate: CLLocationCoordinate2D?, to destination: MKMapItem) -> String {
           // If location not available yet
           guard let userCoordinate = userCoordinate else {
               return "Locating..."
           }

           // Calculate distance between two coordinates
           let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
           guard let destinationLocation = destination.placemark.location else {
               return "Unknown"
           }

           let distanceInMeters = userLocation.distance(from: destinationLocation)
           if distanceInMeters >= 1000 {
               return String(format: "%.1f km", distanceInMeters / 1000)
           } else {
               return String(format: "%.0f m", distanceInMeters)
           }
       }

    private func openInAppleMaps(_ mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}


//#Preview {
//    BottomSheet()
//}
