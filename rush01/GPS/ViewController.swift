//
//  ViewController.swift
//  GPS
//
//  Created by Ivan SELETSKYI on 10/13/18.
//  Copyright © 2018 Ivan SELETSKYI. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire
import MapKit

enum Location {
    case startLocation
    case destinationLocation
}

private let googleAPIKey = ""

class ViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var firstLocation: UITextField!
    @IBOutlet weak var secondLocation: UITextField!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var switchBar: UISwitch!
    
    var polyline: GMSPolyline?
    var saveTextField: UITextField!
    var locationStart: CLLocationCoordinate2D?
    var locationEnd: CLLocationCoordinate2D?
    var currentLocation: CLLocation!
    var rememberLocation: CLLocation!
    
    var markerArr: [GMSMarker] = [
        GMSMarker(),
        GMSMarker()
    ]
    
    var isRegularModeEnabled: Bool = true {
        willSet {
            if newValue == true {
                googleMaps.mapStyle = try? GMSMapStyle(jsonString: regularMode)
                polyline?.strokeColor = .darkGray
            } else {
                googleMaps.mapStyle = try? GMSMapStyle(jsonString: darkMode)
                polyline?.strokeColor = .yellow
            }
        }
    }
    
    var isHiddenSearchBar: Bool = false
    
    var searchBarFrame: CGRect!
    
    var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 50
        locationManager.startMonitoringSignificantLocationChanges()
        
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(manageSearchBar))
        
        searchBarFrame = searchBarView.frame
        
        locationManager.delegate = self
        googleMaps.delegate = self
        googleMaps.mapStyle = try? GMSMapStyle(jsonString: regularMode)
        if let theLocation = locationManager.location {
            let theCamera = GMSCameraPosition.camera(withTarget: theLocation.coordinate, zoom: 15.0)
            if googleMaps.isHidden {
                googleMaps.isHidden = false
                googleMaps.camera = theCamera
            } else {
                googleMaps.animate(to: theCamera)
            }
        }
    }
    
    @IBAction func manageSearchBar() {
        if isHiddenSearchBar {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.searchBarView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard let theFrame = self?.searchBarFrame else { return }
                self?.searchBarView.transform = CGAffineTransform(translationX: 0, y: -theFrame.height)
            }, completion: nil)
        }
        isHiddenSearchBar = !isHiddenSearchBar
    }
    
    func createMarker(titleMarker: String, titleAddress: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees, indexMarker: Int) {
        self.polyline?.map = nil
        let marker = markerArr[indexMarker]
        marker.map = googleMaps
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        if titleAddress != nil {
            marker.snippet = titleAddress
        }
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        firstLocation.text = ""
        secondLocation.text = ""
        locationStart = nil
        locationEnd = nil
        
        createMarker(titleMarker: "Your point", titleAddress: nil, latitude: coordinate.latitude, longitude: coordinate.longitude, indexMarker: 1)
        rememberLocation = currentLocation
        let theCamera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 16.0)
        googleMaps.animate(to: theCamera)
        let theAlertController = UIAlertController(title: "Route to this point?", message: "Do you want to start trip to this point?", preferredStyle: .alert)
        let theFirstAction = UIAlertAction(title: "No", style: .cancel, handler: { (theAlertAction) in
            let theMarker = self.markerArr[1]
            theMarker.map = nil
            let theCoordinate = self.rememberLocation.coordinate
            DispatchQueue.main.async {
                let theGoBackCamera = GMSCameraPosition.camera(withTarget: theCoordinate, zoom: 15.0)
                self.googleMaps.animate(to: theGoBackCamera)
            }
        })
        let theSecondAction = UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (theAlertAction) in
            guard let theStartPoint = self?.markerArr[0] else { return }
            guard let theCoordinate = self?.rememberLocation.coordinate else { return }
            let theStartCoordinate = theCoordinate
            theStartPoint.map = nil
            DispatchQueue.main.async {
                self?.createMarker(titleMarker: "Your place", titleAddress: nil, latitude: theCoordinate.latitude, longitude: theCoordinate.longitude, indexMarker: 0)
                self?.drawPath(coordStartLocation: theStartCoordinate, coordEndLocation: coordinate)
            }
        })
        theAlertController.addAction(theFirstAction)
        theAlertController.addAction(theSecondAction)
        present(theAlertController, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveTextField = textField
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func switchTheme(_ sender: UISwitch) {
        isRegularModeEnabled = sender.isOn
    }
    
    func drawPath(coordStartLocation: CLLocationCoordinate2D?, coordEndLocation: CLLocationCoordinate2D?)
    {
        polyline?.map = nil
        guard let theStartCoordinate = coordStartLocation,
                    let theEndCoordinate = coordEndLocation
                    else { return }
        let theOrigin = "\(theStartCoordinate.latitude),\(theStartCoordinate.longitude)"
        let theDestination = "\(theEndCoordinate.latitude),\(theEndCoordinate.longitude)"
        
        let theURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(theOrigin)&destination=\(theDestination)&mode=driving&key=\(googleAPIKey)"
        
        if !isHiddenSearchBar {
            manageSearchBar()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(theURL).responseJSON { [weak self] (aResponse) in
            let theJSON = try? JSON(data: aResponse.data!)
            let theRoutes = theJSON!["routes"].arrayValue
            guard theRoutes.count != 0 else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let theCamera = GMSCameraPosition.camera(withTarget: theStartCoordinate,
                            zoom: 15.0)
                self?.googleMaps.animate(to: theCamera)
                self?.showAlertView(title: "Error", message: "No paths found")
                return
            }
            guard let theRegularMode = self?.switchBar.isOn else { return }
            var theDistance = ""
            var theDuration = ""
            for route in theRoutes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                guard let thePoints = routeOverviewPolyline?["points"]?.stringValue
                            else { continue }
                let theLegs = route["legs"][0].dictionary
                if let theDistanceInfo = theLegs!["distance"] {
                    theDistance = theDistanceInfo["text"].stringValue
                }
                if let theDurationInfo = theLegs!["duration"] {
                    theDuration = theDurationInfo["text"].stringValue
                }
                let thePath = GMSPath(fromEncodedPath: thePoints)
                let thePolyline = GMSPolyline(path: thePath)
                thePolyline.strokeWidth = 5
                thePolyline.strokeColor = theRegularMode ? .darkGray : .yellow
                thePolyline.map = self?.googleMaps
                self?.polyline = thePolyline
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let theDetailedInfo = UIAlertController(title: "Driving Info",
                            message: "\nRoad distance is \(theDistance)" +
                            "\n\nRoad duration is \(theDuration)" +
                            "\n\nHave a nice trip!",
                            preferredStyle: .alert)
                let theAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                theDetailedInfo.addAction(theAction)
                self?.present(theDetailedInfo, animated: true, completion: nil)
                let theBounds = GMSCoordinateBounds(coordinate: theStartCoordinate,
                            coordinate: theEndCoordinate)
                let theCameraUpdate = GMSCameraUpdate.fit(theBounds, withPadding: 130.0)
                self?.googleMaps.animate(with: theCameraUpdate)
            }
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                        didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            googleMaps.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            googleMaps.isMyLocationEnabled = true
            googleMaps.settings.myLocationButton = true
            googleMaps.settings.compassButton = true
            googleMaps.settings.zoomGestures = true
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
}

// MARK: - GMS Auto Complete Delegate, for autocomplete search location

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let thePlaceCamera = GMSCameraPosition(target: place.coordinate, zoom: 16.5, bearing: 1.0, viewingAngle: 0.0)
        saveTextField.text = place.name
        if saveTextField.tag == 0 {
            locationStart = place.coordinate
        } else {
            locationEnd = place.coordinate
        }
        self.dismiss(animated: true, completion: { [weak self] in
            DispatchQueue.main.async {
                self?.googleMaps.animate(to: thePlaceCamera)
                guard let theTextFieldTag = self?.saveTextField.tag else { return }
                self?.createMarker(titleMarker: place.name, titleAddress: place.formattedAddress, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, indexMarker: theTextFieldTag)
                if self?.saveTextField.tag == 1 {
                    self?.drawPath(coordStartLocation: self?.locationStart, coordEndLocation: self?.locationEnd)
                }
            }
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension UIViewController {
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

private let darkMode = "[{\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#212121\"}]},{\"elementType\":\"labels.icon\",\"stylers\":[{\"visibility\":\"off\"}]},{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#757575\"}]},{\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#212121\"}]},{\"featureType\":\"administrative\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#757575\"}]},{\"featureType\":\"administrative.country\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#9e9e9e\"}]},{\"featureType\":\"administrative.land_parcel\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"administrative.locality\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#bdbdbd\"}]},{\"featureType\":\"poi\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#757575\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#181818\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#616161\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#1b1b1b\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#2c2c2c\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8a8a8a\"}]},{\"featureType\":\"road.arterial\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#373737\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#3c3c3c\"}]},{\"featureType\":\"road.highway.controlled_access\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#4e4e4e\"}]},{\"featureType\":\"road.local\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#616161\"}]},{\"featureType\":\"transit\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#757575\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#000000\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#3d3d3d\"}]}]"

private let regularMode = "[{\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#ebe3cd\"}]},{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#523735\"}]},{\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#f5f1e6\"}]},{\"featureType\":\"administrative\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#c9b2a6\"}]},{\"featureType\":\"administrative.land_parcel\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#dcd2be\"}]},{\"featureType\":\"administrative.land_parcel\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#ae9e90\"}]},{\"featureType\":\"landscape.natural\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#dfd2ae\"}]},{\"featureType\":\"poi\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#dfd2ae\"}]},{\"featureType\":\"poi\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#93817c\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#a5b076\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#447530\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#f5f1e6\"}]},{\"featureType\":\"road.arterial\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#fdfcf8\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#f8c967\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#e9bc62\"}]},{\"featureType\":\"road.highway.controlled_access\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#e98d58\"}]},{\"featureType\":\"road.highway.controlled_access\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#db8555\"}]},{\"featureType\":\"road.local\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#806b63\"}]},{\"featureType\":\"transit.line\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#dfd2ae\"}]},{\"featureType\":\"transit.line\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8f7d77\"}]},{\"featureType\":\"transit.line\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#ebe3cd\"}]},{\"featureType\":\"transit.station\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#dfd2ae\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry.fill\",\"stylers\":[{\"color\":\"#b9d3c2\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#92998d\"}]}]"








