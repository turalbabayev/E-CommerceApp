//
//  AllProductTableViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit

class AllProductTableViewCell: UITableViewCell {
    @IBOutlet weak var backgroundViewCell: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productBrand: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productRate: UILabel!
    @IBOutlet weak var rightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(_ product: Products) {
        productTitle.text = product.ad!
        productBrand.text = product.marka!
        productPrice.text = String("₺\(product.fiyat!)")
    }

}
