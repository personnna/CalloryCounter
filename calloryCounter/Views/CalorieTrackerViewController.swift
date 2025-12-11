//
//  CalorieTrackerViewController.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//
import UIKit
import SnapKit
import SwiftData

final class CalorieTrackerViewController: UIViewController {
    private let viewModel: CalorieTrackerViewModel
    
    private let dailyTotalView = DailyTotalView()
    private let foodInputView = FoodInputView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private let emptyStateImageView = UIImageView()
    
    init(viewModel: CalorieTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
        
        viewModel.delegate = self
        viewModel.fetchTodayItems()
        
        addKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Калории"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(dailyTotalView)
        
        foodInputView.delegate = self
        view.addSubview(foodInputView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FoodItemCell.self, forCellReuseIdentifier: FoodItemCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = true
        view.addSubview(tableView)
        
        emptyStateImageView.image = UIImage(systemName: "fork.knife")
        emptyStateImageView.tintColor = .systemGray3
        view.addSubview(emptyStateImageView)
        
        emptyStateLabel.text = "Начните добавлять блюда"
        emptyStateLabel.textColor = .systemGray
        emptyStateLabel.font = .systemFont(ofSize: 16)
        emptyStateLabel.textAlignment = .center
        view.addSubview(emptyStateLabel)
        
        updateEmptyState()
    }
    
    private func setupConstraints() {
        dailyTotalView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(180)
        }
        
        foodInputView.snp.makeConstraints { make in
            make.top.equalTo(dailyTotalView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(foodInputView.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyStateImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.size.equalTo(60)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    private func setupDelegates() {
        foodInputView.foodNameTextField.delegate = self
    }
    
    // MARK: - Keyboard
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: 0.3) {
            self.tableView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(keyboardHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.tableView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Helpers
    private func updateEmptyState() {
        let isEmpty = viewModel.items.isEmpty
        UIView.animate(withDuration: 0.3) {
            self.emptyStateImageView.alpha = isEmpty ? 1.0 : 0.0
            self.emptyStateLabel.alpha = isEmpty ? 1.0 : 0.0
            self.tableView.alpha = isEmpty ? 0.0 : 1.0
        }
    }
    
    private func showDeleteAlert(for item: FoodItem) {
        let alert = UIAlertController(
            title: "Удалить блюдо?",
            message: "Вы уверены, что хотите удалить '\(item.name)'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.viewModel.deleteItem(item)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - FoodInputViewDelegate
extension CalorieTrackerViewController: FoodInputViewDelegate {
    func foodInputViewDidTapAdd() {
        guard let text = foodInputView.foodNameTextField.text, !text.isEmpty else {
            return
        }
        
        let photoData = foodInputView.selectedPhotoImage?.jpegData(compressionQuality: 0.6)
        
        viewModel.addItem(input: text, photoData: photoData)
        foodInputView.foodNameTextField.text = ""
        foodInputView.clearPhoto()
    }
}

// MARK: - CalorieTrackerViewModelDelegate
extension CalorieTrackerViewController: CalorieTrackerViewModelDelegate {
    func viewModelDidUpdateItems() {
        DispatchQueue.main.async {
            self.dailyTotalView.updateTotal(self.viewModel.totalCalories)
            self.tableView.reloadData()
            self.updateEmptyState()
        }
    }
    
    func viewModelDidShowAlert(type: CalorieTrackerViewModel.AlertType) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            switch type {
            case .invalidFormat:
                alert.title = "Ошибка"
                alert.message = "Неверный формат. Используйте: 'Яблоко 95'"
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                
            case .duplicateItem(let name):
                alert.title = "Внимание"
                alert.message = "'\(name)' уже добавлен сегодня"
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                
            case .success(let name, let calories):
                alert.title = "✅ Успешно"
                alert.message = "'\(name)' (+\(calories) kcal) добавлено!"
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
            }
            
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension CalorieTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        foodInputViewDidTapAdd()
        return true
    }
}

// MARK: - UITableViewDelegate & DataSource
extension CalorieTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodItemCell.identifier, for: indexPath) as! FoodItemCell
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = viewModel.items[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completionHandler in
            self.showDeleteAlert(for: item)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = viewModel.items[indexPath.row]
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { _, _, completionHandler in
            let editVC = EditFoodItemViewController(
                item: item,
                onSave: { newCalories in
                    self.viewModel.updateItem(item, newCalories: newCalories)
                }
            )
            let nav = UINavigationController(rootViewController: editVC)
            self.present(nav, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemOrange
        editAction.image = UIImage(systemName: "pencil")
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
}
