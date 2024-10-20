//
//  HomeViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 13.10.2024.
//

import UIKit
import RxSwift
import Kingfisher
import CoreLocation


class HomeViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    
    var categoryList = [Category]()
    var productList = [Products]()
    var combinedProductAndRatings = [(Products, Rating?)]()  // Ürün ve rating bilgilerini tutan liste
    var viewModel = HomeViewModel()
    var username = UserDefaults.standard.string(forKey: "savedUsername") ?? "guest"
    var uiHelper = Helper()
    var disposeBag = DisposeBag()
    let locationManager = CLLocationManager()


    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchTextField.setLeftIcon(UIImage(systemName: "magnifyingglass")!)
        searchTextField.setupBorderStyle()
        searchTextField.delegate = self
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        viewModel.loadDescriptions()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        /*
        _ = viewModel.productList.subscribe(onNext: { list in
            self.productList = list
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
                //self.categoryCollectionView.reloadData()
            }
        })
         */
        
        
        // Ürünler ve rating bilgileri birleştiriliyor
        _ = viewModel.combineProductAndRatings().subscribe(onNext: { combinedList in
            self.combinedProductAndRatings = combinedList
            DispatchQueue.main.async {
                self.productCollectionView.reloadData()
            }
        })
        
        _ = viewModel.categoryList.subscribe(onNext: { list in
            self.categoryList = list
            DispatchQueue.main.async {
                self.categoryCollectionView.reloadData()
            }
        })
        
        configureTabBarAppearance()
        categoryCollectionView.tag = 1
        productCollectionView.tag = 2
        
        
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.loadProducts()
        //viewModel.loadRatingsForProducts()  // Ürünler ve rating bilgilerini yükle

    }
    
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 3
        }
    }
    
    
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showFilter", sender: nil)
    }
    
    
    @IBAction func searchTextFieldTapped(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let data = sender as? (Description, Products) {
                let nextVC = segue.destination as! ProductDetailViewController
                nextVC.product = data.1
                nextVC.descriptionItem = data.0
            }
        }
        if segue.identifier == "showFilter" {
            if let filterVC = segue.destination as? FilterViewController {
                filterVC.modalPresentationStyle = .pageSheet
                if let sheet = filterVC.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.prefersGrabberVisible = false
                    sheet.preferredCornerRadius = 20
                    sheet.largestUndimmedDetentIdentifier = .medium
                }
                
                filterVC.applyFilterCompletion = { [weak self] selectedCategories, maxPrice in
                    if selectedCategories.isEmpty && maxPrice == 0 {
                        self?.viewModel.loadProducts()
                    } else {
                        self?.viewModel.filterProductsByCategoryAndPrice(selectedCategories: selectedCategories, maxPrice: maxPrice)
                    }
                }
                
                filterVC.presentationController?.delegate = self
                
            }
        }
    }
    
    func updateFavoriteState(for product: Products, in cell: ProductCollectionViewCell) {
        FirestoreRepository().isProductInFavorites(product: product, username: username) { isFavorite in
            DispatchQueue.main.async {
                cell.setup(product, isFavorite: isFavorite)
            }
        }
    }
    
    
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.white
        
        uiHelper.changeTabBarColor(itemAppearance: appearance.stackedLayoutAppearance)
        uiHelper.changeTabBarColor(itemAppearance: appearance.inlineLayoutAppearance)
        uiHelper.changeTabBarColor(itemAppearance: appearance.compactInlineLayoutAppearance)
        
        tabBarController?.tabBar.standardAppearance = appearance
    }
    
    

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return categoryList.count
        }
        else{
            return combinedProductAndRatings.count
            //return productList.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
            uiHelper.addShadowToView(view: cell)
            cell.setup(categoryList[indexPath.row])
            
            return cell
        }else{
            let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCollectionViewCell
            //let product = productList[indexPath.row]
            let (product, rating) = combinedProductAndRatings[indexPath.row]
            productCell.setup(product, isFavorite: false)
            productCell.cornerRadius = 12
            productCell.productRating.cornerRadius = 3
            productCell.productRating.layer.masksToBounds = true
            uiHelper.addShadowToView(view: productCell)


                        
            //let imageUrl = viewModel.getImageURL(for: productList[indexPath.row].resim!)
            let imageUrl = viewModel.getImageURL(for: product.resim!)
            if let url = URL(string: imageUrl){
                DispatchQueue.main.async {
                    productCell.productImage.kf.setImage(with: url)

                }
            }
            
            // Eğer rating varsa, rating bilgilerini göster
            if let rating = rating {
                productCell.productRating.text = "\(rating.rating)"
            } else {
                // Rating yoksa varsayılan değer göster
                productCell.productRating.text = "4.2"
            }
            
            
            // Ürünün favorilerde olup olmadığını kontrol ediyoruz.
            viewModel.isProductInFavorites(product: product) { isFavorite in
                DispatchQueue.main.async {
                    productCell.setup(product, isFavorite: isFavorite)
                }
            }
            
            
            updateFavoriteState(for: product, in: productCell)
            
            productCell.favoriteButtonTapped = { [weak self] in
                self?.viewModel.toggleFavorite(for: product) { isFavorite in
                    DispatchQueue.main.async {
                        productCell.setup(product, isFavorite: isFavorite)
                    }
                }
            }
            
            productCell.removeFavoriteButtonTapped = { [weak self] in
                FirestoreRepository().removeProductFromFavorites(product: product, username: self?.username ?? "") { error in
                    if let error = error {
                        print("Favorilerden çıkarırken hata: \(error.localizedDescription)")
                    }
                }
            }
            
            return productCell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2{
            let (product, _) = combinedProductAndRatings[indexPath.row]
            let selectedDescription = viewModel.descriptions[indexPath.row]
            //let product = productList[indexPath.row]
            performSegue(withIdentifier: "toDetail", sender: (selectedDescription,product))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1{
            let size = (UIScreen.main.bounds.width - 50) / 4
            return CGSize(width: size, height: size)
        }
        else{
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = (screenWidth - 30)/2
            return CGSize(width: itemWidth, height: itemWidth * 1.3)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 1{
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }else{
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 1{
            return 10
        }
        else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 1{
            return 10
        }
        else{
            return 10
        }
    }
    

    
}

extension HomeViewController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "nextToSearchPage", sender: self)
        // Return false to prevent the keyboard from showing up (klavyenin açılmasını engelle)
        return false
    }
}

extension HomeViewController: CLLocationManagerDelegate{
    // Kullanıcının konumu güncellendiğinde bu fonksiyon tetiklenir
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       if let location = locations.last {
           getPlace(for: location)
       }
       locationManager.stopUpdatingLocation() // Konum bir kez alındıktan sonra durdur
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       print("Konum alınamadı: \(error.localizedDescription)")
   }

   // Konum bilgilerini insan tarafından okunabilir hale getirmek için CLGeocoder kullanıyoruz
   func getPlace(for location: CLLocation) {
       let geocoder = CLGeocoder()
       
       geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
           if let error = error {
               print("Geocode hatası: \(error.localizedDescription)")
               return
           }
           
           if let placemark = placemarks?.first {
               let city = placemark.locality ?? "Şehir bulunamadı"
               let country = placemark.country ?? "Ülke bulunamadı"
               self.locationLabel.text = "\(city), \(country)" // Label'da şehir ve ülkeyi göster
           }
       }
   }
}





