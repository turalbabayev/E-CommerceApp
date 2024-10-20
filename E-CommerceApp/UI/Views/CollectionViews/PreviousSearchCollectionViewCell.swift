//
//  PreviousSearchCollectionViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit

protocol CellProtocolPrevious{
    func deleteButtonTapped(indexPath: IndexPath)
}

class PreviousSearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backgroundViewCell: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var indexPath: IndexPath?
    var cellProtocol: CellProtocolPrevious?

    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        cellProtocol?.deleteButtonTapped(indexPath: indexPath!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Arka planın yuvarlanmasını sağlamak
        backgroundViewCell.layer.cornerRadius = 12
        backgroundViewCell.layer.borderWidth = 1
        backgroundViewCell.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}
