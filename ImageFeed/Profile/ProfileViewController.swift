//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Amir on 05.07.2026.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUIElements()
    }
    
    func setupUIElements(){
        let profileImage = UIImage(named: "Photo")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.layer.cornerRadius = 35
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailLabel = UILabel()
        emailLabel.text = "@ekaterina_nov"
        emailLabel.textColor = .ypGray
        emailLabel.font = UIFont.systemFont(ofSize: 13)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let helloTextLabel = UILabel()
        helloTextLabel.text = "Hello, world!"
        helloTextLabel.textColor = .ypWhite
        helloTextLabel.font = UIFont.systemFont(ofSize: 13)
        helloTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        guard let exitButtonImage = UIImage(named: "Exit button") else { return }
        let exitButton = UIButton.systemButton(
            with: exitButtonImage,
            target: self,
            action: nil)
        exitButton.tintColor = UIColor.ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(helloTextLabel)
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            helloTextLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            helloTextLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            helloTextLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
