//
//  PaymentViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 17.10.2024.
//

import UIKit

class PaymentViewController: UIViewController {
    @IBOutlet weak var addressTitle: UILabel!
    @IBOutlet weak var addressLine: UILabel!
    @IBOutlet weak var paymentTitle1: UILabel!
    @IBOutlet weak var paymentTitle2: UILabel!
    @IBOutlet weak var cardNumber1: UILabel!
    @IBOutlet weak var cardNumber2: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var discountAmount: UILabel!
    @IBOutlet weak var deliveryAmount: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var firstRadioButton: UIButton!
    @IBOutlet weak var secondRadioButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var checkboxButton: UIButton!
    
    
    
    
    var amountValue: String?
    var discountAmountValue: String?
    var deliveryAmountValue: String?
    var totalAmountValue: String?
    var products: [ProductCart] = []  // CartViewController'dan gelen ürünler
    var isFirstButtonSelected = false
    var isSecondButtonSelected = false
    var isCheckboxSelected: Bool = false
    var userName: String = UserDefaults.standard.string(forKey: "savedUsername") ?? ""
    var viewModel = PaymentViewModel()
    var amountData: Amount?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addressDetailButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func checkboxTapped(_ sender: UIButton) {
        isCheckboxSelected.toggle()
                
        if isCheckboxSelected {
            // Checkbox işaretli hale getiriliyor
            checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)  // Seçili kare
            payButton.isEnabled = true
            payButton.backgroundColor = UIColor(named: "appPrimary")
        } else {
            // Checkbox işaretsiz hale getiriliyor
            checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)  // İşaretsiz kare
            payButton.isEnabled = false  // Checkbox seçili değilse buton devre dışı kalır
            payButton.backgroundColor = UIColor(named: "light")

        }
    }
    
    
    @IBAction func payButtonTapped(_ sender: Any) {
        print(amountData!)
        viewModel.saveOrderToFirestore(products: products, userName: userName, amount: amountData!) { success in
            if success {
                print("Sipariş başarıyla kaydedildi.")
            } else {
                print("Sipariş kaydedilirken hata oluştu.")
            }
        }
        performSegue(withIdentifier: "toPaymentSuccess", sender: nil)
    }
    
    @IBAction func card1Tapped(_ sender: Any) {
        if isFirstButtonSelected {
            // Eğer birinci buton seçiliyse, ikinci butonu seçili yap
            firstRadioButton.setImage(UIImage(systemName: "circle.dashed"), for: .normal)
            secondRadioButton.setImage(UIImage(systemName: "circle.dashed.inset.filled"), for: .normal)
            
            // Durumları güncelle
            isFirstButtonSelected = false
            isSecondButtonSelected = true
        } else {
            // Eğer birinci buton seçili değilse, onu seçili yap
            firstRadioButton.setImage(UIImage(systemName: "circle.dashed.inset.filled"), for: .normal)
            secondRadioButton.setImage(UIImage(systemName: "circle.dashed"), for: .normal)
            
            // Durumları güncelle
            isFirstButtonSelected = true
            isSecondButtonSelected = false
        }
    }

    @IBAction func card2Tapped(_ sender: Any) {
        if isSecondButtonSelected {
            // Eğer ikinci buton seçiliyse, birinci butonu seçili yap
            secondRadioButton.setImage(UIImage(systemName: "circle.dashed"), for: .normal)
            firstRadioButton.setImage(UIImage(systemName: "circle.dashed.inset.filled"), for: .normal)
            
            // Durumları güncelle
            isFirstButtonSelected = true
            isSecondButtonSelected = false
        } else {
            // Eğer ikinci buton seçili değilse, onu seçili yap
            secondRadioButton.setImage(UIImage(systemName: "circle.dashed.inset.filled"), for: .normal)
            firstRadioButton.setImage(UIImage(systemName: "circle.dashed"), for: .normal)
            
            // Durumları güncelle
            isFirstButtonSelected = false
            isSecondButtonSelected = true
        }
    }
    
    func setup(){
        amount.text = amountValue
        discountAmount.text = discountAmountValue
        deliveryAmount.text = deliveryAmountValue
        totalAmount.text = totalAmountValue
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.layer.cornerRadius = 4  // Kare görünüm için köşe yuvarlama
        payButton.isEnabled = false  // Checkbox seçilmezse buton devre dışı
        payButton.backgroundColor = UIColor(named: "light")
        if let amountStr = amountValue, let discountstr = discountAmountValue, let deliveryAmount = deliveryAmountValue, let totalStr = totalAmountValue{
            //print(amountStr)
            amountData = Amount(orderAmount: amountStr, orderDiscountAmount: discountstr, orderDeliveryAmount: deliveryAmount, totalAmount: totalStr)
        }
    }
    
    
}
