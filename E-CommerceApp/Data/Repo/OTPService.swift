//
//  OTPService.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import RxSwift
import UIKit
import SwiftSMTP

class OTPService{
    static let shared = OTPService()
    private var currentOTP: String? // OTP kodunu saklayacak değişken

    
    private init() {}
    
    func generateOTP() -> String{
        if currentOTP == nil {
            currentOTP = String(format: "%04d", arc4random_uniform(10000)) // 4 haneli OTP oluştur
            print("Oluşturulan OTP kodu: \(currentOTP!)")
        }
        return currentOTP!
    }
    

    func sendOTPEmail(to email: String) -> Observable<Bool> {
        return Observable.create { observer in
            let otpCode = OTPService.shared.generateOTP()
            // SMTP Ayarları
            let smtp = SMTP(
                hostname: "smtp.mailgun.org", // SMTP hostname
                email: "postmaster@sandboxcedfcdce1fe04f6bbe37935d50335e66.mailgun.org", // SMTP username
                password: "d332ceee51c6a90c82a93f5fe7af8fb9-5dcb5e36-55b644ee", // SMTP password
                port: 587, // SMTP port
                tlsMode: .normal
            )

            // Gönderen ve Alıcı Ayarları
            let from = Mail.User(name: "YourApp", email: "postmaster@sandboxcedfcdce1fe04f6bbe37935d50335e66.mailgun.org")
            let to = Mail.User(name: "", email: email)

            // E-posta İçeriği
            let mail = Mail(
                from: from,
                to: [to],
                subject: "Your OTP Code",
                text: "Your OTP code is: \(otpCode)" // OTP kodu
            )

            // E-posta gönderimi
            smtp.send(mail) { error in
                if let error = error as? SMTPError {
                    print("E-posta gönderimi başarısız oldu: \(error.localizedDescription)")
                    observer.onError(error)
                } else {
                    print("E-posta başarıyla gönderildi!")
                    observer.onNext(true)
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    func resetOTP() {
            currentOTP = nil
        }

    // Bu fonksiyon ile OTP kodunu başka sınıflarda alabiliriz
    func getCurrentOTP() -> String? {
        return currentOTP
    }
}
