//
//  DailyTotalView.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//
import UIKit
import SnapKit

final class DailyTotalView: UIView {
    private let titleLabel = UILabel()
    private let totalLabel = UILabel()
    private let progressView = UIProgressView()
    private let caloriesBudgetLabel = UILabel()
    
    private let DAILY_BUDGET = 2500
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        clipsToBounds = true
        
        titleLabel.text = "Калории за день"
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .systemGray
        addSubview(titleLabel)
        
        totalLabel.text = "0"
        totalLabel.font = .systemFont(ofSize: 56, weight: .bold)
        totalLabel.textColor = .systemBlue
        addSubview(totalLabel)
        
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        addSubview(progressView)
        
        caloriesBudgetLabel.font = .systemFont(ofSize: 12, weight: .regular)
        caloriesBudgetLabel.textColor = .systemGray
        addSubview(caloriesBudgetLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().inset(16)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(totalLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(6)
        }
        
        caloriesBudgetLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(8)
            make.left.bottom.right.equalToSuperview().inset(16)
        }
    }
    
    func updateTotal(_ calories: Int) {
        let oldValue = Int(totalLabel.text ?? "0") ?? 0
        
        if oldValue != calories {
            animateNumberChange(from: oldValue, to: calories)
        }
        
        let progress = Float(calories) / Float(DAILY_BUDGET)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.progressView.setProgress(min(progress, 1.0), animated: true)
            }
        )
        
        let remaining = max(0, DAILY_BUDGET - calories)
        caloriesBudgetLabel.text = "Осталось: \(remaining) kcal"
        
        let newColor: UIColor = calories > DAILY_BUDGET ? .systemRed : .systemBlue
        UIView.animate(withDuration: 0.3) {
            self.totalLabel.textColor = newColor
            self.progressView.progressTintColor = newColor
        }
    }
    
    private func animateNumberChange(from: Int, to: Int) {
        let duration: TimeInterval = 0.5
        let steps = to - from
        let stepDuration = duration / Double(abs(steps))
        
        var current = from
        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            if steps > 0 {
                current += 1
                if current >= to {
                    current = to
                    timer.invalidate()
                }
            } else {
                current -= 1
                if current <= to {
                    current = to
                    timer.invalidate()
                }
            }
            
            self?.totalLabel.text = "\(current)"
        }
    }
}
