//
//  FavoritesViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 17.10.2024.
//

import UIKit
import Kingfisher
import Lottie

class FavoritesViewController: UIViewController {
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    var favoriteProducts = [Products]()
    var viewModel = FavoritesViewModel()
    var username = UserDefaults.standard.string(forKey: "savedUsername") ?? "guest"
    var uiHelper = Helper()
    @IBOutlet weak var noFoundAnimationView: LottieAnimationView!
    @IBOutlet weak var noFoundLabel: UILabel!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.delegate = self
        //self.startAnimation()

        
        // Favori ürünleri yükle
        viewModel.loadFavorites { products in
            self.favoriteProducts = products
            DispatchQueue.main.async {
                if self.favoriteProducts.isEmpty{
                    self.favoritesCollectionView.reloadData()
                    self.updateVisibility(isHidden: true)
                }else{
                    self.favoritesCollectionView.reloadData()
                    self.updateVisibility(isHidden: false)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadFavorites { products in
            self.favoriteProducts = products
            DispatchQueue.main.async {
                if self.favoriteProducts.isEmpty{
                    self.updateVisibility(isHidden: true)
                    self.favoritesCollectionView.reloadData()
                    self.startAnimation()
                }else{
                    self.updateVisibility(isHidden: false)
                    self.favoritesCollectionView.reloadData()
                    self.stopAnimation()
                }
            }
        }
    }
    
    func updateVisibility(isHidden: Bool){
        favoritesCollectionView.isHidden = isHidden
        noFoundAnimationView.isHidden = !isHidden
        noFoundLabel.isHidden = !isHidden
    }
    
    func startAnimation(){
        noFoundAnimationView.contentMode = .scaleAspectFit
        noFoundAnimationView.loopMode = .loop
        noFoundAnimationView.animationSpeed = 0.5
        noFoundAnimationView.play()
    }
    
    func stopAnimation(){
        noFoundAnimationView.stop()
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favoriteProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoritesCell", for: indexPath) as! FavoritesCollectionViewCell
        let product = favoriteProducts[indexPath.row]
        cell.setup(product)
        cell.productRate.cornerRadius = 3
        cell.productRate.layer.masksToBounds = true
        uiHelper.addShadowToView(view: cell)
        
        
        
        let imageUrl = viewModel.getImageURL(for: favoriteProducts[indexPath.row].resim!)
        if let url = URL(string: imageUrl){
            DispatchQueue.main.async {
                cell.productImage.kf.setImage(with: url)

            }
        }
        
        cell.deleteButtonTapped = { [weak self] in
            self?.viewModel.removeProductFromFavorites(product: product) { success in
                if success {
                    self?.favoriteProducts.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self?.favoritesCollectionView.deleteItems(at: [indexPath])
                        NotificationCenter.default.post(name: NSNotification.Name("favoritesUpdated"), object: nil)
                    }
                }
            }
        }
        
        
        return cell
        
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
