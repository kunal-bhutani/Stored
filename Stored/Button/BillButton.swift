//
//  BillButton.swift
//  Stored
//
//  Created by student on 08/05/24.
//
import UIKit

class BillButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        // Set button image
        let buttonImage = UIImage(named: "BillScanButtonSmall")
        setImage(buttonImage, for: .normal)
        self.setImage(buttonImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        

        // Apply drop shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 4

    }

}
extension BillButton {
    func setupUI(in view: UIView) {
        // Add button to the view
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -100),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26)
        ])

        // Make sure the button is above all other views
        view.bringSubviewToFront(self)

    }
}

