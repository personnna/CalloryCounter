//
//  EditFoodItemViewController.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//


import UIKit
import SnapKit

final class EditFoodItemViewController: UIViewController {
    private let item: FoodItem
    private let onSave: (Int) -> Void
    
    private let caloriesTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    init(item: FoodItem, onSave: @escaping (Int) -> Void) {
        self.item = item
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Изменить калории"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // TextField
        caloriesTextField.text = "\(item.calories)"
        caloriesTextField.borderStyle = .roundedRect
        caloriesTextField.keyboardType = .numberPad
        caloriesTextField.font = .systemFont(ofSize: 18)
        caloriesTextField.backgroundColor = .secondarySystemBackground
        view.addSubview(caloriesTextField)
        
        // Save Button
        var config = UIButton.Configuration.filled()
        config.title = "Сохранить"
        saveButton.configuration = config
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        caloriesTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(caloriesTextField.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let text = caloriesTextField.text,
              let calories = Int(text),
              calories > 0 else {
            showErrorAlert()
            return
        }
        
        onSave(calories)
        dismiss(animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Введите корректное числo",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}