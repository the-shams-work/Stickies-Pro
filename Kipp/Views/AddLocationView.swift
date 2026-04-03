//
//  AddLocationView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 03/04/26.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Location Search Service

@MainActor
final class LocationSearchService: NSObject, ObservableObject {
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching = false

    private let completer = MKLocalSearchCompleter()
    private var searchTask: Task<Void, Never>?

    override init() {
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func search(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        searchTask?.cancel()
        isSearching = true

        searchTask = Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            let search = MKLocalSearch(request: request)

            do {
                let response = try await search.start()
                if !Task.isCancelled {
                    self.searchResults = response.mapItems
                }
            } catch {
                if !Task.isCancelled {
                    self.searchResults = []
                }
            }

            self.isSearching = false
        }
    }

    func clear() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
    }
}

// MARK: - Add Location View

struct AddLocationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedLocationName: String?
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?

    @StateObject private var searchService = LocationSearchService()
    @StateObject private var locationManager = NoteLocationManager()

    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3317, longitude: -122.0307),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapAnnotation: IdentifiableCoordinate?
    @State private var pendingName: String?
    @State private var pendingLatitude: Double?
    @State private var pendingLongitude: Double?
    @State private var showRemoveConfirm = false
    @State private var isLocatingUser = false

    private var hasSelection: Bool {
        pendingLatitude != nil
    }

    var body: some View {
        Form {
            // MARK: - Search Section
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))

                    TextField("addlocation.search.placeholder", text: $searchText)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { _, new in
                            searchService.search(query: new)
                        }

                    if searchService.isSearching {
                        ProgressView()
                            .scaleEffect(0.75)
                    } else if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchService.clear()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text("addlocation.section.search")
            }

            // MARK: - Search Results
            if !searchService.searchResults.isEmpty {
                Section {
                    ForEach(searchService.searchResults, id: \.self) { item in
                        Button {
                            selectMapItem(item)
                        } label: {
                            HStack(spacing: 14) {
                                HIGIcon(systemName: "mappin", color: themeManager.theme.color)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    if let address = formatAddress(item) {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                if pendingLatitude == item.placemark.coordinate.latitude &&
                                    pendingLongitude == item.placemark.coordinate.longitude {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.theme.color)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("addlocation.section.results")
                }
            }

            // MARK: - Use Current Location
            Section {
                Button {
                    requestCurrentLocation()
                } label: {
                    HStack(spacing: 14) {
                        HIGIcon(systemName: "location.fill", color: .blue)
                        Text("addlocation.use.current")
                            .foregroundColor(.primary)
                        Spacer()
                        if isLocatingUser {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isLocatingUser)
            } header: {
                Text("addlocation.section.current")
            }

            // MARK: - Map Preview & Selection
            if hasSelection, let lat = pendingLatitude, let lon = pendingLongitude {
                Section {
                    VStack(spacing: 10) {
                        Map(coordinateRegion: $region, annotationItems: mapAnnotation.map { [$0] } ?? []) { item in
                            MapMarker(coordinate: item.coordinate, tint: themeManager.theme.color)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(.separator), lineWidth: 0.5)
                        )
                        .allowsHitTesting(false)

                        if let name = pendingName {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(themeManager.theme.color)
                                Text(name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        HStack {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.5f, %.5f", lat, lon))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("addlocation.section.preview")
                }

                // Remove button
                Section {
                    Button(role: .destructive) {
                        showRemoveConfirm = true
                    } label: {
                        Label("addlocation.remove", systemImage: "trash")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .navigationTitle("addlocation.title")
        .navigationBarTitleDisplayMode(.inline)
        .tint(themeManager.theme.color)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    commitSelection()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.theme.color)
            }
        }
        .onAppear {
            // Pre-populate with existing selection
            if let existingLat = selectedLatitude, let existingLon = selectedLongitude {
                pendingLatitude = existingLat
                pendingLongitude = existingLon
                pendingName = selectedLocationName
                let coord = CLLocationCoordinate2D(latitude: existingLat, longitude: existingLon)
                region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapAnnotation = IdentifiableCoordinate(coordinate: coord)
            }

            // Start location manager
            locationManager.onLocationUpdate = { coordinate, name in
                selectCoordinate(coordinate, name: name)
                isLocatingUser = false
            }
            locationManager.onError = {
                isLocatingUser = false
            }
        }
        .confirmationDialog(
            "addlocation.remove.confirm.title",
            isPresented: $showRemoveConfirm,
            titleVisibility: .visible
        ) {
            Button("addlocation.remove", role: .destructive) {
                clearSelection()
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("addlocation.remove.confirm.message")
        }
    }

    // MARK: - Actions

    private func requestCurrentLocation() {
        isLocatingUser = true
        locationManager.requestLocation()
    }

    private func selectMapItem(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        let name = item.name ?? formatAddress(item) ?? String(localized: "addlocation.unknown")
        selectCoordinate(coordinate, name: name)
        searchText = ""
        searchService.clear()
    }

    private func selectCoordinate(_ coordinate: CLLocationCoordinate2D, name: String?) {
        pendingLatitude = coordinate.latitude
        pendingLongitude = coordinate.longitude
        pendingName = name

        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapAnnotation = IdentifiableCoordinate(coordinate: coordinate)
        }
    }

    private func clearSelection() {
        pendingLatitude = nil
        pendingLongitude = nil
        pendingName = nil
        mapAnnotation = nil
    }

    private func commitSelection() {
        selectedLatitude = pendingLatitude
        selectedLongitude = pendingLongitude
        selectedLocationName = pendingName
    }

    private func formatAddress(_ item: MKMapItem) -> String? {
        let p = item.placemark
        let parts = [p.locality, p.administrativeArea, p.country].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

// MARK: - Identifiable Coordinate

struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Note Location Manager (CLLocationManager wrapper)

final class NoteLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onLocationUpdate: ((CLLocationCoordinate2D, String?) -> Void)?
    var onError: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            onError?()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            onError?()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            onError?(); return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let placemark = placemarks?.first
            let parts = [
                placemark?.name,
                placemark?.locality,
                placemark?.administrativeArea
            ].compactMap { $0 }
            let name = parts.isEmpty ? nil : parts.prefix(2).joined(separator: ", ")
            DispatchQueue.main.async {
                self?.onLocationUpdate?(location.coordinate, name)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.onError?()
        }
    }
}
