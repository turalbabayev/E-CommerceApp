//
//  OrderDetailViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 20.10.2024.
//

import UIKit
import PDFKit
import Kingfisher

class OrderDetailViewController: UIViewController {
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQty: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var productView: UIView!
    
    var viewModel = OrderDetailViewModel()
    var product: ProductCart?
    var orderDateValue: Date?
    var amount: Amount?
    let formatter = DateFormatter()
    var uiHelper = Helper()
    var pdfView: PDFView!
    var closeButton: UIButton!
    var downloadButton: UIButton!
    var pdfFilePath: URL?
    var username = UserDefaults.standard.string(forKey: "savedUsername") ?? "guest"
    var email = UserDefaults.standard.string(forKey: "savedEmail") ?? "guest@gmail.com"
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        uiHelper.addShadowToView(view: productView)
        productView.cornerRadius = 12
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func showInvoiceTapped(_ sender: Any) {
        createCustomPDFInvoice()
    }
    
    func setup(){
        if let amount = amount, let product = product, let orderDate = orderDate {
            formatter.dateFormat = "dd/MM/yyyy"  // Tarih formatı
            orderDate.text = "Sipariş Tarihi: \(formatter.string(from: orderDateValue!))"
            productTitle.text = product.ad!
            productPrice.text = "₺\(product.fiyat!)"
            productQty.text = "Adet: \(product.siparisAdeti!)"
            amountLabel.text = amount.orderAmount
            discountLabel.text =  amount.orderDiscountAmount
            deliveryLabel.text = amount.orderDeliveryAmount
            totalAmountLabel.text = amount.totalAmount
            let imageUrl = viewModel.getImageURL(for: product.resim!)
            if let url = URL(string: imageUrl){
                DispatchQueue.main.async {
                    self.productImage.kf.setImage(with: url)
                }
            }
        }
    }
    
}

extension OrderDetailViewController{
    
    func createCustomPDFInvoice() {
        let pdfMetaData = [
            kCGPDFContextCreator: "Sipariş Faturası",
            kCGPDFContextAuthor: "Tural Babayev",
            kCGPDFContextTitle: "Fatura"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 595.2
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()

            // Fatura tasarımı başlıyor

            // Logo ekleme
            let logoImage = UIImage(named: "logo")
            let logoRect = CGRect(x: 50, y: 20, width: 100, height: 50)
            logoImage?.draw(in: logoRect)

            // Başlık
            let title = "Fatura"
            let titleFont = UIFont.boldSystemFont(ofSize: 32.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            let titleStringSize = title.size(withAttributes: titleAttributes)
            let titleStringRect = CGRect(x: (pageWidth - titleStringSize.width) / 2.0, y: 90, width: titleStringSize.width, height: titleStringSize.height)
            title.draw(in: titleStringRect, withAttributes: titleAttributes)

            // Üst bilgilendirme (Şirket & Tarih)
            let companyInfo = """
            Şirket Adı: Tural Babayev Ltd.
            Tarih: \(Date())
            """
            let companyInfoFont = UIFont.systemFont(ofSize: 14.0)
            let companyInfoAttributes: [NSAttributedString.Key: Any] = [.font: companyInfoFont, .foregroundColor: UIColor.darkGray]
            let companyInfoRect = CGRect(x: 50, y: 150, width: pageWidth - 100, height: 50)
            companyInfo.draw(in: companyInfoRect, withAttributes: companyInfoAttributes)

            // Çizgi ekleme
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: 50, y: 210))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 50, y: 210))
            context.cgContext.strokePath()

            // Müşteri bilgileri
            let customerInfo = """
            Fatura Alıcısı: \(username)
            Adres: Nef İnistanbul Sitesi, Maltepe Mah, Zeytinburnu
            E-Posta: \(email)
            """
            let customerInfoFont = UIFont.systemFont(ofSize: 16.0)
            let customerInfoAttributes: [NSAttributedString.Key: Any] = [.font: customerInfoFont, .foregroundColor: UIColor.black]
            let customerInfoRect = CGRect(x: 50, y: 230, width: pageWidth - 100, height: 100)
            customerInfo.draw(in: customerInfoRect, withAttributes: customerInfoAttributes)

            // Ürün Listesi
            let productHeader = "Ürün Detayları"
            let productHeaderFont = UIFont.boldSystemFont(ofSize: 18.0)
            let productHeaderAttributes: [NSAttributedString.Key: Any] = [.font: productHeaderFont, .foregroundColor: UIColor.black]
            let productHeaderRect = CGRect(x: 50, y: 350, width: pageWidth - 100, height: 30)
            productHeader.draw(in: productHeaderRect, withAttributes: productHeaderAttributes)

            let productDetails = """
            Ürün: \(productTitle.text!)
            \(productQty.text!)
            Birim Fiyatı: \(productPrice.text!)
            Toplam: \(totalAmountLabel.text!)
            """
            let productDetailsFont = UIFont.systemFont(ofSize: 16.0)
            let productDetailsAttributes: [NSAttributedString.Key: Any] = [.font: productDetailsFont, .foregroundColor: UIColor.black]
            let productDetailsRect = CGRect(x: 50, y: 380, width: pageWidth - 100, height: 100)
            productDetails.draw(in: productDetailsRect, withAttributes: productDetailsAttributes)

            // Toplam fiyat ve footer
            let totalPrice = """
            Ara Toplam: \(productPrice.text!)
            İndirim: \(discountLabel.text!)
            Toplam: \(totalAmountLabel.text!)
            """
            let totalPriceFont = UIFont.boldSystemFont(ofSize: 18.0)
            let totalPriceAttributes: [NSAttributedString.Key: Any] = [.font: totalPriceFont, .foregroundColor: UIColor.black]
            let totalPriceRect = CGRect(x: 50, y: 500, width: pageWidth - 100, height: 80)
            totalPrice.draw(in: totalPriceRect, withAttributes: totalPriceAttributes)

            // Çizgi
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: 50, y: 590))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 50, y: 590))
            context.cgContext.strokePath()

            // Teşekkür yazısı
            let footerText = "Teşekkürler!"
            let footerFont = UIFont.systemFont(ofSize: 14.0)
            let footerAttributes: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.darkGray]
            let footerRect = CGRect(x: (pageWidth - 100) / 2.0, y: 600, width: 300, height: 30)
            footerText.draw(in: footerRect, withAttributes: footerAttributes)
        }

        // PDF dosyasını belgeler dizinine kaydet
        pdfFilePath = getDocumentsDirectory().appendingPathComponent("invoice.pdf")
        do {
            try data.write(to: pdfFilePath!)
            print("PDF başarıyla kaydedildi: \(pdfFilePath!)")
            
            // PDF'yi kullanıcıya göster
            showPDF(fileURL: pdfFilePath!)
        } catch {
            print("PDF kaydedilemedi: \(error.localizedDescription)")
        }
    }
    
    // Belgeler dizinini alma fonksiyonu
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // PDF'yi gösterme fonksiyonu
    func showPDF(fileURL: URL) {
        // PDF Görüntüleme Alanı
        pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoScales = true
        self.view.addSubview(pdfView)
        
        if let document = PDFDocument(url: fileURL) {
            pdfView.document = document
        }

        // Kapat Butonu
        closeButton = UIButton(frame: CGRect(x: 20, y: 70, width: 40, height: 40))
        closeButton.setTitle("X", for: .normal)
        closeButton.backgroundColor = .red.withAlphaComponent(0.8)
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(closePDFView), for: .touchUpInside)
        self.view.addSubview(closeButton)

        // İndir Butonu
        downloadButton = UIButton(frame: CGRect(x: self.view.frame.width - 100, y: 70, width: 80, height: 40))
        downloadButton.setTitle("İndir", for: .normal)
        downloadButton.backgroundColor = UIColor(named: "appPrimary")
        downloadButton.layer.cornerRadius = 5
        downloadButton.addTarget(self, action: #selector(downloadPDF), for: .touchUpInside)
        self.view.addSubview(downloadButton)
    }

    // PDF Görüntüsünü kapatma fonksiyonu
    @objc func closePDFView() {
        pdfView.removeFromSuperview()
        closeButton.removeFromSuperview()
        downloadButton.removeFromSuperview()
    }

    // PDF'yi indirme fonksiyonu
    @objc func downloadPDF() {
        guard let fileURL = pdfFilePath else { return }
        
        // PDF'yi paylaşma ve indirme işlemi
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // iPad için gerekli
        present(activityViewController, animated: true, completion: nil)
    }
}
