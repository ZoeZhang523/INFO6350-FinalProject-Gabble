//
//  ResetPasswordViewController.swift
//  Gabble
//
//  Created by ZoeZ on 11/30/20.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func confirmAction(_ sender: Any) {
    
        let email = txtEmail.text
        
        if email?.isEmail == false {
            alertResetPasswordError(message: "Please enter valid email")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email!) { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            if error != nil {
                strongSelf.alertResetPasswordError(message: "Reset Failed")
            } else {
                strongSelf.alertResetPasswordError(message: "Reset Email Sent")
                
            }
        }
    }
    func alertResetPasswordError(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}
