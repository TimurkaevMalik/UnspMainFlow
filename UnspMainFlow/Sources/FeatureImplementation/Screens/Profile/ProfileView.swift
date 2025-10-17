//
//  ProfileView.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import SnapKit
import CoreKit
import KeychainStorageKit

final class ProfileView: UIView {
    
    ///Публичная кнопка, чтобы ParentController добавил UIAction
    lazy var openGalleryButton = UIButton(type: .system)
    
    private lazy var avatarImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var nicknameLabel = UILabel()
      
    func setupUI() {
        setupSubViews()
        setupLayout()
        setupData()
    }
}

// MARK: - Setup
private extension ProfileView {
    func setupSubViews() {
        backgroundColor = Palette.Asset.whitePrimary.uiColor
        
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.layer.borderColor = Palette.Asset.blackPrimary.uiColor.cgColor
        avatarImageView.layer.borderWidth = 1
        
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.textColor = Palette.Asset.blackPrimary.uiColor
        
        nicknameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        nicknameLabel.textAlignment = .center
        nicknameLabel.textColor = .gray
        
        openGalleryButton.setTitle("Открыть галерею", for: .normal)
        openGalleryButton.backgroundColor = Palette.Asset.blackPrimary.uiColor
        openGalleryButton.tintColor = Palette.Asset.whitePrimary.uiColor
        openGalleryButton.layer.cornerRadius = 10
    }
    
    func setupLayout() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(nicknameLabel)
        addSubview(openGalleryButton)
        
        avatarImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        openGalleryButton.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(44)
        }
    }
    
    func setupData() {
        avatarImageView.image = UIImage(resource: .userPhoto)
        nameLabel.text = "Alex Junior"
        nicknameLabel.text = "@alexjunior"
    }
}
