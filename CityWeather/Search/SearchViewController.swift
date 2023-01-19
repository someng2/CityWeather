//
//  SearchViewController.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import UIKit
import RxSwift
import SnapKit

class SearchViewController: UIViewController {
    var searchController: UISearchController!
    var collectionView: UICollectionView!
    
    let searchVM = SearchViewModel()
    var mainVM: MainViewModel!
    let bag = DisposeBag()
    
    typealias Item = CityData
    enum Section: Int {
        case main
    }
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    let backgroundColor: UIColor = UIColor(named: "Green") ?? .white

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        setupCollectionView()
        subscribe()
        embedSearchControl()
        searchVM.getCityData(filter: "")
        self.view.backgroundColor = backgroundColor
    }

    private func subscribe() {
        searchVM.cityList
            .subscribe { cityList in
//                print("---> cityList = \(cityList)")
                if let data = cityList {
                    self.applySnapshot(items: data, section: .main)
                }
            }.disposed(by: bag)
    }
    
    private func embedSearchControl() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "도시/국가명 검색"
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
        self.navigationItem.preferredSearchBarPlacement = .inline
        self.navigationItem.searchController = searchController
        self.navigationController?.navigationBar.barTintColor = backgroundColor
    }
    
    private func setupCollectionView() {
        collectionView = WeeklyCollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        collectionView.backgroundColor = backgroundColor
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            let cell = self.configureCell(for: section, item: item, collectionView: self.collectionView, indexPath: indexPath)
            return cell
        })
        
        collectionView.delegate = self
        collectionView.register(CityCell.classForCoder(), forCellWithReuseIdentifier: "CityCell")
    }
    
    private func applySnapshot(items: [Item], section: Section) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: section)
        dataSource.apply(snapshot)
    }
    
    private func configureCell(for section: Section, item: Item, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch section{
        case .main:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCell", for: indexPath) as! CityCell
             cell.configure(item)
            return cell
        }
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let spacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        section.interGroupSpacing = spacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        searchVM.getCityData(filter: keyword)
        self.dismiss(animated: true)    // dismiss search bar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchVM.getCityData(filter: "")
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) is CityCell  else { return }
            if let city = try? searchVM.cityList.value() {
                let selected = city[indexPath.item]
                mainVM.city.onNext(selected)
                self.dismiss(animated: true)    // dismiss search view controller
            }
        
    }
}
