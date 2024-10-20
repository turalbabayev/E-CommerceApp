//
//  OrdersViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import UIKit
import Lottie
import Kingfisher

class OrdersViewController: UIViewController {
    @IBOutlet weak var ordersTableView: UITableView!
    @IBOutlet weak var noFoundAnimationView: LottieAnimationView!
    @IBOutlet weak var noFoundLabel: UILabel!
    
    
    var orders: [Order] = []
    var viewModel = OrdersViewModel()
    var userName: String = UserDefaults.standard.string(forKey: "savedUsername") ?? ""
    let uiHelper = Helper()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ordersTableView.delegate = self
        ordersTableView.dataSource = self
        ordersTableView.backgroundColor = .clear
        ordersTableView.separatorStyle = .none
        noFoundAnimationView.isHidden = true
        noFoundLabel.isHidden = true
        
        fetchOrders()
    }
    
    func fetchOrders() {
        viewModel.getOrders(for: userName) { [weak self] orders in
            self?.orders = orders ?? []
            if !((self?.orders.isEmpty) != nil){
                self?.noFoundAnimationView.contentMode = .scaleAspectFit
                self?.noFoundAnimationView.loopMode = .loop
                self?.noFoundAnimationView.animationSpeed = 0.5
                self?.noFoundAnimationView.play()
                self?.ordersTableView.isHidden = true
                self?.noFoundAnimationView.isHidden = false
                self?.noFoundLabel.isHidden = false
                self?.ordersTableView.reloadData()
            }else{
                self?.noFoundAnimationView.stop()
                self?.noFoundAnimationView.isHidden = true
                self?.noFoundLabel.isHidden = true
                self?.ordersTableView.reloadData()

            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func navigateToAddReviewPage(for product: ProductCart) {
        let addReviewVC = storyboard?.instantiateViewController(withIdentifier: "AddReviewViewController") as! AddReviewViewController
        addReviewVC.product = product  // Ürün bilgilerini gönderiyoruz
        navigationController?.pushViewController(addReviewVC, animated: true)
    }
    
    func navigateToOrderDetail(product: ProductCart,orderDate: Date,amount: Amount){
        let orderDetailVC = storyboard?.instantiateViewController(withIdentifier: "orderDetailViewController") as! OrderDetailViewController
        orderDetailVC.amount = amount
        orderDetailVC.orderDateValue = orderDate
        orderDetailVC.product = product
        navigationController?.pushViewController(orderDetailVC, animated: true)

    }

    

}

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.flatMap { $0.products }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrdersTableViewCell
        cell.backgroundColor = .clear
        cell.backgroundViewCell.cornerRadius = 10
        uiHelper.addShadowToView(view: cell.backgroundViewCell)
        
        cell.selectionStyle = .none
        
        let allProducts = orders.flatMap { $0.products }
        let product = allProducts[indexPath.row]
        let allAmount = orders.flatMap{$0.amount}
        let amount = allAmount[indexPath.row]
        
        let imageUrl = viewModel.getImageURL(for: product.resim!)
        if let url = URL(string: imageUrl){
            DispatchQueue.main.async {
                cell.productImage.kf.setImage(with: url)
            }
        }
        
        var orderDate: Date = Date()
        for order in orders {
            if order.products.contains(where: { $0.ad == product.ad }) {
                orderDate = order.orderDate
                break
            }
        }
        
        
        cell.configure(with: product, orderDateValue: orderDate)
        
        cell.rateButtonAction = { [weak self] in
            self?.navigateToAddReviewPage(for: product)
        }
        
        cell.orderDetailButtonAction = { [weak self] in
            self?.navigateToOrderDetail(product: product, orderDate: orderDate, amount: amount)
        }
        
        return cell
    }
    
}
