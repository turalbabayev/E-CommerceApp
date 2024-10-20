//
//  FirestoreRepository.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import FirebaseFirestore
import FirebaseAuth
import RxSwift

class FirestoreRepository{
    private let db = Firestore.firestore()
    var previousSearchList = BehaviorSubject<[String]>(value: [String]())
    var favoritedProducts = BehaviorSubject<[Products]>(value: [Products]())

        
    // Kullanıcı verilerini Firestore'a kaydetme
    func saveUserData(uid: String, email: String, username: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "username": username
        ]
        db.collection("users").document(uid).setData(userData, completion: completion)
    }

    // Kullanıcı verilerini Firestore'dan getirme
    func getUserData(uid: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                completion(.success(document.data() ?? [:]))
            } else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı."])))
            }
        }
    }
    
    func saveSearchHistory(username: String, searchTerm: String){
        let searchHistoryRef = db.collection("users").document(username).collection("searchHistory")
        
        /// Arama geçmişine yeni bir kayıt ekle
        searchHistoryRef.addDocument(data: [
            "searchTerm": searchTerm,
            "timestamp": FieldValue.serverTimestamp()  // Zaman damgası ekleniyor
        ])

    }
    
    func getSearchHistory(username: String) {
        let searchHistoryRef = db.collection("users").document(username).collection("searchHistory")
        
        searchHistoryRef.getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                // Belgeleri timestamp'e göre sıralama
                let sortedSearchTerms = snapshot?.documents.sorted(by: {
                    let date1 = ($0.data()["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let date2 = ($1.data()["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    return date1 > date2  // En yeni tarih en başta olacak
                }).compactMap { $0.data()["searchTerm"] as? String } ?? []

                // Sıralanmış verileri onNext ile gönderiyoruz
                print("Search text: \(sortedSearchTerms)")
                self.previousSearchList.onNext(sortedSearchTerms)
            }
        }
    }
    
    func deleteSearchTerm(username: String, searchTerm: String){
        let searchHistoryRef = db.collection("users").document(username).collection("searchHistory")

        searchHistoryRef.whereField("searchTerm", isEqualTo: searchTerm).getDocuments { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            } else{
                if let documents = snapshot?.documents{
                    for document in documents{
                        document.reference.delete()
                    }
                }
            }
        }
    }
    
    func clearSearchHistory(username: String){
        let searchHistoryRef = db.collection("users").document(username).collection("searchHistory")
        
        searchHistoryRef.getDocuments { snapshot, error in
            if let error = error{
                print(error.localizedDescription)
            }
            else{
                if let documents = snapshot?.documents{
                    for document in documents{
                        document.reference.delete()
                    }
                }
            }
        }
    }
    
    
    // Ürünü favorilere ekle
    func addProductToFavorites(product: Products, username: String, completion: @escaping (Error?) -> Void) {
        let favoritesRef = db.collection("users").document(username).collection("favorites")
        favoritesRef.document("\(product.id ?? 0)").setData([
            "id": product.id ?? 0,
            "ad": product.ad ?? "",
            "fiyat": product.fiyat ?? 0,
            "kategori": product.kategori,
            "resim": product.resim ?? "",
            "marka": product.marka ?? "",
            "timestamp": FieldValue.serverTimestamp()  // Timestamp ekliyoruz
        ]) { error in
            completion(error)
        }
    }


    func removeProductFromFavorites(product: Products, username: String, completion: @escaping (Error?) -> Void) {
        let favoritesRef = db.collection("users").document(username).collection("favorites")
        favoritesRef.document("\(product.id ?? 0)").delete { error in
            completion(error)
        }
    }


    func isProductInFavorites(product: Products, username: String, completion: @escaping (Bool) -> Void) {
        let favoritesRef = db.collection("users").document(username).collection("favorites")
        favoritesRef.document("\(product.id ?? 0)").getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
        
    // Tüm favori ürünleri getir
    func getFavoriteProducts(username: String, completion: @escaping ([Products]) -> Void) {
        let favoritesRef = db.collection("users").document(username).collection("favorites")
        
        favoritesRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Favorileri çekerken hata: \(error.localizedDescription)")
                completion([])
            } else {
                let products = snapshot?.documents.compactMap { document -> Products? in
                    let data = document.data()
                    let id = data["id"] as? Int ?? 0
                    let ad = data["ad"] as? String ?? ""
                    let fiyat = data["fiyat"] as? Int ?? 0
                    let kategori = data["kategori"] as? String ?? ""
                    let resim = data["resim"] as? String ?? ""
                    let marka = data["marka"] as? String ?? ""
                    return Products(id: id, ad: ad, resim: resim, kategori: kategori, fiyat: fiyat, marka: marka)
                }
                completion(products ?? [])
            }
        }
    }

    // Siparişi Firestore'a kaydetme fonksiyonu
    func saveOrder(userName: String, products: [ProductCart],amount: Amount, completion: @escaping (Bool) -> Void) {
        let ordersCollection = db.collection("orders")
        
        let orderData: [[String: Any]] = products.map { product in
            return [
                "productName": product.ad ?? "",
                "productPrice": product.fiyat ?? 0,
                "productImage": product.resim ?? "",
                "productQty": product.siparisAdeti ?? 1,
                "orderDate": Timestamp(date: Date()),
                "orderAmount": amount.orderAmount,
                "orderDiscountAmount" : amount.orderDiscountAmount,
                "orderDeliveryAmount" : amount.orderDeliveryAmount,
                "totalAmount" : amount.totalAmount
            ]
        }

        // Firestore'a ekleme işlemi, kullanıcı adına göre
        ordersCollection.addDocument(data: ["userName": userName, "products": orderData]) { error in
            if let error = error {
                print("Error saving order: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Kullanıcı adına göre siparişleri çekme fonksiyonu
    func getOrders(for userName: String, completion: @escaping ([Order]?) -> Void) {
        db.collection("orders")
            .whereField("userName", isEqualTo: userName)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting orders: \(error)")
                    completion(nil)
                } else {
                    var orders: [Order] = []
                    for document in snapshot!.documents {
                        let data = document.data()
                        
                        // Firestore'dan alınan veriler
                        let productsData = data["products"] as? [[String: Any]] ?? []
                        print("productsData: \(productsData)")
                        let orderDate = (data["orderDate"] as? Timestamp)?.dateValue() ?? Date()  // Sipariş tarihi
                        
                        // Firestore'dan alınan her bir ürün verisini `ProductCart` yapısına uygun hale getiriyoruz
                        let products: [ProductCart] = productsData.map { productData in
                            print(productData)
                            return ProductCart(
                                sepetId: 0,  // Sepet ID, eğer yoksa default olarak 0 veriyoruz
                                ad: productData["productName"] as? String ?? "",
                                resim: productData["productImage"] as? String ?? "",
                                kategori: "",  // Firestore'dan kategori gelmiyorsa boş bırakıyoruz
                                fiyat: productData["productPrice"] as? Int ?? 0,
                                marka: "",  // Firestore'dan marka gelmiyorsa boş bırakıyoruz
                                siparisAdeti: productData["productQty"] as? Int ?? 1,
                                kullaniciAdi: userName  // Firestore'dan gelen kullanıcı adı
                            )
                        }
                        
                        let amounts: [Amount] = productsData.map { productData in
                            return Amount(
                                orderAmount: productData["orderAmount"] as? String ?? "0",
                                orderDiscountAmount: productData["orderDiscountAmount"] as? String ?? "0",
                                orderDeliveryAmount: productData["orderDeliveryAmount"] as? String ?? "0",
                                totalAmount: productData["totalAmount"] as? String ?? "0")
                        }
                        // Sipariş oluşturuluyor
                        let order = Order(userName: userName, products: products, orderDate: orderDate, amount: amounts)
                        
                        orders.append(order)
                    }
                    // Veriyi aldıktan sonra tarihe göre sıralama yapıyoruz
                    let sortedOrders = orders.sorted { $0.orderDate > $1.orderDate }  // Tarihe göre azalan sıralama
                    completion(sortedOrders)
                }
            }
    }
    
    // Yorumları Firestore'a kaydetme
    func saveReview(productName: String, reviewText: String, rating: Double, completion: @escaping (Bool) -> Void) {
            let reviewsCollection = db.collection("productReviews").document(String(productName)).collection("reviews")
            
            let reviewData: [String: Any] = [
                "productName": productName,
                "reviewText": reviewText,
                "rating": rating,
                "userName": UserDefaults.standard.string(forKey: "savedUsername") ?? "Anonymous",
                "reviewDate": Timestamp(date: Date())
            ]
            
            reviewsCollection.addDocument(data: reviewData) { error in
                if let error = error {
                    print("Error saving review: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    
    
    // Rating bilgilerini dinleme (real-time listener)
    func listenForRatingChanges(productName: String, completion: @escaping (Double, Int) -> Void) {
        let reviewsCollection = db.collection("productReviews").whereField("productName", isEqualTo: productName)
        
        reviewsCollection.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(5.0, 0)  // No reviews, default rating
                return
            }
            
            var totalRating: Double = 0
            let reviewCount = snapshot.documents.count
            
            for document in snapshot.documents {
                let data = document.data()
                let rating = data["rating"] as? Double ?? 5.0
                totalRating += rating
            }
            
            let averageRating = reviewCount > 0 ? totalRating / Double(reviewCount) : 5.0
            completion(averageRating, reviewCount)
        }
    }


}
