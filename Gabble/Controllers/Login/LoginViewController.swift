//
//  LoginViewController.swift
//  Gabble
//
//  Created by ZoeZ on 11/20/20.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
    override func viewDidAppear(_ animated: Bool) {
        let keyChain = KeychainService().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "LoginToRootSegue", sender: self)
        }
        txtPassword.text = ""
    }
    
    func addKeychainAfterLogin(_ uid : String) {
        let keyChain = KeychainService().keyChain
        keyChain.set(uid, forKey: "uid")
    }
    
    @IBAction func LoginAction(_ sender: Any) {
        let email = txtEmail.text
        let password = txtPassword.text
        
        if email == "" || password!.count < 6 {
            alertUserLoginError(message: "Please enter email and correct password")
            return
        }
        
        if email?.isEmail == false {
            alertUserLoginError(message: "Please enter valid email")
            return
        }
        spinner.show(in: view)
        
        Auth.auth().signIn(withEmail: email!, password: password!) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }

            guard let result = authResult, error == nil else {
                print("Failed to log in user with email:\(email)")
                return
            }
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email!)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let nickname = userData["nickname"] as? String else {
                            return
                        }
                    UserDefaults.standard.set("\(nickname)", forKey: "nickname")
                    
                case .failure(let error):
                    print("Failed to read data with error: \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            let uid = Auth.auth().currentUser?.uid
            strongSelf.addKeychainAfterLogin(uid!)
            strongSelf.performSegue(withIdentifier: "LoginToRootSegue", sender: strongSelf)
            //strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            print("Logged in user: \(user)")
            
        }
    }
    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }


}
