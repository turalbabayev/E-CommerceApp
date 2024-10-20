//
//  UIView+Extension.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 11.10.2024.
//

import UIKit

extension UIView{
   @IBInspectable var cornerRadius:CGFloat{
       get{ return self.cornerRadius }
        set{
            self.layer.cornerRadius = newValue
        }
    }
}

extension UITextField{
    
    func setLeftIcon(_ icon: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 15, y: 5, width: 20, height: 20))
        iconView.image = icon.withRenderingMode(.alwaysTemplate)  // Rendering Mode Template
        iconView.tintColor = .lightGray
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        iconContainerView.addSubview(iconView)
        
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func setRightIcon(_ icon: UIImage, target: Any, action: Selector) {
        let iconView = UIImageView(frame: CGRect(x: 15, y: 5, width: 20, height: 20))
        iconView.image = icon.withRenderingMode(.alwaysTemplate)  // Rendering Mode Template
        iconView.tintColor = .lightGray
        iconView.isUserInteractionEnabled = true // İkonun tıklanabilir olmasını sağla

        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        iconView.addGestureRecognizer(tapGesture)

        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        iconContainerView.addSubview(iconView)
        
        rightView = iconContainerView
        rightViewMode = .always
    }
    
    func setupBorderStyle() {
        // Başlangıçta kenar çizgisi olmayacak (border width ve color sıfırlanıyor)
        self.layer.cornerRadius = 12
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        self.layer.borderWidth = 0
        self.layer.borderColor = .none
    }

    func updateBorder(isEditing: Bool) {
        if isEditing {
            // Yazı yazılmaya başlandığında turuncu kenarlık ekle
            self.layer.borderWidth = 1.5
            self.layer.borderColor = UIColor.orange.cgColor
            updateIconColors(isEditing: isEditing)
        } else {
            // Yazı yazma bittiğinde, text varsa kenarlık turuncu kalsın, yoksa kaldır
            if let text = self.text, !text.isEmpty {
                // Text doluysa turuncu kenarlık kalsın
                self.layer.borderWidth = 1.5
                self.layer.borderColor = UIColor.orange.cgColor
                updateIconColors(isEditing: isEditing)
            } else {
                // Text boşsa kenarlık kaldır
                self.layer.borderWidth = 0
                self.layer.borderColor = UIColor.clear.cgColor
                updateIconColors(isEditing: isEditing)
            }
        }
    }
    
    func updateIconColors(isEditing: Bool){
        
        if let leftIconView = leftView?.subviews.first as? UIImageView {
            leftIconView.tintColor = isEditing ? UIColor.orange : UIColor.lightGray
        }
        
        if let rightIconView = rightView?.subviews.first as? UIImageView {
            rightIconView.tintColor = isEditing ? UIColor.black : UIColor.lightGray
        }
    }

}

