//
//  MapSnapshotManager.swift
//  Buzz
//
//  Created by Jay Borania on 10/12/25.
//

import MapKit
import UIKit

class MapSnapshotManager {
    static let shared = MapSnapshotManager()

    func snapshot(for coordinate: CLLocationCoordinate2D,
                  size: CGSize = CGSize(width: 150, height: 102)) async -> UIImage? {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
        options.size = size
        options.scale = await UIScreen.main.scale

        let snapshotter = MKMapSnapshotter(options: options)

        do {
            let snapshot = try await snapshotter.start()
            return snapshot.image
        } catch {
            print("Snapshot error:", error)
            return nil
        }
    }
}
