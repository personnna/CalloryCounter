//
//  SceneDelegate.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
        var window: UIWindow?

        func scene(
            _ scene: UIScene,
            willConnectTo session: UISceneSession,
            options connectionOptions: UIScene.ConnectionOptions
        ) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            
            let window = UIWindow(windowScene: windowScene)
            
            let modelContext = DependencyContainer.setupContainer()
            let viewModel = CalorieTrackerViewModel(modelContext: modelContext)
            let viewController = CalorieTrackerViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: viewController)
            
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
