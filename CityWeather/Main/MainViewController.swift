//
//  MainViewController.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/17.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    let viewModel = MainViewModel()
    
    private var collectionView: UICollectionView!
    typealias Item = AnyHashable
    enum Section: Int {
        case main
        case weather
    }
    
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        viewModel.getWeatherData()
        configureCollectionView()
        
        applySnapshot(items: [viewModel.city], section: .main)
    }
    
    private func bind() {
        
    }
    
    private func configureCollectionView() {
        collectionView = CustomCollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        datasource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil}
            let cell = self.configureCell(for: section, item: item, collectionView: collectionView, indexPath: indexPath)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main, .weather])
        snapshot.appendItems([], toSection: .main)
        snapshot.appendItems([] , toSection: .weather)
        datasource.apply(snapshot)
        
        collectionView.register(CityInfoCell.classForCoder(), forCellWithReuseIdentifier: "CityInfoCell")
    }
    
    private func configureCell(for section: Section, item: Item, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        print("item = \(item)")
        switch section{
        case .main:
            if let cityInfo = item as? City {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityInfoCell", for: indexPath) as! CityInfoCell
                cell.configure(cityInfo)
                return cell
            } else {
                return nil
            }
        case .weather:
            return nil
        }
    }
    
    private func applySnapshot(items: [Item], section: Section) {
        var snapshot = datasource.snapshot()
        snapshot.appendItems(items, toSection: section)
        datasource.apply(snapshot)
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let spacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 높이: 그룹마다 달라질 수 있기 때문에 estimated 로 설정(최소값: 60 으로)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 0, trailing: 16)
        section.interGroupSpacing = spacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

