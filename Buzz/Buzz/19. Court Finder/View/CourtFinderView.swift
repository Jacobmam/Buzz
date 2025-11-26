
import SwiftUI
import MapKit

struct CourtFinderView: View {
    @StateObject private var viewModel = CourtFinderViewModel()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            headerView
            
            if viewModel.isMapLoaded {
                Map(position: $position) {
                    UserAnnotation()
                    ForEach(viewModel.courts) { court in
                        Annotation(court.mapItem.name ?? "Court",
                                   coordinate: court.mapItem.placemark.coordinate) {
                            Button {
                                openInAppleMaps(court.mapItem)
                            } label: {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20 ))
                .mapStyle(.imagery)
                .onReceive(viewModel.$region) { newRegion in
                    position = .region(newRegion)
                }
            } else {
                JBLoadingView()
            }
            
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.isShowBottomSheet.toggle()
                viewModel.isMapLoaded = true
            }
        }
        .sheet(isPresented: $viewModel.isShowBottomSheet) {
            BottomSheet(courts: viewModel.courts, userCoordinate: viewModel.region.center) // ✅ pass same instance
                .interactiveDismissDisabled(true)
                .presentationDetents([.height(130), .medium, .large])
                .presentationBackground(.clear)
                .background(.clear)
                .presentationBackgroundInteraction(.enabled) // Allow interaction with the background map
        }

//        VStack(spacing: 0) {
//            headerView
//            if viewModel.isMapLoaded {
//                Map(position: $position) {
//                    UserAnnotation()
//                    ForEach(viewModel.courts) { court in
//                        Annotation(court.mapItem.name ?? "Court",
//                                   coordinate: court.mapItem.placemark.coordinate) {
//                            Button {
//                                openInAppleMaps(court.mapItem)
//                            } label: {
//                                Image(systemName: "mappin.circle.fill")
//                                    .font(.title)
//                                    .foregroundColor(.orange)
//                                    .shadow(radius: 2)
//                            }
//                        }
//                    }
//                }
//                .mapStyle(.imagery)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .onReceive(viewModel.$region) { newRegion in
//                    position = .region(newRegion)
//                }
//            } else {
//                JBLoadingView()
//            }
//        }
//        .onAppear() {
//            viewModel.isShowBottomSheet.toggle()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                viewModel.isMapLoaded = true
//            }
//        }
//        .sheet(isPresented: $viewModel.isShowBottomSheet) {
//            BottomSheet(courts: viewModel.courts, userCoordinate: viewModel.region.center)
//                .interactiveDismissDisabled(true)
//                .presentationDetents([.height(130), .medium, .large])
//                .presentationBackground(.clear)
//                .background(.clear)
//                .presentationBackgroundInteraction(.enabled) // Allow interaction with the background map
//        }
    }
    
    var headerView: some View {
        HStack {
            Button {
                viewModel.isShowBottomSheet.toggle()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .tint(.orange)
                    .frame(height: 20)
                    .bold()
            }
            .frame(width: 50, height: 50)
            
            Text("Court Finder")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .background(.black)
        .padding(.leading, 10)
//        .padding(.top, -45)
    }
    private func openInAppleMaps(_ mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
}

