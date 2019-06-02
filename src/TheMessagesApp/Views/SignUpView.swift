//
//  SignUpView.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import UIKit

class SignUpView: UIView {
    var submitAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "background")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField(placeHolder: "Name")
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField(placeHolder: "Email")
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField(placeHolder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let confirmPasswordTextField: UITextField = {
        let tf = UITextField(placeHolder: "Confirm Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(title: "Submit", borderColor: .greenBorderColor)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(title: "Cancel", borderColor: .redBorderColor)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SignUpView {
    func setupViews() {
        let stackView = createStackView(views: [nameTextField,
                                                emailTextField,
                                                passwordTextField,
                                                confirmPasswordTextField,
                                                submitButton,
                                                cancelButton])
        addSubview(backgroundImageView)
        addSubview(stackView)
    
        backgroundImageView.setAnchor(top: topAnchor,
                                      left: leftAnchor,
                                      bottom: bottomAnchor,
                                      right: rightAnchor,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: 0,
                                      paddingRight: 0)
        stackView.setAnchor(width: frame.width - 60, height: 310)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}


extension SignUpView {
    @objc func handleSubmit() {
        submitAction?()
    }
    
    @objc func handleCancel() {
        cancelAction?()
    }
}
