//
//  FoodInputViewDelegate.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//

import UIKit
import SnapKit

protocol FoodInputViewDelegate: AnyObject {
    func foodInputViewDidTapAdd()
}

final class FoodInputView: UIView {
    weak var delegate: FoodInputViewDelegate?
    
    let foodNameTextField = UITextField()
    let addButton = UIButton(type: .system)
    
    private let photoButton = UIButton(type: .system)
    private let photoIndicator = UIImageView()
    
    var selectedPhotoImage: UIImage? {
        didSet {
            updatePhotoIndicator()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        foodNameTextField.placeholder = "Яблоко 95"
        foodNameTextField.borderStyle = .roundedRect
        foodNameTextField.returnKeyType = .done
        foodNameTextField.backgroundColor = .secondarySystemBackground
        foodNameTextField.font = .systemFont(ofSize: 16)
        addSubview(foodNameTextField)
        
        var photoConfig = UIButton.Configuration.tinted()
        photoConfig.image = UIImage(systemName: "paperclip")
        photoConfig.baseBackgroundColor = .systemBlue
        photoButton.configuration = photoConfig
        photoButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        addSubview(photoButton)
        
        photoIndicator.image = UIImage(systemName: "checkmark.circle.fill")
        photoIndicator.tintColor = .systemGreen
        photoIndicator.isHidden = true
        photoIndicator.contentMode = .scaleAspectFit
        addSubview(photoIndicator)
        
        var addConfig = UIButton.Configuration.filled()
        addConfig.image = UIImage(systemName: "paperplane.fill")
        addButton.configuration = addConfig
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addSubview(addButton)
    }
    
    private func setupConstraints() {
        foodNameTextField.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(photoButton.snp.left).offset(-8)
        }
        
        photoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
            make.right.equalTo(addButton.snp.left).offset(-8)
        }
        
        photoIndicator.snp.makeConstraints { make in
            make.top.right.equalTo(photoButton)
            make.width.height.equalTo(22)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
            make.right.equalToSuperview()
        }
    }
    
    @objc private func photoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        if let vc = parentViewController {
            vc.present(imagePicker, animated: true)
        }
    }
    
    @objc private func addButtonTapped() {
        delegate?.foodInputViewDidTapAdd()
    }
    
    private func updatePhotoIndicator() {
        if selectedPhotoImage != nil {
            photoIndicator.isHidden = false
        } else {
            photoIndicator.isHidden = true
        }
    }
    
    func clearPhoto() {
        selectedPhotoImage = nil
    }
    
    private var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}

extension FoodInputView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        defer {
            picker.dismiss(animated: true)
        }
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            selectedPhotoImage = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
