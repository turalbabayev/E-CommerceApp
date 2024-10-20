//
//  CartTableViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import UIKit

protocol CellProtocol{
    func deleteProductTapped(indexPath: IndexPath)
    func qtyIncreaseTapped(indexPath: IndexPath, qty: Int)
    func qtyDecreaseTapped(indexPath: IndexPath, qty: Int)
}

class CartTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productBrand: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQty: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var qtyStackView: UIStackView!
    
    var cellProtocol: CellProtocol?
    var indexPath: IndexPath?
    var qty: Int?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func qtyDecreaseTapped(_ sender: UIButton) {
        if let currentQty = qty, currentQty > 1 {
            qty = currentQty - 1
            productQty.text = String(qty!)
            // Güncellenen miktarı viewController'a bildir
            cellProtocol?.qtyDecreaseTapped(indexPath: indexPath!, qty: qty!)
        }
    }
    
    
    @IBAction func qtyIncreaseTapped(_ sender: Any) {
        if let currentQty = qty {
            qty = currentQty + 1
            productQty.text = String(qty!)
            print("CartTableViewCell qty: \(qty!)")
            // Güncellenen miktarı viewController'a bildir
            cellProtocol?.qtyIncreaseTapped(indexPath: indexPath!, qty: qty!)
        }
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        cellProtocol?.deleteProductTapped(indexPath: indexPath!)
    }
    
}
