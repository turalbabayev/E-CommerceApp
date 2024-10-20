//
//  Helper.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import Foundation
import UIKit

class Helper{
    func addShadowToView(view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor  // Gölgenin rengi
        view.layer.shadowOpacity = 0.1  // Gölgenin opaklığı (0 ile 1 arasında)
        view.layer.shadowOffset = CGSize(width: 0, height: 2)  // Gölgenin ofseti (yatay ve dikey kayma)
        view.layer.shadowRadius = 4  // Gölgenin yayılma mesafesi
        view.layer.masksToBounds = false  // Gölgenin görünmesi için gerekli
    }
    
    func addDashedBorder(to view: UIView) {
        let shapeLayer = CAShapeLayer()
        
        // Çizgilerin yapısı: birimlerin boyutları
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.lineDashPattern = [6, 4] // 6 birim çizgi, 4 birim boşluk
        
        // Köşeleri yuvarlatmak için
        shapeLayer.fillColor = nil
        shapeLayer.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 10).cgPath
        
        // View'un boyutuna göre şeklin ayarlanması için
        shapeLayer.frame = view.bounds
        
        // Layer'ı view'a ekle
        view.layer.addSublayer(shapeLayer)
    }
    
    func changeTabBarColor(itemAppearance: UITabBarItemAppearance){
        //Seçili Durum
        itemAppearance.selected.iconColor = UIColor(named: "appPrimary")
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(named: "appPrimary")!]
        itemAppearance.selected.badgeBackgroundColor = UIColor.red
        //Seçili Olmayan Durum
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
    }
    
}
