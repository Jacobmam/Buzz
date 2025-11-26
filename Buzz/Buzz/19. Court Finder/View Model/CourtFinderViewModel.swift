////
////  CourtFinderViewModel.swift
////  Buzz
////
////  Created by Jay Borania on 14/10/25.
//
import Foundation
import MapKit
import Combine

class CourtFinderViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion()
    @Published var courts: [CourtFinderModel] = []
    @Published var isLoading = false
    @Published var isShowBottomSheet = false
    @Published var isMapLoaded: Bool = false

    private var locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var lastSearchCoordinate: CLLocationCoordinate2D?

    override init() {
        super.init()
        setupLocation()
        observeRegionChanges()
    }

    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func observeRegionChanges() {
        $region
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] newRegion in
                guard let self = self else { return }
                self.handleRegionChange(newRegion)
            }
            .store(in: &cancellables)
    }

    private func handleRegionChange(_ region: MKCoordinateRegion) {
        guard let last = lastSearchCoordinate else {
            lastSearchCoordinate = region.center
            searchNearbyCourts(at: region.center)
            return
        }

        let lastLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
        let newLoc = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        if newLoc.distance(from: lastLoc) > 500 {
            lastSearchCoordinate = region.center
            searchNearbyCourts(at: region.center)
        }
    }

    private func searchNearbyCourts(at coordinate: CLLocationCoordinate2D) {
        isLoading = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Basketball court"
        request.region = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters:5000,
                                            longitudinalMeters:5000)

        MKLocalSearch(request: request).start { [weak self] response, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let items = response?.mapItems {
                    self?.courts = items.map { CourtFinderModel(mapItem: $0) }
                }
            }
        }
    }
}

extension CourtFinderViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        region = MKCoordinateRegion(center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.005))
        locationManager.stopUpdatingLocation()
        searchNearbyCourts(at: location.coordinate)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
}
