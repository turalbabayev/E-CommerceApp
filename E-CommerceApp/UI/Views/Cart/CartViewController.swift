//
//  CartViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import UIKit
import Kingfisher
import Lottie


class CartViewController: UIViewController {
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var discountAmountLabel: UILabel!
    @IBOutlet weak var deliveryAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var lineView2: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var complateOrder: UIButton!
    @IBOutlet weak var couponTextField: UITextField!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var couponLabelView: UIView!
    @IBOutlet weak var couponApplyButton: UIButton!
    @IBOutlet weak var couponBackgroundView: UIView!
    @IBOutlet weak var noFoundAnimationView: LottieAnimationView!
    @IBOutlet weak var noFoundLabel: UILabel!
    
    var productListInCart = [ProductCart]()
    var username = UserDefaults.standard.string(forKey: "savedUsername")
    var viewModel = CartViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productTableView.delegate = self
        productTableView.dataSource = self
        
        _ = viewModel.productListInCart.subscribe(onNext: { list in
            self.productListInCart = list
            DispatchQueue.main.async {
                
                if self.productListInCart.isEmpty{
                    self.productTableView.reloadData()
                    self.clearDiscountFromUserDefaults()
                    self.calculateTotalAmounts()  // Sayfa yüklendiğinde toplamları hesapla
                    self.updateViewVisibility(isHidden: true)
                }else{
                    self.productTableView.reloadData()
                    self.calculateTotalAmounts()
                    self.updateViewVisibility(isHidden: false)
                }
            }
        })
        
        couponBackgroundView.isHidden = true
        couponBackgroundView.cornerRadius = 12
        couponLabelView.isHidden = true
        couponTextField.isHidden = true
        couponApplyButton.isHidden = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewModel.getProductInCart()
        loadDiscountFromUserDefaults()  // Sayfa görünür hale geldiğinde indirimi yükle
        
    }
    
    func loadDiscountFromUserDefaults() {
        let discountPercentage = UserDefaults.standard.double(forKey: "appliedDiscountPercentage")
        let discountAmount = UserDefaults.standard.integer(forKey: "appliedDiscountAmount")
        let discountedAmount = UserDefaults.standard.integer(forKey: "discountedAmount")
        
        print("İndirim yüklendi: Yüzde \(discountPercentage), Sabit \(discountAmount), Toplam: \(discountedAmount)")
        
        DispatchQueue.main.async {
            if discountPercentage != 0 {
                self.discountAmountLabel.text = "₺\(Int(Double(discountedAmount) * (discountPercentage / 100.0)))"
            } else if discountAmount != 0 {
                self.discountAmountLabel.text = "₺\(discountAmount)"
            }
            self.totalLabel.text = "₺\(discountedAmount)"
        }
    }
    
    
    
    func saveDiscountToUserDefaults(discountPercentage: Double?, discountAmount: Int?, discountedAmount: Int) {
        UserDefaults.standard.removeObject(forKey: "appliedDiscountPercentage")
        UserDefaults.standard.removeObject(forKey: "appliedDiscountAmount")
        
        if let discountPercentage = discountPercentage {
            UserDefaults.standard.set(discountPercentage, forKey: "appliedDiscountPercentage")
        }
        
        if let discountAmount = discountAmount {
            UserDefaults.standard.set(discountAmount, forKey: "appliedDiscountAmount")
        }
        
        UserDefaults.standard.set(discountedAmount, forKey: "discountedAmount")
    }

    
    
    func calculateTotalAmounts() {
        let totalAmount = productListInCart.map { product -> Int in
            let price = product.fiyat ?? 0
            let quantity = product.siparisAdeti ?? 1
            return price * quantity
        }.reduce(0, +)
        
        let discountPercentage = UserDefaults.standard.double(forKey: "appliedDiscountPercentage")
        let discountAmount = UserDefaults.standard.integer(forKey: "appliedDiscountAmount")
        
        var finalDiscount = 0
        
        if discountPercentage != 0 {
            finalDiscount = Int(Double(totalAmount) * (discountPercentage / 100.0))
        } else if discountAmount != 0 {
            finalDiscount = discountAmount
        }
        
        let finalTotal = totalAmount - finalDiscount
        
        DispatchQueue.main.async {
            self.amountLabel.text = "₺\(totalAmount)"
            self.discountAmountLabel.text = "₺\(finalDiscount)"
            self.totalLabel.text = "₺\(finalTotal)"
        }
    }

    
    
    
    @IBAction func applyCouponTapped(_ sender: Any) {
        guard let couponCode = couponTextField.text, !couponCode.isEmpty else {
                print("Kupon kodu girilmedi")
                return
            }
            
        if let priceString = amountLabel.text?.replacingOccurrences(of: "₺", with: "").replacingOccurrences(of: ".", with: ""),
           let priceInt = Int(priceString) {
            if let (discountedAmount, discount) = viewModel.applyCoupon(code: couponCode, to: priceInt) {
                totalLabel.text = "₺\(discountedAmount)"
                discountAmountLabel.text = "₺\(discount)"
                
                // Kupon tipine göre kaydetme
                switch viewModel.getCouponType(for: couponCode) {
                case .percentage(let discountPercentage):
                    saveDiscountToUserDefaults(discountPercentage: discountPercentage, discountAmount: nil, discountedAmount: discountedAmount)
                case .fixedAmount(let discountAmount):
                    saveDiscountToUserDefaults(discountPercentage: nil, discountAmount: Int(discountAmount), discountedAmount: discountedAmount)
                case .none:
                    print("Kupon bulunamadı")
                }
            } else {
                print("Geçersiz kupon kodu")
            }
        } else {
            print("Fiyat hatalı")
        }

        
        removeBlurEffect()
        couponBackgroundView.isHidden = true
        couponLabelView.isHidden = true
        couponTextField.isHidden = true
        couponApplyButton.isHidden = true
    }

    
    @IBAction func discountApplyTapped(_ sender: UIButton) {
        addBlurEffect()
        couponBackgroundView.isHidden = false
        couponLabelView.isHidden = false
        couponTextField.isHidden = false
        couponApplyButton.isHidden = false
    }
    
    
    @IBAction func closeCouponView(_ sender: Any) {
        removeBlurEffect()
        couponBackgroundView.isHidden = true
        couponLabelView.isHidden = true
        couponTextField.isHidden = true
        couponApplyButton.isHidden = true
    }
    
    
    @IBAction func complateOrderTapped(_ sender: UIButton) {
        let cardSummary = CartSummary(amount: amountLabel.text! , discountAmount: discountAmountLabel.text!, totalAmount: totalLabel.text!, deliveryAmount: deliveryAmountLabel.text!)
        let cartSummaryWithProducts = CartSummaryWithProducts(cartSummary: cardSummary, products: productListInCart)
        performSegue(withIdentifier: "toPayment", sender: cartSummaryWithProducts)
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func updateViewVisibility(isHidden: Bool) {
        self.productTableView.isHidden = isHidden
        self.couponView.isHidden = isHidden
        self.lineView.isHidden = isHidden
        self.lineView2.isHidden = isHidden
        self.amountView.isHidden = isHidden
        self.totalView.isHidden = isHidden
        self.complateOrder.isHidden = isHidden
        self.noFoundAnimationView.isHidden = !isHidden
        self.noFoundLabel.isHidden = !isHidden
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPayment" {
            if let cartSummaryWithProducts = sender as? CartSummaryWithProducts {
                let nextVC = segue.destination as! PaymentViewController
                // CartSummary verilerini gönderiyoruz
                nextVC.amountValue = cartSummaryWithProducts.cartSummary.amount
                nextVC.discountAmountValue = cartSummaryWithProducts.cartSummary.discountAmount
                nextVC.deliveryAmountValue = cartSummaryWithProducts.cartSummary.deliveryAmount
                nextVC.totalAmountValue = cartSummaryWithProducts.cartSummary.totalAmount
                
                // Sepetteki ürünleri gönderiyoruz
                nextVC.products = cartSummaryWithProducts.products
            }
        }
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.95 // 0.5 ile hafif bulanıklık
        view.insertSubview(blurEffectView, belowSubview: couponBackgroundView)
    }
    
    func removeBlurEffect() {
        for subview in view.subviews {
            if let blurView = subview as? UIVisualEffectView {
                blurView.removeFromSuperview()
            }
        }
    }
    
    func clearDiscountFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "appliedDiscountPercentage")
        UserDefaults.standard.removeObject(forKey: "appliedDiscountAmount")
        UserDefaults.standard.removeObject(forKey: "discountedAmount")
        
        print("İndirim bilgileri sıfırlandı.")
    }
    

}

extension CartViewController: UITableViewDelegate, UITableViewDataSource, CellProtocol{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productListInCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        let product = productListInCart[indexPath.row]
        cell.productTitle.text = product.ad!
        cell.productQty.text = String(product.siparisAdeti!)
        cell.productBrand.text = product.marka!
        cell.productPrice.text = String("₺\(product.fiyat!)")
        cell.cellProtocol = self
        cell.indexPath = indexPath
        cell.qty = product.siparisAdeti ?? 1
        


        let imageUrl = viewModel.getImageURL(for: product.resim!)
        if let url = URL(string: imageUrl){
            DispatchQueue.main.async {
                cell.productImage.kf.setImage(with: url)
            }
        }
        
        cell.backgroundColor = UIColor.white
        cell.productView.cornerRadius = 12
        cell.deleteButton.layer.borderColor = UIColor.red.cgColor
        cell.deleteButton.layer.borderWidth = 0.5
        cell.deleteButton.cornerRadius = 12
        cell.qtyStackView.layer.borderColor = UIColor(named: "appPrimary")!.cgColor
        cell.qtyStackView.layer.borderWidth = 0.5
        cell.qtyStackView.cornerRadius = 12
        
        
        
        
        return cell
    }
    
    func deleteProductTapped(indexPath: IndexPath) {
        let product = productListInCart[indexPath.row]
        viewModel.deleteProductInCart(cartId: product.sepetId!)
        
        if productListInCart.isEmpty {
            // Sepet boşaldıysa indirim verilerini sıfırla
            clearDiscountFromUserDefaults()
        }
        calculateTotalAmounts()
    }
    
    func qtyIncreaseTapped(indexPath: IndexPath, qty: Int) {
        let product = productListInCart[indexPath.row]
        print("CardViewController Increase qty: \(qty)")

        
        self.viewModel.updateProductInCart(name: product.ad!, productImage: product.resim!, productCategory: product.kategori!, productPrice: product.fiyat!, productBrand: product.marka!, productQty: qty, process: true) { addSuccess in
            if addSuccess {
                self.calculateTotalAmounts()
                print("Ürün başarıyla güncellendi.")
            } else {
                print("Ürün eklenirken hata oluştu.")
            }
        }
    }

    func qtyDecreaseTapped(indexPath: IndexPath, qty: Int) {
        if qty < 1 {
            return // Sipariş adeti 1'in altına düşemez, azaltma işlemi yapılmaz
        }
        
        let product = productListInCart[indexPath.row]
        print("CardViewController Decrease qty: \(qty)")
        
        
        self.viewModel.updateProductInCart(name: product.ad!, productImage: product.resim!, productCategory: product.kategori!, productPrice: product.fiyat!, productBrand: product.marka!, productQty: qty, process: false) { addSuccess in
            if addSuccess {
                self.calculateTotalAmounts()
                print("Ürün başarıyla güncellendi.")
            } else {
                print("Ürün eklenirken hata oluştu.")
            }
        }
    }

}

