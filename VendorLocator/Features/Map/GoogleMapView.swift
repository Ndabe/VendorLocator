//
//  GoogleMapView.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import GoogleMaps
import SwiftUI

struct GoogleMapView: UIViewRepresentable {
    let vendors: [Vendor]
    let selectedVendor: Vendor?
    let onVendorSelected: (Vendor) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onVendorSelected: onVendorSelected)
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(
            latitude: -33.9249,
            longitude: 18.4241,
            zoom: 11
        )
        let options = GMSMapViewOptions()
        options.camera = camera
        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.updateMarkers(for: vendors, on: mapView)
        
        guard let selectedVendor else { return }
        
        let coordinate = CLLocationCoordinate2D(
            latitude: selectedVendor.coordinate.latitude,
            longitude: selectedVendor.coordinate.longitude
        )
        mapView.animate(to: GMSCameraPosition(target: coordinate, zoom: 15))
        mapView.selectedMarker = context.coordinator.markers[selectedVendor.id]
    }
    
    final class Coordinator: NSObject, GMSMapViewDelegate {
        var markers: [String: GMSMarker] = [:]
        private let onVendorSelected: (Vendor) -> Void
        
        init(onVendorSelected: @escaping (Vendor) -> Void) {
            self.onVendorSelected = onVendorSelected
        }
        
        func updateMarkers(for vendors: [Vendor], on mapView: GMSMapView) {
            let vendorIDs = Set(vendors.map(\.id))
            
            for (id, marker) in markers where !vendorIDs.contains(id) {
                marker.map = nil
                markers[id] = nil
            }
            
            for vendor in vendors {
                let marker = markers[vendor.id] ?? GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: vendor.coordinate.latitude,
                    longitude: vendor.coordinate.longitude
                )
                marker.title = vendor.name
                marker.snippet = vendor.address
                marker.userData = vendor
                marker.map = mapView
                markers[vendor.id] = marker
            }
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            guard let vendor = marker.userData as? Vendor else { return false }
            
            onVendorSelected(vendor)
            return false
        }
    }
}
