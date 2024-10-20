//
//  AddReviewViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import UIKit
import Kingfisher

class AddReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var clickToUploadLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var productBackgroundView: UIView!
    @IBOutlet weak var uploadImageBackgroundView: UIView!
    @IBOutlet var starButtons: [UIButton]!
    
    
    
    var selectedRating = 0
    var uiHelper = Helper()
    var product: ProductCart?
    var viewModel = AddReviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiHelper.addShadowToView(view: productBackgroundView)
        uiHelper.addDashedBorder(to: uploadImageBackgroundView)
        textField.setupBorderStyle()
        productBackgroundView.cornerRadius = 12
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        uploadImageBackgroundView.isUserInteractionEnabled = true
        uploadImageBackgroundView.addGestureRecognizer(tapGesture)
        
        setupAndSave()
        updateStarSelection(rating: 0)
        viewModel.product = product  // Ürün bilgilerini ViewModel'e gönderiyoruz


    }
    
    @IBAction func starTapped(_ sender: UIButton) {
        guard let index = starButtons.firstIndex(of: sender) else { return }
                let rating = index + 1
                selectedRating = rating
                print(selectedRating)
                updateStarSelection(rating: rating)
    }
    
    func updateStarSelection(rating: Int) {
        for (index, button) in starButtons.enumerated() {
            if index < rating {
                button.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                button.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
    
    
    @objc func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupAndSave(){
        if let product = product {
            productName.text = product.ad!
            productPrice.text = "₺\(product.fiyat!)"
            let imageUrl = viewModel.getImageURL(for: product.resim!)
            if let url = URL(string: imageUrl){
                DispatchQueue.main.async {
                    self.productImage.kf.setImage(with: url)
                }
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.image = selectedImage // Seçilen resmi göster
                clickToUploadLabel.text = "" // Yazıyı boşalt
            }
            picker.dismiss(animated: true, completion: nil)
        }
    @IBAction func submitReview(_ sender: Any) {
        let reviewText = textField.text ?? ""
        let rating = selectedRating
        
        // Yorum verilerini ViewModel'e gönderiyoruz
        viewModel.submitReview(reviewText: reviewText, rating: Double(rating)) { success in
            if success {
                print("Review successfully saved!")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Error saving review.")
            }
        }
        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
