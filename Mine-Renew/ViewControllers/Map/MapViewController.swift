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
    @IBOutlet weak var walkingTimeLabel: UILabel!

    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var startingCoordinate: CLLocationCoordinate2D?
    private var boundary: [CLLocationCoordinate2D] = []
    private var startTime: Date?
    private var returnToCurrentLocationTimer: Timer?
    private var walkingTimer: Timer?
    private var elapsedSeconds: Int = 0
    private var isFinished: Bool = false
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTimeLabel()
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
        self.walkingTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateWalkingTimeLabel),
            userInfo: nil,
            repeats: true
        )
    }
    
    // MARK: - IBActions
    @IBAction func didTapQuitButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Helpers
    func setTimeLabel() {
        walkingTimeLabel.textColor = .white
        walkingTimeLabel.backgroundColor = .black.withAlphaComponent(0.7)
        walkingTimeLabel.layer.cornerRadius = 10
        walkingTimeLabel.clipsToBounds = true
    }
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
        mapView.showsCompass = false
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
        guard let previousCoordinate = self.boundary.last else {
            return
        }
        let longtitude: CLLocationDegrees = location.coordinate.longitude
        let latitude:CLLocationDegrees = location.coordinate.latitude
        var points: [CLLocationCoordinate2D] = []
        let point1 = CLLocationCoordinate2DMake(previousCoordinate.latitude, previousCoordinate.longitude)
        let point2 = CLLocationCoordinate2DMake(latitude, longtitude)
        let distacne: CLLocationDistance = MKMapPoint(point1).distance(to: MKMapPoint(point2))
        print("이전 좌표와의 거리: \(Int(distacne))m")
        if distacne > 20 {
            return
        }
        points.append(point1)
        points.append(point2)
        let lineDraw = MKPolyline(coordinates: points, count:points.count)
        self.mapView.addOverlay(lineDraw)
        self.boundary.append(location.coordinate)
    }

    /// 3분 이상 산착했을 때 부터 폴리곤을 확인한다.
    func checkPolygonIsMade(with location: CLLocation) {
        guard !isFinished,
              let startingCoordinate = startingCoordinate,
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
        
        self.boundary.append(CLLocationCoordinate2D(latitude: 36.7394, longitude: 127.17058))
        let polygon = MKPolygon(
            coordinates: self.boundary,
            count: self.boundary.count
        )
        mapView.addOverlay(polygon)
        moveCameraToCenterOfPolygon(with: polygon)
        isFinished.toggle()
        setTrackingDisabled()
    }

    func setTrackingDisabled() {
        mapView.setUserTrackingMode(.none, animated: false)
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
        returnToCurrentLocationTimer?.invalidate()
        walkingTimer?.invalidate()
    }

    func moveCameraToCenterOfPolygon(with polygon: MKPolygon) {
        mapView.visibleMapRect = polygon.boundingMapRect
    }

    @objc
    func updateWalkingTimeLabel() {
        self.elapsedSeconds += 1
        self.walkingTimeLabel.text = "      \(Int(exactly: self.elapsedSeconds / 3600)!)h \(Int(exactly: self.elapsedSeconds / 60)!)m"
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = AppColor.junction_green.color
            renderer.lineWidth = 5.0
            renderer.alpha = 1.0
            return renderer
        }
        
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = AppColor.junction_green.color
            polygonView.fillColor = AppColor.junction_second_green.color.withAlphaComponent(0.5)
            polygonView.lineWidth = 5.0
            return polygonView
        }
        
        print("can't draw polyline")
        return MKOverlayRenderer()
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        guard !isFinished,
              mapView.userTrackingMode != .followWithHeading else {
            return
        }
        setReturnTimer()
    }
}

// MARK: - CLLocationManagerDelegate
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
            self.boundary.append(location.coordinate)
        }
    }
}
