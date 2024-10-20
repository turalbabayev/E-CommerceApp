//
//  AllCategoryViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit
import Kingfisher

class AllCategoryViewController: UIViewController {
    @IBOutlet weak var allCategoryTableView: UITableView!
    var viewModel = AllCategoryViewModel()
    var categoryList = [Category]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        allCategoryTableView.dataSource = self
        allCategoryTableView.delegate = self
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(named: "appSecondary")!.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Üst merkez
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Alt merkez
        
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        allCategoryTableView.backgroundColor = .clear
        allCategoryTableView.separatorStyle = .none
        
        _ = viewModel.categoryList.subscribe(onNext: { list in
            self.categoryList = list
            DispatchQueue.main.async {
                self.allCategoryTableView.reloadData()
            }
        })
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}

extension AllCategoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell") as! AllCategoryTableViewCell
        let category = categoryList[indexPath.row]
        cell.categoryImage.image = UIImage(named: category.image) 
        cell.categoryName.text = category.title
        cell.backgroundColor = .clear
        cell.cellView.layer.cornerRadius = 12
        
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AllCategoryTableViewCell {
            // Hücre seçildiğinde border ekle
            cell.cellView.layer.borderWidth = 1
            cell.cellView.layer.borderColor = UIColor(named: "appPrimary")!.cgColor
            cell.cellView.backgroundColor = UIColor(named: "appPrimary")!.withAlphaComponent(0.2)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AllCategoryTableViewCell {
            // Hücre seçilmediğinde border'ı kaldır
            cell.cellView.layer.borderWidth = 0
            cell.cellView.layer.borderColor = UIColor.clear.cgColor
            cell.cellView.backgroundColor = UIColor.white

        }
    }
    
    

    
    
}
