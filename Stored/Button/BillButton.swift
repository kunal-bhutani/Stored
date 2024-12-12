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
        let buttonImage = UIImage(systemName: "plus.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 37, weight: .regular, scale: .large)) // Adjust size here

        setImage(buttonImage, for: .normal)
        self.setImage(buttonImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        tintColor = UIColor(named: "Background")
        
        titleLabel?.font = UIFont.systemFont(ofSize: 300)  // Adjust font size here
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
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -26),
            
//            widthAnchor.constraint(equalToConstant: 80),  // Adjust width here
//            heightAnchor.constraint(equalToConstant: 60)
        ])

        // Make sure the button is above all other views
        view.bringSubviewToFront(self)

    }
}

