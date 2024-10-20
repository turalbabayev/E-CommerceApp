//
//  SearchViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit
import RxSwift
import Lottie

class SearchViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var previousCollectionView: UICollectionView!
    @IBOutlet weak var allProductTableView: UITableView!
    @IBOutlet weak var noFoundLabel: UILabel!
    @IBOutlet weak var noProductLabel: UILabel!
    
    @IBOutlet weak var animationView: LottieAnimationView!
    
    let viewModel = SearchViewModel()
    var previousSearchList = [String]()
    var productList = [Products]()
    let uiHelper = Helper()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        previousCollectionView.delegate = self
        previousCollectionView.dataSource = self
        allProductTableView.dataSource = self
        allProductTableView.delegate = self
        searchTextField.delegate = self
        searchTextField.setLeftIcon(UIImage(systemName: "magnifyingglass")!)
        searchTextField.setupBorderStyle()
        searchTextField.autocorrectionType = .no

        
        _ = viewModel.previousSearchList.subscribe(onNext: { list in
            self.previousSearchList = list
            if self.previousSearchList.isEmpty{
                self.noFoundLabel.isHidden = false
                self.previousCollectionView.isHidden = true
            }else{
                self.noFoundLabel.isHidden = true
                self.previousCollectionView.isHidden = false
                DispatchQueue.main.async {
                    self.previousCollectionView.reloadData()
                }
            }
            
        })
        
        _ = viewModel.productList.subscribe(onNext: { list in
            self.productList = list
            if self.productList.isEmpty{
                self.allProductTableView.isHidden = true
                self.animationView.isHidden = false
                self.noProductLabel.isHidden = false
                self.animationView.contentMode = .scaleAspectFit
                self.animationView.loopMode = .loop
                self.animationView.animationSpeed = 0.5
                self.animationView.play()
            }else{
                self.animationView.isHidden = true
                self.allProductTableView.isHidden = false
                self.noProductLabel.isHidden = true

                DispatchQueue.main.async {
                    self.allProductTableView.reloadData()
                }
            }
            
        })
        
        allProductTableView.backgroundColor = .clear
        allProductTableView.separatorStyle = .none
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadSearchHistory()

    }
    
    @IBAction func clearAllTapped(_ sender: Any) {
        viewModel.clearSearchHistory()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToDetail" {
            if let product = sender as? Products {
                let nextVC = segue.destination as! ProductDetailViewController
                nextVC.product = product
            }
        }
    }
    
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CellProtocolPrevious{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previousSearchList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let previousCell = collectionView.dequeueReusableCell(withReuseIdentifier: "previousSearchCell", for: indexPath) as! PreviousSearchCollectionViewCell
        previousCell.title.text = previousSearchList[indexPath.row]
        previousCell.cellProtocol = self
        previousCell.indexPath = indexPath
        
        return previousCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        
        label.text = previousSearchList[indexPath.row]
        label.font = UIFont.systemFont(ofSize: 15) // Fontun aynı olduğundan emin olun

        let labelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30))

        return CGSize(width: labelSize.width + 45, height: 30) // Ekstra 30px padding
    }
    
    func deleteButtonTapped(indexPath: IndexPath) {
        let searchText = self.previousSearchList[indexPath.row]
        self.viewModel.deleteSearchTerm(searchTerm: searchText)
    }
    
    
    
}

extension SearchViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let searchText = self.searchTextField.text, !searchText.isEmpty {
            // Arama terimini Firestore'a ve yerel listeye ekle
            viewModel.addSearchTerm(searchTerm: searchText)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if currentText == "" {
            viewModel.loadProducts()
        }else{
            print("Arama metni değişti: \(currentText)")
            viewModel.searchProductsLocally(searchTerm: currentText)
        }
        return true

        
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allProductsCellInSearch") as! AllProductTableViewCell
        cell.setup(productList[indexPath.row])
        
        let imageUrl = viewModel.getImageURL(for: productList[indexPath.row].resim!)
        if let url = URL(string: imageUrl){
            DispatchQueue.main.async {
                cell.productImage.kf.setImage(with: url)
            }
        }
        
        cell.backgroundColor = .clear
        cell.rightView.backgroundColor = .clear
        cell.backgroundViewCell.cornerRadius = 12
        uiHelper.addShadowToView(view: cell.backgroundViewCell)
        
        
        cell.selectionStyle = .none
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = productList[indexPath.row]
        self.performSegue(withIdentifier: "searchToDetail", sender: product)
    }
    
    
}
