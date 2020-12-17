//
//  RegisterViewController.swift
//  Gabble
//
//  Created by ZoeZ on 11/20/20.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtNickname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let keyChain = KeychainService().keyChain
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "signupToRootSegue", sender: self)
        }
        //txtPassword.text = ""
    }
    
    func addKeychainAfterSignUp( _ uid : String) {
        let keyChain = KeychainService().keyChain
        keyChain.set(uid, forKey: "uid")
    }
    
    @IBAction func RegisterAction(_ sender: Any) {
        let nickname = txtNickname.text
        let email = txtEmail.text
        let password = txtPassword.text
        
        if email == "" || password!.count < 6 || nickname == ""{
            alertUserLoginError(message: "Please enter all needed informaiton to sign up")
            return
        }
        
        if email?.isEmail == false {
            alertUserLoginError(message: "Please enter valid email")
            return
        }
        
        spinner.show(in: view)
        
        DatabaseManager.shared.userExists(with: email!, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                strongSelf.alertUserLoginError(message: "Looks like a user account for this email already exists.")
                return
            }
            
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in

                guard authResult != nil, error == nil else {
                    print("Error creating user!")
                    return
                }

                //strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                let chatUser = ChatAppUser(nickname: nickname!, emailAddress: email!)
                DatabaseManager.shared.insertUser(with: chatUser, completion: {success in
                    if success {
                        //Upload image
                        guard let image = strongSelf.imgView.image, let data = image.pngData() else {
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    }
                })
                
                let uid = Auth.auth().currentUser?.uid
                strongSelf.addKeychainAfterSignUp(uid!)
                strongSelf.performSegue(withIdentifier: "signupToConversationSegue", sender: strongSelf)
                
            }
        })
        
    }
    
    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func didTapImageView(_ sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        
        let choosePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { action in
            if ( UIImagePickerController.isSourceTypeAvailable(.camera)){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let takePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { action in
            if ( UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel")
        }
        
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(choosePhotoAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            imgView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
