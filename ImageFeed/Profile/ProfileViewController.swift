//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Amir on 05.07.2026.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject{
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar()
    func updateProfileDetails(profile: Profile)
}

class ProfileViewController: UIViewController , ProfileViewControllerProtocol{
    var presenter: ProfileViewPresenterProtocol?
    
    private var nameLabel = UILabel()
    private var usernameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var profileImageView = UIImageView()
    private var exitButton = UIButton()
    
    private lazy var nameLabelSkeleton = SkeletonView()
    private lazy var usernameLabelSkeleton = SkeletonView()
    private lazy var descriptionLabelSkeleton = SkeletonView()
    private lazy var profileImageViewSkeleton = SkeletonView()
    
    var animationLayers = Set<CALayer>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.accessibilityIdentifier = "ProfileViewController"
        
        // Do any additional setup after loading the view.
        setupUIElements()
        setupSkeleton()
        startSkeletonAnimation()
        
        if presenter == nil{
            presenter = ProfileViewPresenter()
        }
        
        
        presenter?.view = self
        presenter?.viewDidLoad()
        
    }
    
    private func setupSkeleton(){
        [nameLabelSkeleton, usernameLabelSkeleton, descriptionLabelSkeleton, profileImageViewSkeleton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        profileImageViewSkeleton.layer.cornerRadius = 35
        profileImageViewSkeleton.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            profileImageViewSkeleton.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            profileImageViewSkeleton.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            profileImageViewSkeleton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            profileImageViewSkeleton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            nameLabelSkeleton.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameLabelSkeleton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameLabelSkeleton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nameLabelSkeleton.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            usernameLabelSkeleton.topAnchor.constraint(equalTo: usernameLabel.topAnchor),
            usernameLabelSkeleton.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            usernameLabelSkeleton.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            usernameLabelSkeleton.bottomAnchor.constraint(equalTo: usernameLabel.bottomAnchor),
            descriptionLabelSkeleton.topAnchor.constraint(equalTo: descriptionLabel.topAnchor),
            descriptionLabelSkeleton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            descriptionLabelSkeleton.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            descriptionLabelSkeleton.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor)
        ])
    }
    
    private func startSkeletonAnimation(){
        profileImageViewSkeleton.startAnimation()
        nameLabelSkeleton.startAnimation()
        usernameLabelSkeleton.startAnimation()
        descriptionLabelSkeleton.startAnimation()
    }
    
    private func hideSkeletonAnimation(_ skeleton: SkeletonView?){
        skeleton?.stopAnimating()
        skeleton?.removeFromSuperview()
    }
    
    func updateAvatar(){
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else{
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.setImage(with: url,
                                     placeholder: UIImage(named: "Photo"),
                                     options: [.processor(processor)]) { [weak self] _ in
            self?.hideSkeletonAnimation(self?.profileImageViewSkeleton)
        }
    }
    
    func updateProfileDetails(profile: Profile){
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
        
        hideSkeletonAnimation(nameLabelSkeleton)
        hideSkeletonAnimation(usernameLabelSkeleton)
        hideSkeletonAnimation(descriptionLabelSkeleton)
    }
    
    func setupUIElements(){
        self.view.backgroundColor = UIColor.ypBlack
        
        let profileImage = UIImage(named: "Photo")
        profileImageView = UIImageView(image: profileImage)
        profileImageView.layer.cornerRadius = 35
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel = UILabel()
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.textColor = .ypGray
        usernameLabel.font = UIFont.systemFont(ofSize: 13)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        guard let exitButtonImage = UIImage(named: "Exit button") else { return }
        exitButton = UIButton.systemButton(
            with: exitButtonImage,
            target: self,
            action: nil)
        exitButton.tintColor = UIColor.ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        exitButton.accessibilityIdentifier = "logoutButton"
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(exitButton)
        
        exitButton.addTarget(self, action: #selector(logoutButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    @objc private func logoutButton(){
        showAlert(title: "Пока, пока!", message: "Уверены, что хотите выйти?", yesComplition: { [weak self] in
            self?.presenter?.logout()
        })
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



extension ProfileViewController{
    func showAlert(title: String, message: String, yesComplition: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .cancel) { _ in
            yesComplition?()
        }
        let noAction = UIAlertAction(title: "Нет", style: .default)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        alertController.preferredAction = noAction
        present(alertController, animated: true)
    }
}
