//
//  SignUpView.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit
import RxCocoa

class SignupView: UIView {
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField(placeHolder: "Name")
        return tf
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField(placeHolder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField(placeHolder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField(placeHolder: "Confirm Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(title: "Submit", borderColor: .greenBorderColor)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(title: "Cancel", borderColor: .redBorderColor)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = createStackView(views: [nameTextField,
                                                emailTextField,
                                                passwordTextField,
                                                confirmPasswordTextField,
                                                submitButton,
                                                cancelButton])
        addSubview(backgroundImageView)
        addSubview(stackView)
        
        backgroundImageView.setAnchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            paddingTop: 0,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0
        )
        
        stackView.setAnchor(width: frame.width - 60, height: 310)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SignupView {
    var name: String {
        return nameTextField.text ?? ""
    }
    
    var email: String {
        return emailTextField.text ?? ""
    }
    
    var password: String {
        return passwordTextField.text ?? ""
    }
    
    var confirmPassword: String {
        return confirmPasswordTextField.text ?? ""
    }
    
    var submitButtonTap: ControlEvent<Void> {
        return submitButton.rx.tap
    }
    
    var cancelButtonTap: ControlEvent<Void> {
        return cancelButton.rx.tap
    }
}
