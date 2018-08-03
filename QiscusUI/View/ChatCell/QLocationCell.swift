//
//  QLocationCell.swift
//  Alamofire
//
//  Created by UziApel on 27/06/18.
//

import UIKit
import MapKit
import SwiftyJSON
import QiscusCore

class QLocationCell: BaseChatCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressView: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(QLocationCell.openMap))
        self.mapView.addGestureRecognizer(tapRecognizer)
    }
     override func bindDataToView() {
        if let data = self.comment.payload as? PayloadLocation {
            self.lbName.text = self.comment.username
            self.lbTime.text = self.comment.timestamp
            self.addressView.text = data.address
            
            let lat = CLLocationDegrees(data.latitude!)
            let long = CLLocationDegrees(data.longitude!)
            
            let center = CLLocationCoordinate2DMake(lat, long)
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            let newPin = MKPointAnnotation()
            newPin.coordinate = center
            self.mapView.setRegion(region, animated: false)
            self.mapView.addAnnotation(newPin)
        }
//
//
        
        

        if self.comment.isMyComment {
            DispatchQueue.main.async {
                self.rightConstraint.isActive = true
                self.leftConstraint.isActive = false
            }
            lbName.textAlignment = .right
        }else {
            DispatchQueue.main.async {
                self.leftConstraint.isActive = true
                self.rightConstraint.isActive = false
            }
            lbName.textAlignment = .left
        }
    }
    
    @objc func openMap(){
//        let payload = JSON(parseJSON: self.comment.additionalData)
        
        if let data = self.comment.payload as? PayloadLocation {
            let latitude: CLLocationDegrees = data.latitude!
            let longitude: CLLocationDegrees = data.longitude!
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = data.name
            mapItem.openInMaps(launchOptions: options)
        }
    }

    
}
