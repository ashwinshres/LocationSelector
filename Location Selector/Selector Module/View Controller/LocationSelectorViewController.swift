//
//  LocationSelectorViewController.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class LocationSelectorViewController: UIViewController {

    @IBOutlet var backBtn: UIButton!
    @IBOutlet var selectLocationBtn: UIButton!
    @IBOutlet var clearBtn: UIButton!
    @IBOutlet var gpsBtn: UIButton!
    
    @IBOutlet var mapView: MapView!
    @IBOutlet var addressTxtField: UITextField!
    
    @IBOutlet var autoCompleteTableView: UITableView!
    
    @IBOutlet var clearBtnWidth: NSLayoutConstraint!
    @IBOutlet var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    
    weak var delegate: MapViewControllerDelegate?
    weak var dataSource: MapViewControllerDataSource?
    
    var selectedGMSPlace: GMSPlace? {
        didSet {
            selectLocationBtn.isEnabled = selectedGMSPlace.hasValue
            selectLocationBtn.alpha = selectedGMSPlace.hasValue ? 1.0 : 0.5
        }
    }
    
    var addressSuggestions =  [GMSAutocompletePrediction]()
    let locationMgr = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        populateView()
    }
    
    private func setUpView() {
        setUpUI()
        setUpLocationService()
        setUpAutoCompleteTable()
        setUpMapView()
        setUpAddressTxtField()
        updateClearBtnView()
    }
    
    private func populateView() {
        if let selectedGMSPlace = selectedGMSPlace {
            addAnnotationsToMap(for: selectedGMSPlace)
            setAddress(for: selectedGMSPlace)
        }
    }
    
    private func setAddress(for place: GMSPlace) {
        addressTxtField.text = place.formattedAddress
    }
    
    private func addAnnotationsToMap(for place: GMSPlace) {
        mapView.removeAllMarkers()
        let marker = Marker(place: place, with: getMarkerImage(), with: getMarkerSize())
        mapView.createMarkers(markers: [marker])
        mapView.centerMapView(in: place)
    }
    
    private func updateSuggestionTable() {
        autoCompleteTableView.isHidden = addressSuggestions.isEmpty
        autoCompleteTableView.reloadData()
        tableViewHeight.constant = CGFloat((addressSuggestions.count <= 4) ? addressSuggestions.count : 5) * 44.0
        view.layoutIfNeeded()
    }
    
    private func hasAddressTxtFieldText() -> Bool {
        return !(addressTxtField.text?.isEmpty ?? true)
    }
    
    private func updateClearBtnView() {
        clearBtn.isHidden = !hasAddressTxtFieldText()
        clearBtnWidth.constant = hasAddressTxtFieldText() ?  30.0 : 0.0
    }
    
    private func setUpLocationService() {
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        locationMgr.delegate = self
    }
    
}

extension LocationSelectorViewController {
    
    @IBAction func clearBtnClick(_ sender: UIButton) {
        addressTxtField.text = ""
        updateClearBtnView()
        mapView.removeAllMarkers()
    }
    
    @IBAction func gpsBtnClick(_ sender: UIButton) {
        view.endEditing(true)
        fetchGPSLocation()
    }
    
    @IBAction func onLocationSetBtnClick(_ sender: UIButton) {
        guard let place = selectedGMSPlace else {
   showAlertWithOkAndCancelHandler(LSConstants.strings.locationSelectionErrorString, okHandler: {}) {}
            return
        }
        delegate?.didSelect(location: place)
        delegate?.didClickClose(viewController: self)
    }
    
    @IBAction func backBtnClick(_ sender: UIButton) {
        delegate?.didClickClose(viewController: self)
    }
    
}

// MARK: - Google Maps Delegate Methods
extension LocationSelectorViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        reverseGeocodeLocation(coordinates: coordinate)
    }
    
}

extension LocationSelectorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateClearBtnView()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if textField == addressTxtField {
            addressSuggestions.removeAll()
            autoCompleteTableView.isHidden = true
            updateClearBtnView()
            if hasAddressTxtFieldText() {
                fetchAutoCompleteAddress(for: textField.text!)
            }
        }
    }
    
    func fetchAutoCompleteAddress(for subString: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.getAutocompleteArrayFor(subString: subString, callback: {
                [weak self] suggestedArray in
                guard let sSelf = self else { return }
                sSelf.addressSuggestions = suggestedArray
                sSelf.updateSuggestionTable()
            })
        })
    }
  
}

extension LocationSelectorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = addressSuggestions[indexPath.row].attributedFullText.string
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressTxtField.text = addressSuggestions[indexPath.row].attributedFullText.string
        autoCompleteTableView.isHidden = true
        getLocation(from: addressSuggestions[indexPath.row].placeID)
        addressTxtField.resignFirstResponder()
        view.layoutIfNeeded()
    }
    
}

// MARK: - Api calls
extension LocationSelectorViewController {
    
    func reverseGeocodeLocation(coordinates: CLLocationCoordinate2D) {
        LocationSelectorWebServiceCall.getAddress(for: coordinates) { [weak self] (address, error) in
            guard let sSelf = self else { return }
            if let error = error {
                sSelf.showAlertWithOkAndCancelHandler(error, okHandler: {}, cancelHandler: {})
                return
            }
            sSelf.selectedGMSPlace = address
            sSelf.populateView()
        }
    }
    
    func getAutocompleteArrayFor(subString: String?, callback: @escaping ([GMSAutocompletePrediction]) -> ()) {
        let subStr = (subString ?? "").replacingOccurrences(of: " ", with: "+")
        LocationSelectorWebServiceCall.getLocationSuggestions(from: subStr, with: dataSource?.countryComponent()) { (predictions, errorString) in
            if let _ = errorString  { return }
            let suggestionArray = predictions ?? []
            callback(suggestionArray)
        }
    }
    
    func getLocation(from placeId: String?) {
        guard let placeId = placeId else { return }
        LocationSelectorWebServiceCall.getLocation(from: placeId) {[weak self] (selectedPlace, error) in
            guard let sSelf = self else { return }
            if let error = error {
                sSelf.showAlertWithOkAndCancelHandler(error, okHandler: {}, cancelHandler: {})
                return
            }
            sSelf.selectedGMSPlace = selectedPlace
            sSelf.populateView()
        }
    }
 
}

extension LocationSelectorViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationCoOrdinates = locations.first?.coordinate else {
                return
        }
        reverseGeocodeLocation(coordinates: locationCoOrdinates)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    private func fetchGPSLocation() {
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch locationAuthorizationStatus {
        case .notDetermined:
            locationMgr.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationMgr.requestLocation()
            }
        case .restricted, .denied:
            alertLocationAccessNeeded()
        }
    }
    
    func alertLocationAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: LSConstants.strings.locationAccessTitleString ,
            message: LSConstants.strings.locationServiceAccessString,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: LSConstants.strings.cancel, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: LSConstants.strings.allowLocationAccessBtnTitle,
                                      style: .cancel,
                                      handler: { (alert) -> Void in
                                        UIApplication.shared.open(settingsAppURL,
                                                                  options: [:],
                                                                  completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension LocationSelectorViewController {
    
    func showAlertWithOkAndCancelHandler(_ message: String = "Something went wrong.\nPlease try again later.", okTitle: String = "Ok", okHandler: @escaping () -> (), cancelTitle: String = "Cancel", cancelHandler : @escaping () -> ()) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: self.dataSource?.appName() ??  LSConstants.strings.moduleTitle, message: message, preferredStyle: .alert)
            let okAction =  UIAlertAction(title: okTitle, style: .default){
                handler in
                okHandler()
            }
            alert.addAction(okAction)
            let cancelAction =  UIAlertAction(title: cancelTitle, style: .cancel){
                handler in
                cancelHandler()
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setUpAutoCompleteTable() {
        autoCompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        autoCompleteTableView.backgroundColor = UIColor.lightGray
        autoCompleteTableView.layer.borderColor = UIColor.lightGray.cgColor
        autoCompleteTableView.layer.borderWidth = 1.0
        autoCompleteTableView.layer.cornerRadius = 2.0
        autoCompleteTableView.layer.masksToBounds = true
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.delegate = self
    }
    
    private func setUpMapView() {
        mapView.delegate = self
        mapViewBottomConstraint.constant = isReguarSizeDevice() ? 0.0 : -44.0
    }
    
    private func setUpAddressTxtField() {
        addressTxtField.delegate = self
        addressTxtField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        addressTxtField.returnKeyType = .done
    }
    
    private func isReguarSizeDevice() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436, 2688, 1792, 1624:
                return false
            default:
                return true
            }
        }
        return true
    }
    
    private func setUpUI() {
        selectedGMSPlace = nil
        backBtn.setImage(dataSource?.imageForBackBtn() ?? LSConstants.images.backBtnImage, for: [])
        clearBtn.setImage(dataSource?.imageForClearBtn() ?? LSConstants.images.clearBtnImage, for: [])
        gpsBtn.setImage(dataSource?.imageForGpsBtn() ?? LSConstants.images.gpsBtnImage, for: [])
       selectLocationBtn.setTitle(dataSource?.titleForSelectLocationBtn() ?? LSConstants.strings.titleLocationString, for: .normal)
        mapView.defaultZoom = dataSource?.defaultZoomLevel() ?? LSConstants.mapView.zoomLevel
        view.backgroundColor = dataSource?.themeColor() ??  LSConstants.color.themeColor
        selectLocationBtn.backgroundColor = dataSource?.themeColor() ??  LSConstants.color.themeColor
        selectLocationBtn.setTitleColor(dataSource?.textFieldTextColor() ??  LSConstants.color.textFieldTxtColor, for: .normal)
        addressTxtField.textColor = dataSource?.textFieldTextColor() ??  LSConstants.color.textFieldTxtColor
    }
    
    private func getMarkerImage() -> UIImage {
        return dataSource?.imageForMarker() ??  LSConstants.images.markerImage
    }
    
    private func getMarkerSize() -> CGSize {
        return dataSource?.sizeForMarker() ??  LSConstants.size.markerSize
    }
    
}
