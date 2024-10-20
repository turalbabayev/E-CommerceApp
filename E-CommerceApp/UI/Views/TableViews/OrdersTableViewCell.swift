//
//  OrdersTableViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import UIKit
import Kingfisher

class OrdersTableViewCell: UITableViewCell {
    @IBOutlet weak var backgroundViewCell: UIView!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var reviewButton: UIButton!
    
    var rateButtonAction: (() -> Void)?
    var orderDetailButtonAction: (() -> Void)?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reviewButton.cornerRadius = 3
        reviewButton.backgroundColor = .none
        reviewButton.layer.borderColor = UIColor(named: "appPrimary")?.cgColor
        reviewButton.layer.borderWidth = 0.2
    }
    
    func configure(with product: ProductCart, orderDateValue: Date) {
        productPrice.text = "₺\(product.fiyat ?? 0)"  // Ürün fiyatı
        

        // Sipariş tarihini formatlayıp göstermek
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"  // Tarih formatı
        orderDate.text = "Sipariş Tarihi: \(formatter.string(from: orderDateValue))"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func toDetailTapped(_ sender: Any) {
        orderDetailButtonAction?()
    }
    
    @IBAction func makeReviewTapped(_ sender: Any) {
        rateButtonAction?()
    }
    
}
