//
//  FilterViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit
import RxSwift

class FilterViewController: UIViewController {
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var categoryList = [Category]()
    var viewModel = FilterViewModel()
    
    var selectedCategories = [String]()
    var selectedCategoriesCompletion: (([String]) -> Void)?
    var maxPriceCompletion: ((Int) -> Void)?
    var maxPrice: Int = 0
    
    // Filtrelerin uygulanması için closure
    var applyFilterCompletion: (([String], Int) -> Void)?

    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceLabel: UILabel!
    

    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.allowsMultipleSelection = true
        priceSlider.minimumValue = 0
        priceSlider.maximumValue = 100000
        
        updatePriceLabel()

        priceSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        

        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = 30
        
        _ = viewModel.categoryList.subscribe(onNext: { list in
            self.categoryList = list
            DispatchQueue.main.async {
                self.categoryCollectionView.reloadData()
            }
        })
        
    }
    
    
    @IBAction func buttonTapped(_ sender: Any) {
        // Eğer hem kategoriler boş hem de maxPrice sıfır ise, tüm ürünleri yükle
        if selectedCategories.isEmpty && maxPrice == 0 {
            applyFilterCompletion?([], 0)  // Hiçbir filtre yok, tüm ürünleri göster
        } else if maxPrice == 0 && !selectedCategories.isEmpty{
            viewModel.filterProductsByCategory(selectedCategories: selectedCategories)
        }
        else {
            applyFilterCompletion?(selectedCategories, maxPrice)  // Seçilen filtrelerle ürünleri filtrele
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func sliderValueChanged() {
        updatePriceLabel()  // Slider hareket ettikçe label güncellenir
    }

    func updatePriceLabel() {
        let currentSliderValue = Int(priceSlider.value)  // Slider'ın mevcut değerini alıyoruz (tam sayı)
        self.maxPrice = currentSliderValue
        priceLabel.text = "₺0 - ₺\(currentSliderValue)"    // Label'i güncelleme
    }

}


extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryInFilter", for: indexPath) as! CategoryInFilterCollectionViewCell
        cell.categoryName.text = categoryList[indexPath.row].title
        cell.backgroundViewCell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        
        label.text = categoryList[indexPath.row].title
        label.font = UIFont.systemFont(ofSize: 15)

        let labelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))

        return CGSize(width: labelSize.width + 30, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryInFilterCollectionViewCell {
            // Hücre seçildiğinde border ekleme
            cell.backgroundViewCell.backgroundColor = UIColor(named: "appPrimary")!.withAlphaComponent(0.2)
            cell.categoryName.textColor = UIColor(named: "appPrimary")!
            
            // Seçilen kategoriyi listeye ekleme
            let selectedCategory = categoryList[indexPath.row].title
            selectedCategories.append(selectedCategory)
            print(selectedCategories)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryInFilterCollectionViewCell {
            // Hücre seçildiğinde border ekle
            cell.backgroundViewCell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.categoryName.textColor = UIColor.black
            // Seçimi kaldırılan kategoriyi listeden cikarmak
            let deselectedCategory = categoryList[indexPath.row].title
            if let index = selectedCategories.firstIndex(of: deselectedCategory) {
                selectedCategories.remove(at: index)
                print(selectedCategories)
            }
        }
    }
    
}

