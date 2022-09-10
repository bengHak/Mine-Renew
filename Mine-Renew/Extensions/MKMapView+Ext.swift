//
//  MKMapView+Ext.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/10.
//

import MapKit

extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius
    )
    setRegion(coordinateRegion, animated: true)
  }
}
