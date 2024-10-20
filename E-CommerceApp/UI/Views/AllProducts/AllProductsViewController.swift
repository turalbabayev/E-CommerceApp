//
//  AllProductsViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit
import Kingfisher
import RxSwift

class AllProductsViewController: UIViewController {
    @IBOutlet weak var allProductCollectionView: UICollectionView!
    
    
    var productList = [Products]()
    var viewModel = AllProductsViewModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        _ = viewModel.productList.subscribe(onNext: { list in
            self.productList = list
            DispatchQueue.main.async {
                self.allProductCollectionView.reloadData()
            }
        })

        allProductCollectionView.dataSource = self
        allProductCollectionView.delegate = self
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

}

extension AllProductsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: "allProductCell", for: indexPath) as! AllProductsCollectionViewCell
        productCell.setup(productList[indexPath.row])
        productCell.cornerRadius = 12
        productCell.productRate.cornerRadius = 3
        productCell.productRate.layer.masksToBounds = true
        productCell.favButtonView.backgroundColor = .clear
        
                    
        let imageUrl = viewModel.getImageURL(for: productList[indexPath.row].resim!)
        if let url = URL(string: imageUrl){
            DispatchQueue.main.async {
                productCell.productImage.kf.setImage(with: url)

            }
        }
        
        return productCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 30)/2
        return CGSize(width: itemWidth, height: itemWidth * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
