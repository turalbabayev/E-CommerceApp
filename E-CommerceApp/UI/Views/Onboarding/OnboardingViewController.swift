//
//  OnboardingViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 11.10.2024.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var buttonNext: UIButton!
    
    var slides: [OnboardingSlide] = []
    var currentPage = 0{
        didSet{
            pageControl.currentPage = currentPage

            if currentPage == slides.count - 1 {
                buttonNext.setTitle("Alışverişe Başla", for: .normal)
            }else{
                buttonNext.setTitle("Sonraki", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
     
        slides = [
            OnboardingSlide(title: "En İyi Ürünleri Keşfedin", description: "Binlerce ürüne göz atın ve istediğiniz ürünü bulun", image: UIImage(named: "onboarding1")!),
            OnboardingSlide(title: "Satın Alma işleminizi Onaylayın", description: "Son satın alımınızı yapın ve hızlı teslimattan yararlanın", image: UIImage(named: "onboarding2")!)
        ]
        
        
    }
    

    
    @IBAction func buttonNextTapped(_ sender: UIButton) {
        if currentPage == slides.count - 1{
            // Onboarding ekranının tamamlandığını kaydet
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            
            // Giriş yapmadıysa login sayfasına yönlendir
            let loginViewController = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            loginViewController.modalPresentationStyle = .fullScreen // Tam ekran olarak göster
            present(loginViewController, animated: true, completion: nil)

        }
        else{
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            collectionView.reloadData()

        }
        
    }
    
}


extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingCell", for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
    
}
