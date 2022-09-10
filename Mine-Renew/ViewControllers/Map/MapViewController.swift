//
//  MapViewController.swift
//  Mine-Renew
//
//  Created by 고병학 on 2022/09/10.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {
    // MARK: - UI properties
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var previousCoordinate: CLLocationCoordinate2D?
    private var startingCoordinate: CLLocationCoordinate2D?
    private var boundary: [CLLocationCoordinate2D] = []
    private var startTime: Date?
    private var endTime: Date?
    private var returnToCurrentLocationTimer: Timer?
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        setLocationManager()
        setMapView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startTime = Date()
    }
    
    // MARK: - IBActions
    @IBAction func didTapQuitButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        getLocationUsagePermission()
    }

    func getLocationUsagePermission() {
        let authorizedStatus: CLAuthorizationStatus = self.locationManager.authorizationStatus
        if authorizedStatus != .authorizedAlways,
           authorizedStatus != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }

    func setMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        viewCurrentLocation()
    }

    @objc
    func viewCurrentLocation() {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }

    func setReturnTimer() {
        if let previousTimer = self.returnToCurrentLocationTimer {
            previousTimer.invalidate()
            self.returnToCurrentLocationTimer = nil
        }

        let timer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(viewCurrentLocation),
            userInfo: nil,
            repeats: false
        )
        self.returnToCurrentLocationTimer = timer
    }

    func addPolyline(with location: CLLocation) {
        guard let previousCoordinate = self.previousCoordinate else {
            return
        }
        let longtitude: CLLocationDegrees = location.coordinate.longitude
        let latitude:CLLocationDegrees = location.coordinate.latitude
        var points: [CLLocationCoordinate2D] = []
        let point1 = CLLocationCoordinate2DMake(previousCoordinate.latitude, previousCoordinate.longitude)
        let point2 = CLLocationCoordinate2DMake(latitude, longtitude)
        let distacne: CLLocationDistance = MKMapPoint(point1).distance(to: MKMapPoint(point2))
        print("이전 좌표와의 거리: \(Int(distacne))m")
        if distacne < 50 {
            return
        }
        points.append(point1)
        points.append(point2)
        let lineDraw = MKPolyline(coordinates: points, count:points.count)
        self.mapView.addOverlay(lineDraw)
    }

    /// 3분 이상 산착했을 때 부터 폴리곤을 확인한다.
    func checkPolygonIsMade(with location: CLLocation) {
        guard let startingCoordinate = startingCoordinate,
              let startTime = startTime,
              startTime.timeIntervalSinceNow < -180 else {
            return
        }
        
        let point1 = CLLocationCoordinate2DMake(startingCoordinate.latitude, startingCoordinate.longitude)
        let point2 = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let distacne: CLLocationDistance = MKMapPoint(point1).distance(to: MKMapPoint(point2))
        
        if distacne > 20 {
            return
        }
        
        let polygon = MKPolygon(
            coordinates: self.boundary,
            count: self.boundary.count
        )
        mapView.addOverlay(polygon)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline else {
            print("can't draw polyline")
            return MKOverlayRenderer()
        }

        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .orange
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0
        
        return renderer
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        guard mapView.userTrackingMode != .followWithHeading else {
            return
        }
        setReturnTimer()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("not determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorized always")
        case .authorizedWhenInUse:
            print("authorized when in use")
        @unknown default:
            print("unknown")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        addPolyline(with: location)
        checkPolygonIsMade(with: location)
        if self.startingCoordinate == nil {
            self.startingCoordinate = location.coordinate
        }
        self.previousCoordinate = location.coordinate
    }
}
