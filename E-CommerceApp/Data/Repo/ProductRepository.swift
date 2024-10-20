//
//  ProductRepository.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import Foundation
import RxSwift
import Alamofire
import Kingfisher

class ProductRepository{
    var productList = BehaviorSubject<[Products]>(value: [Products]())
    var productListInCart = BehaviorSubject<[ProductCart]>(value: [ProductCart]())
    var categoryList = BehaviorSubject<[Category]>(value: [Category]())
    
    func loadProducts(){
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data{
                do{
                    let dataResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = dataResponse.urunler{
                        self.productList.onNext(list)
                    }
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func filterProductsByCategory(selectedCategories: [String]) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let dataResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = dataResponse.urunler {
                        
                        // Seçilen kategorilere göre ürünleri filtrele
                        
                        let filteredProducts = list.filter { product in
                            return selectedCategories.contains(product.kategori)
                        }
                        
                        print(filteredProducts)
                        // Filtrelenmiş ürünleri yay
                        self.productList.onNext(filteredProducts)
                        
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func filterProductsByPrice(maxPrice: Int){
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let dataResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = dataResponse.urunler {
                        
                        // Ürün listesini fiyat aralığına göre filtrele
                        let filteredProducts = list.filter { product in
                            if let productPrice = product.fiyat {
                                return productPrice <= maxPrice
                            }
                            return false
                        }
                        

                        self.productList.onNext(filteredProducts)
                        
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // Kategori ve fiyata göre filtreleme yapar
    func filterProductsByCategoryAndPrice(selectedCategories: [String], maxPrice: Int) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let dataResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = dataResponse.urunler {
                        // Kategori ve fiyata göre filtreleme yap
                        let filteredProducts = list.filter { product in
                            let isInCategory = selectedCategories.isEmpty || selectedCategories.contains(product.kategori)
                            let isWithinPriceRange = Int(product.fiyat!) <= maxPrice
                            return isInCategory && isWithinPriceRange
                        }
                        
                        // Filtrelenmiş sonuçları yay
                        self.productList.onNext(filteredProducts)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    
    func searchProductsLocally(searchTerm: String) {
        let url = "http://kasimadalan.pe.hu/urunler/tumUrunleriGetir.php"
        
        AF.request(url, method: .get).response { response in
            if let data = response.data {
                do {
                    let dataResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    if let list = dataResponse.urunler {
                        // Yerel filtreleme: Arama kelimesine göre ürünleri filtrele
                        let filteredProducts = list.filter { product in
                            return product.ad!.lowercased().contains(searchTerm.lowercased())
                        }
                        
                        // Filtrelenmiş sonuçları yay
                        self.productList.onNext(filteredProducts)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getImageURL(for imageName: String) -> String {
        return "http://kasimadalan.pe.hu/urunler/resimler/\(imageName)"
    }
    
    func deleteProductInCart(cartId: Int, username: String, completion: @escaping (Bool) -> Void){
        let url = "http://kasimadalan.pe.hu/urunler/sepettenUrunSil.php"
        let params: Parameters = ["sepetId": cartId, "kullaniciAdi": username]
        
        AF.request(url, method: .post, parameters: params).response { response in
            if let data = response.data{
                do {
                    let _ = try JSONDecoder().decode(CRUDResponse.self, from: data)
                    completion(true)
                } catch {
                    completion(false)
                    print("JSON Decode Hatası Delete: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addProductToCart(name: String, productImage: String, productCategory: String, productPrice: Int, productBrand: String, productQty: Int, username: String, completion: @escaping (Bool) -> Void) {
        let getProductUrl = "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php"
        let paramsGet: Parameters = ["kullaniciAdi": username]
        
        AF.request(getProductUrl, method: .post, parameters: paramsGet).response { response in
            if let data = response.data {
                if data.count == 5 {
                    self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: productQty, username: username, completion: completion)
                } else {
                    do {
                        let products = try JSONDecoder().decode(ProductCartResponse.self, from: data)
                        
                        if let existingProduct = products.urunler_sepeti?.first(where: { product in
                            product.ad == name
                        }) {
                            self.deleteProductInCart(cartId: existingProduct.sepetId!, username: username) { success in
                                if success{
                                    let newQty = existingProduct.siparisAdeti! + productQty
                                    self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: newQty, username: username, completion: completion)
                                }
                            }
                            
                        } else {
                            self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: productQty, username: username, completion: completion)
                        }
                    } catch {
                        print("JSON Decode Hatası: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        }
    }
    
    func updateProductInCart(name: String, productImage: String, productCategory: String, productPrice: Int, productBrand: String, productQty: Int, username: String,process: Bool, completion: @escaping (Bool) -> Void) {
        let getProductUrl = "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php"
        let paramsGet: Parameters = ["kullaniciAdi": username]
        
        AF.request(getProductUrl, method: .post, parameters: paramsGet).response { response in
            if let data = response.data {
                if data.count == 5 {
                    self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: productQty, username: username, completion: completion)
                } else {
                    do {
                        let products = try JSONDecoder().decode(ProductCartResponse.self, from: data)
                        
                        if let existingProduct = products.urunler_sepeti?.first(where: { product in
                            product.ad == name
                        }) {
                            self.deleteProductInCart(cartId: existingProduct.sepetId!, username: username) { success in
                                if success{
                                    if process{
                                        let newQty = existingProduct.siparisAdeti! + 1
                                        self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: newQty, username: username, completion: completion)
                                    }else{
                                        let newQty = existingProduct.siparisAdeti! - 1
                                        self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: newQty, username: username, completion: completion)
                                    }
                                    
                                }
                            }
                            
                        } else {
                            self.addNewProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: productQty, username: username, completion: completion)
                        }
                    } catch {
                        print("JSON Decode Hatası: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        }
    }

    func addNewProductToCart(name: String, productImage: String, productCategory: String, productPrice: Int, productBrand: String, productQty: Int, username: String, completion: @escaping (Bool) -> Void) {
        let url = "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php"
        let params: Parameters = ["ad": name, "resim": productImage, "kategori": productCategory, "fiyat": productPrice, "marka": productBrand, "siparisAdeti": productQty, "kullaniciAdi": username]
        
        AF.request(url, method: .post, parameters: params).response { response in
            if let data = response.data {
                do {
                    let dataResponse = try JSONDecoder().decode(CRUDResponse.self, from: data)
                    if dataResponse.success == 1 {
                        self.getProductInCart(username: username)
                        completion(true)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("JSON Decode Hatası Yeni: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    func getProductInCart(username: String){
        let url = "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php"
        let params: Parameters = ["kullaniciAdi": username]
        
        AF.request(url, method: .post, parameters: params).response { response in
            
            if let data = response.data{
                
                do{
                    let dataResponse = try JSONDecoder().decode(ProductCartResponse.self, from: data)
                    
                    if let list = dataResponse.urunler_sepeti{
                        self.productListInCart.onNext(list)
                    }
                    
                }catch{
                    if data.count == 5{
                        self.productListInCart.onNext([])
                    }else{
                        print("JSON Decode Hatası Load: \(error.localizedDescription)")

                    }
                }
                        
                
            }
        }
        
    }
    
    func getCategoryList(){
        var cList = [Category]()
        cList = [
            Category(id: 1, title: "Teknoloji", image: "macbookImage"),
            Category(id: 2, title: "Aksesuar", image: "saat"),
            Category(id: 3, title: "Kozmetik", image: "ruj"),
            Category(id: 4, title: "Yeni Gelenler", image: "yenigelenler"),
            Category(id: 5, title: "Fırsatlar", image: "firsatlar"),
            Category(id: 6, title: "Çok Satanlar ", image: "parfum"),
            Category(id: 7, title: "En Beğenilen", image: "gozluk"),
            Category(id: 8, title: "Popüler Ürünler", image: "dyson")
        ]
        categoryList.onNext(cList)
    }
    
    func fetchDescriptions() -> [Description] {
        return [
            Description(productId: 1, description: "Apple Bilgisayar, ince ve hafif tasarımıyla taşınabilirliği ön planda tutan, güçlü performansı ve uzun pil ömrüyle dikkat çeken bir dizüstü bilgisayardır. Retina ekranı, canlı ve net görüntüler sunar."),
            Description(productId: 2, description: "Ray-Ban gözlükler, ikonik tasarımları ve yüksek kaliteli lensleriyle ünlü, hem stil hem de göz koruması sunan gözlüklerdir. Dayanıklı yapısı ve zarif görünümüyle her tarza uyum sağlar."),
            Description(productId: 3, description: "Sony kulaklıklar, üstün ses kalitesi ve konforlu tasarımıyla müzik deneyimini bir üst seviyeye taşır. Aktif gürültü engelleme özelliği, dış sesleri izole ederek kesintisiz dinleme sağlar. Hem günlük kullanım hem de profesyonel performans için idealdir."),
            Description(productId: 4, description: "Armani parfümleri, sofistike ve zarif kokularıyla lüksü yansıtır. Kaliteli içeriklerden üretilen bu parfümler, her ortamda kalıcı ve etkileyici bir iz bırakmak isteyenler için mükemmel bir tercihtir."),
            Description(productId: 5, description: "Casio saatler, dayanıklılığı, işlevselliği ve şık tasarımıyla bilinen, güvenilir bir markadır. Geniş model yelpazesiyle hem spor hem de klasik tarzlara uyum sağlar. Teknolojik özellikleri ve uzun ömürlü yapısıyla her zaman güvenilir bir kullanım sunar."),
            Description(productId: 6, description: "Dyson süpürgeler, güçlü emiş gücü ve yenilikçi teknolojisiyle derinlemesine temizlik sağlar. Tozları ve alerjenleri etkili bir şekilde hapsederken, kablosuz ve hafif tasarımıyla kullanımı son derece pratiktir. Dayanıklı yapısı ve uzun pil ömrüyle öne çıkar."),
            Description(productId: 7, description: "Apple telefonlar, güçlü performansı, kaliteli kamerası ve şık tasarımıyla öne çıkan, yenilikçi teknolojilere sahip akıllı telefonlardır. iOS işletim sistemiyle sorunsuz ve güvenli bir kullanıcı deneyimi sunar."),
            Description(productId: 8, description: "Hugo Boss deodorantları, ferahlatıcı ve uzun süre kalıcı kokularıyla gün boyu tazelik sağlar. Şıklığı ve kaliteli formülüyle kişisel bakımda vazgeçilmez bir tercihdir."),
            Description(productId: 9, description: "Dior kemer, zarif tasarımı ve kaliteli malzemeleriyle lüksü yansıtır. Şık detayları ve sofistike duruşuyla her kıyafete zarafet katar."),
            Description(productId: 10, description: "Lancôme kremler, cildi nemlendirip beslerken, yumuşak ve sağlıklı bir görünüm kazandırır. Yüksek kaliteli içerikleriyle cilt bakımında fark yaratır."),
            Description(productId: 11, description: "Tom Ford rujları, zengin pigmentleri ve uzun süre kalıcı formülüyle dudaklara mükemmel bir renk ve parlaklık sağlar. Şık ambalajıyla lüksü tamamlar."),
            Description(productId: 12, description: "Versace şapkalar, ikonik tasarımı ve kaliteli yapısıyla tarzınızı tamamlar. Hem spor hem de şık kombinlerle uyum sağlar.")
        ]
    }
    
    
}
