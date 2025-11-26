//
//  CourtLookAroundPreview.swift
//  Buzz
//
//  Created by Jay Borania on 28/10/25.
//

import SwiftUI
import MapKit

struct CourtLookAroundPreview: View {
    let mapItem: MKMapItem
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var snapshotImage: UIImage?

    var body: some View {
        Group {
            if lookAroundScene != nil {
                LookAroundPreview(scene: $lookAroundScene)
                    .cornerRadius(10)
            } else if let snapshotImage {
                Image(uiImage: snapshotImage)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .overlay(ProgressView())
                    .cornerRadius(10)
            }
        }
        .task {
            await loadLookAroundOrSnapshot()
        }
    }

    private func loadLookAroundOrSnapshot() async {
        let request = MKLookAroundSceneRequest(mapItem: mapItem)
        if let scene = try? await request.scene {
            lookAroundScene = scene
        } else {
            await generateSnapshot()
        }
    }

    private func generateSnapshot() async {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: mapItem.placemark.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)
        options.size = CGSize(width: 300, height: 200)
        options.mapType = .standard
        options.showsBuildings = true
        options.pointOfInterestFilter = .includingAll

        let snapshotter = MKMapSnapshotter(options: options)
        do {
            let snapshot = try await snapshotter.start()
            let image = snapshot.image

            UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
            image.draw(at: .zero)

            let point = snapshot.point(for: mapItem.placemark.coordinate)
            let pin = UIImage(systemName: "mappin.circle.fill")?
                .withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
            let offset = CGPoint(x: point.x - (pin?.size.width ?? 0) / 2,
                                 y: point.y - (pin?.size.height ?? 0))
            pin?.draw(at: offset)

            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            await MainActor.run {
                snapshotImage = finalImage
            }
        } catch {
            print("❌ Snapshot error: \(error.localizedDescription)")
        }
    }
}
