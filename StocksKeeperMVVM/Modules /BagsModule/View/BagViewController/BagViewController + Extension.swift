//
//  BagViewController + Extension.swift
//  StocksKeeperMVVM
//
//  Created by dev on 17.10.21.
//

import UIKit

extension BagViewController {
    func configureTabBar() {
        title = "Your Bags"
        view.backgroundColor = .white
        
        tabBarController?.tabBar.isHidden = false
        tabBarItem = UITabBarItem(title: "Your Bags",
                                  image: UIImage(systemName: "bag"),
                                  selectedImage: UIImage(systemName: "bag.fill"))
        tabBarController?.tabBar.tintColor = .black
        
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addBag(sender:)))
    }
    
    func configureBagCollectionView() {
        bagCollectionView.delegate = self
        bagCollectionView.dataSource = self
        bagCollectionView.register(BagCollectionViewCell.self, forCellWithReuseIdentifier: BagCollectionViewCell.identifier)
        
        view.addSubview(bagCollectionView)
        bagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bagCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bagCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bagCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bagCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupScreenForPopUp(check: Bool) {
        if check {
            let visualEffectsView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            
            tabBarController?.view.addSubview(visualEffectsView)
            visualEffectsView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                visualEffectsView.topAnchor.constraint(equalTo: view.topAnchor),
                visualEffectsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                visualEffectsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                visualEffectsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            
            UIView.animate(withDuration: 0.2, animations: {
                visualEffectsView.alpha = 0
                visualEffectsView.alpha = 0.7
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let subviews = self?.tabBarController?.view.subviews else { return }
                for view in subviews {
                    if view.isKind(of: UIVisualEffectView.self) {
                        self?.tabBarController?.view.willRemoveSubview(view)
                        view.removeFromSuperview()
                    }
                }
            })
        }
    }
    
    func setupPopUp() {
        let addBagView = AddBagView()
        addBagView.delegate = self
        addBagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTouchedWhenPopUpViewOnTop(sender:))))
        addBagView.isUserInteractionEnabled = true

        animate(in: true, sender: addBagView)
        addBagView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addBagView.topAnchor.constraint(equalTo: view.topAnchor),
            addBagView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addBagView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addBagView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func animate(in check: Bool, sender: UIView) {
        if check {
            tabBarController?.view.addSubview(sender)
            
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            sender.alpha = 0
            
            UIView.animate(withDuration: 0.2, animations: {
                sender.transform = CGAffineTransform(scaleX: 1, y: 1)
                sender.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.view.willRemoveSubview(sender)
                sender.removeFromSuperview()
            })
        }
    }
}
