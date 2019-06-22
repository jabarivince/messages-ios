//
//  LoginView.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import RxCocoa
import UIKit

class LoginView: UIView {
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background")
        iv.contentMode = .scaleAspectFill
        return iv
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
    
    private let loginButton: UIButton = {
        let button = UIButton(title: "Login", borderColor: .greenBorderColor)
        return button
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(title: "SignUp", borderColor: .redBorderColor)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = createStackView(views: [emailTextField,
                                                passwordTextField,
                                                loginButton,
                                                signupButton])
        
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
        
        stackView.setAnchor(width: frame.width - 60, height: 210)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginView {
    var email: String {
        return emailTextField.text ?? ""
    }
    
    var password: String {
        return passwordTextField.text ?? ""
    }
    
    var loginButtonTap: ControlEvent<Void> {
        return loginButton.rx.tap
    }
    
    var signupButtonTap: ControlEvent<Void> {
        return signupButton.rx.tap
    }
    
    func clear() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}
