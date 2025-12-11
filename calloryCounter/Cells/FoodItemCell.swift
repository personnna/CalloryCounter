//
//  FoodItemCell.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//

import UIKit
import SnapKit

final class FoodItemCell: UITableViewCell {
    static let identifier = "FoodItemCell"
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let caloriesLabel = UILabel()
    private let caloriesUnitLabel = UILabel()
    private let photoImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        contentView.addSubview(containerView)
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        containerView.addSubview(nameLabel)
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 8
        containerView.addSubview(photoImageView)
        
        caloriesLabel.font = .systemFont(ofSize: 32, weight: .bold)
        caloriesLabel.textColor = .systemBlue
        containerView.addSubview(caloriesLabel)
        
        caloriesUnitLabel.font = .systemFont(ofSize: 12, weight: .regular)
        caloriesUnitLabel.textColor = .systemGray
        caloriesUnitLabel.text = "kcal"
        containerView.addSubview(caloriesUnitLabel)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.right.lessThanOrEqualTo(caloriesLabel.snp.left).offset(-12)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().inset(12)
        }
        
        caloriesLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(12)
        }
        
        caloriesUnitLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(caloriesLabel.snp.bottom).offset(2)
        }
    }
    
    func configure(with item: FoodItem) {
        nameLabel.text = item.name
        caloriesLabel.text = "\(item.calories)"
        
        if let photoData = item.photoData, let image = UIImage(data: photoData) {
            photoImageView.image = image
            photoImageView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.photoImageView.alpha = 1.0
            })
        } else {
            photoImageView.image = nil
            photoImageView.alpha = 1.0
        }
    }
}
