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
    @IBOutlet weak var walkingSpeedLabel: UILabel!
    
    @IBOutlet weak var completeModal: WalkingCompleteModalView!

    @IBOutlet weak var whiteOverlayView: UIView!
    @IBOutlet weak var countDownLabel: UILabel!

    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var startingCoordinate: CLLocationCoordinate2D?
    private var boundary: [CLLocationCoordinate2D] = []
    private var startTime: Date?
    private var initialCountDownTimer: Timer?
    private var returnToCurrentLocationTimer: Timer?
    private var walkingTimer: Timer?
    private var captureTimer: Timer?
    private var elapsedSeconds: Int = 0
    private var isStarted: Bool = false
    private var isFinished: Bool = false
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private let userNotiCenter = UNUserNotificationCenter.current()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTimeLabel()
        setLocationManager()
        setMapView()
        completeModal.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTrackingDisabled()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountDown()
    }
    
    // MARK: - IBActions
    @IBAction func didTapQuitButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup
    func setTimeLabel() {
        walkingTimeLabel.textColor = .white
        walkingTimeLabel.backgroundColor = .black.withAlphaComponent(0.7)
        walkingTimeLabel.layer.cornerRadius = 10
        walkingTimeLabel.clipsToBounds = true
        
        walkingSpeedLabel.layer.cornerRadius = 10
        walkingSpeedLabel.clipsToBounds = true
    }
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        getLocationUsagePermission()
    }

    func setMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        mapView.showsCompass = false
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsLargeContentViewer = false
        mapView.setCameraZoomRange(.init(maxCenterCoordinateDistance: 1000), animated: false)
        viewCurrentLocation()
    }

    // MARK: - Timer functions
    @objc
    func countDown() {
        if let text = countDownLabel.text,
           let count = Int(text),
           count > 1 {
            countDownLabel.text = "\(count - 1)"
            feedbackGenerator.notificationOccurred(.success)
        } else {
            whiteOverlayView.isHidden = true
            initialCountDownTimer?.invalidate()
            initialCountDownTimer = nil
            startWalking()
        }
    }

    @objc
    func viewCurrentLocation() {
        mapView.setUserTrackingMode(.followWithHeading, animated: false)
    }

    @objc
    func checkIsActive() {
        if UIApplication.shared.applicationState == .active {
            captureTimer?.invalidate()
            captureTimer = nil
            completeModal.imageView.image = mapView.takeCapture()
            completeModal.isHidden = false
        }
    }

    @objc
    func updateWalkingTimeLabel() {
        self.elapsedSeconds += 1
        self.walkingTimeLabel.text = "      \(Int(exactly: self.elapsedSeconds / 3600)!)h \(Int(exactly: self.elapsedSeconds / 60)!)m"
    }
    
    // MARK: - Helpers
    func startCountDown() {
        self.locationManager.startUpdatingLocation()
        initialCountDownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(countDown),
            userInfo: nil,
            repeats: true
        )
        feedbackGenerator.notificationOccurred(.success)
    }

    func startWalking() {
        self.isStarted = true
        self.startTime = Date()
        self.walkingTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateWalkingTimeLabel),
            userInfo: nil,
            repeats: true
        )
        feedbackGenerator.notificationOccurred(.success)
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

    func getLocationUsagePermission() {
        let authorizedStatus: CLAuthorizationStatus = self.locationManager.authorizationStatus
        if authorizedStatus != .authorizedAlways,
           authorizedStatus != .authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }

    func setTrackingDisabled() {
        isFinished = true
        mapView.setUserTrackingMode(.none, animated: false)
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
        returnToCurrentLocationTimer?.invalidate()
        walkingTimer?.invalidate()
    }

    func moveCameraToCenterOfPolygon(with polygon: MKPolygon) {
        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 0), animated: true)
        mapView.visibleMapRect = polygon.boundingMapRect
        if polygon.boundingMapRect.width < polygon.boundingMapRect.height {
            mapView.region.span.longitudeDelta = mapView.region.span.longitudeDelta * 2
        } else {
            mapView.region.span.latitudeDelta = mapView.region.span.latitudeDelta * 1.2
        }
        feedbackGenerator.notificationOccurred(.success)
    }

    func showAlert() {
        if isFinished { return }
        setTrackingDisabled()
        let alert = UIAlertController(title: "너무 빨라용", message: "초속 3미터 이하로 걸어주세요", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(action)
        present(alert, animated: true)
        feedbackGenerator.notificationOccurred(.warning)
        requestSendTooFastNoti()
    }
    
    // MARK: - Send notification
    func requestSendTooFastNoti() {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "⚠️ 과속 알림!"
        notiContent.body = "초속 3미터보다 빠르게 산책하면 안됩니다."
        notiContent.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notiContent,
            trigger: nil
        )
        
        userNotiCenter.add(request) { (error) in
            print(#function, error?.localizedDescription ?? "")
        }
    }
    
    func requestSendFinishNoti() {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "✅ 산책 완료!"
        notiContent.body = "산책 구역을 확인하세요!"
        notiContent.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notiContent,
            trigger: nil
        )
        
        userNotiCenter.add(request) { (error) in
            print(#function, error?.localizedDescription ?? "")
        }
    }

    // MARK: - Draw on mapview
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
        // 이전 좌표와 2미터 이상 차이 날 때 그리기
        if distacne < 2 { return }
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
              startTime.timeIntervalSinceNow < -60 else {
            return
        }
        
        let point1 = CLLocationCoordinate2DMake(startingCoordinate.latitude, startingCoordinate.longitude)
        let point2 = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let distacne: CLLocationDistance = MKMapPoint(point1).distance(to: MKMapPoint(point2))
        
        // 시작 지점에서 3미터 미만으로 가까워졌을 때
        if distacne > 10 { return }
        setTrackingDisabled()
        
        let polygon = MKPolygon(
            coordinates: self.boundary,
            count: self.boundary.count
        )
        mapView.addOverlay(polygon)
        moveCameraToCenterOfPolygon(with: polygon)
        let timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(checkIsActive),
            userInfo: nil,
            repeats: true
        )
        captureTimer = timer
        requestSendFinishNoti()
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
        print(location.speed)
        if location.speed < 0 || !isStarted { return }
        walkingSpeedLabel.text = "\(String(format: "%.2f", location.speed))m/s"
//        if location.speed > 3 {
//            print("너무 빠름")
//            showAlert()
//        }

        addPolyline(with: location)
        checkPolygonIsMade(with: location)
        if self.startingCoordinate == nil {
            self.startingCoordinate = location.coordinate
            self.boundary.append(location.coordinate)
        }
    }
}

// MARK: - WalkingCompleteModalViewDelegate
extension MapViewController: WalkingCompleteModalViewDelegate {
    func didTapCancle() {
        completeModal.isHidden = true
    }

    func didTapSave() {
        pushViewControllerWithStoryBoard(.login)
    }
}
