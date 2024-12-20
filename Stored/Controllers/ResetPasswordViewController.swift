//
//  ResetPasswordViewController.swift
//  Stored
//
//  Created by iOS on 19/12/24.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func forgetPasswordButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email address to reset your password.")
            return
        }
        
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.showAlert(message: "Failed to send password reset email. \(error.localizedDescription)")
            } else {
                strongSelf.showAlert(message: "A password reset email has been sent to \(email). Please check your inbox.") {
                    // Perform dismiss only after user taps OK on the alert
                    strongSelf.dismiss(animated: true, completion: nil)
                }
            }
            
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?() // This only gets called after tapping OK
        }))
        present(alert, animated: true, completion: nil)
    }
}
