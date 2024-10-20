//
//  ProductDetailViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import UIKit
import Kingfisher

class ProductDetailViewController: UIViewController {
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productBrand: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQty: UILabel!
    
    var product: Products?
    var descriptionItem: Description?
    var viewModel = ProductDetailViewModel()
    var qtyCounter = 1
    var username: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countView.cornerRadius = 12
        countView.layer.borderColor = UIColor(named: "appPrimary")!.cgColor
        countView.layer.borderWidth = 0.5
        // UserDefaults'tan kaydedilmiş kullanıcı adını al
        
        username = UserDefaults.standard.string(forKey: "savedUsername")
        
        if let p = product, let descriptionItem = descriptionItem{
            productTitle.text = p.ad
            productBrand.text = p.marka
            productPrice.text = String("₺\(p.fiyat!)")
            
            let imageUrl = viewModel.getImageURL(for: p.resim!)
            if let url = URL(string: imageUrl){
                DispatchQueue.main.async {
                    self.productImage.kf.setImage(with: url)
                }
            }
            
            if descriptionItem.productId == p.id{
                productDescription.text = descriptionItem.description
            }
        }

    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func qtyDecreaseTapped(_ sender: Any) {
        if qtyCounter>1{
            qtyCounter -= 1
            productQty.text = String(qtyCounter)
        }
    }
    
    @IBAction func qtyIncreaseTapped(_ sender: Any) {
        qtyCounter += 1
        productQty.text = String(qtyCounter)
    }
    
    
    @IBAction func addToCardTapped(_ sender: Any) {
        if let p = self.product{
            //print("Detay Sayfasindan Giden: \(self.qtyCounter)")
            self.viewModel.addProductToCart(name: p.ad!, productImage: p.resim!, productCategory: p.kategori, productPrice: p.fiyat!, productBrand: p.kategori, productQty: self.qtyCounter, username: username ?? "" ){ success in
                if success{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goToCartSegue", sender: nil)
                    }
                }
                else{
                    print("Basarisiz")
                }
                }
            }
        }
    
}
