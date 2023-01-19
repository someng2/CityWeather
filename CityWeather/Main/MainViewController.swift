//
//  MainViewController.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import UIKit
import SnapKit
import RxSwift

class MainViewController: UIViewController {
    var scrollView: UIScrollView!
    var contentView: UIView!
    var cityInfoView: UIView!
    var cityNameLabel: UILabel!
    var tmpLabel: UILabel!
    var descriptionLabel: UILabel!
    var minMaxTmpLabel: UILabel!
    var hourlyWeatherCV: UICollectionView!
    var weeklyWeatherCV: UICollectionView!
    var searchButton: UIButton!
    
    let viewModel = MainViewModel()
    let bag = DisposeBag()
    
    typealias Item = AnyHashable
    enum Section: Int {
        case hourly
        case weekly
    }
    var hourlyDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var weeklyDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupContentView()
        setupSearchButton()
        setupCityInfoView()
        setupHourlyWeatherCV()
        setupWeeklyWeatherCV()
        subscribe()
    }
    
    private func subscribe() {
        viewModel.city
            .subscribe { city in
                print("---> city: \(city)")
                self.viewModel.getWeatherData()
            }.disposed(by: bag)
        
        viewModel.weather
            .observe(on: MainScheduler.instance)
            .subscribe { weather in
                if let weatherData = weather {
//                    print("---> weahter: \(weatherData)")
                    self.showCityInfoData(weatherData)
                }
            }.disposed(by: bag)
        
        viewModel.weeklyWeather
            .observe(on: MainScheduler.instance)
            .subscribe { weatherList in
//                print("---> weeklyWeather: \(String(describing: weatherList))")
                if let items = weatherList {
                    self.applyWeeklySnapshot(items: items, section: .weekly)
                }
            }.disposed(by: bag)
        
        viewModel.hourlyWeather
            .observe(on: MainScheduler.instance)
            .subscribe { list in
//                print("---> hourlyWeather: \(String(describing: list))")
                if let items = list {
                    self.applyHourlySnapshot(items: items, section: .hourly)
                }
            }.disposed(by: bag)
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(named: "BackgroundColor")
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1000)
        }
    }
    
    private func setupSearchButton() {
        searchButton = UIButton(frame: CGRect(x: 100, y: 100, width: self.view.bounds.width-40, height: 35))
        searchButton.backgroundColor = .white.withAlphaComponent(0.4)
        searchButton.layer.cornerRadius = 10
        searchButton.contentHorizontalAlignment = .left
        searchButton.setTitle("   Search", for: .normal)
        searchButton.setTitleColor(.gray, for: .normal)
        let searchIcon = UIImage(systemName: "magnifyingglass")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        searchButton.setImage(searchIcon, for: .normal)
        searchButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        searchButton.addTarget(self, action: #selector(searchBtnTapped), for: .touchUpInside)
        
        contentView.addSubview(searchButton)
        
        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(35)
        }
    }
    
    @objc func searchBtnTapped(sender: UIButton!) {
        let searchVC = SearchViewController()
        searchVC.mainVM = viewModel
        let navVC = UINavigationController(rootViewController: searchVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
    }
    
    private func setupCityInfoView() {
        cityInfoView = UIView()
        contentView.addSubview(cityInfoView)
        cityInfoView.snp.makeConstraints { make in
            make.top.equalTo(searchButton.snp.bottom).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(280)
        }
        cityNameLabel = UILabel()
        cityNameLabel.textColor = .white
        cityNameLabel.font = .systemFont(ofSize: 36)
        cityInfoView.addSubview(cityNameLabel)
        
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        tmpLabel = UILabel()
        tmpLabel.textColor = .white
        tmpLabel.font = .systemFont(ofSize: 80)
        cityInfoView.addSubview(tmpLabel)
        
        tmpLabel.snp.makeConstraints { make in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 30)
        cityInfoView.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(tmpLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        minMaxTmpLabel = UILabel()
        minMaxTmpLabel.textColor = .white
        minMaxTmpLabel.font = .systemFont(ofSize: 22)
        cityInfoView.addSubview(minMaxTmpLabel)
        
        minMaxTmpLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    private func showCityInfoData(_ item: WeatherData) {
        cityNameLabel.text = item.city.name
        
        let currentWeather = item.list[0]
        let tmp = Int(round(currentWeather.main.temp))
        let minTemp = Int(round(currentWeather.main.temp_min))
        let maxTemp = Int(round(currentWeather.main.temp_max))
        let description = currentWeather.weather[0].description
        
        tmpLabel.text = "\(tmp)°"
        descriptionLabel.text = description
        minMaxTmpLabel.text = "최고: \(maxTemp)°  |  최저: \(minTemp)°"
    }
    
    private func setupHourlyWeatherCV() {
        let layout = hourlyWeatherLayout()
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        hourlyWeatherCV = HourlyCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        hourlyWeatherCV.backgroundColor = UIColor(named: "CellBackgroundColor")
        hourlyWeatherCV.layer.cornerRadius = 15
        hourlyWeatherCV.showsHorizontalScrollIndicator = false
        contentView.addSubview(hourlyWeatherCV)
        
        hourlyWeatherCV.snp.makeConstraints { make in
            make.top.equalTo(cityInfoView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(150)
        }
        
        hourlyDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: hourlyWeatherCV, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil}
            let cell = self.configureCell(for: section, item: item, collectionView: self.hourlyWeatherCV, indexPath: indexPath)
            return cell
        })
        
        hourlyWeatherCV.register(HourlyWeatherCell.classForCoder(), forCellWithReuseIdentifier: "HourlyWeatherCell")
    }
    
    private func setupWeeklyWeatherCV() {
        weeklyWeatherCV = WeeklyCollectionView(frame: CGRect.zero, collectionViewLayout: weeklyWeatherLayout())
        weeklyWeatherCV.backgroundColor = UIColor(named: "CellBackgroundColor")
        weeklyWeatherCV.layer.cornerRadius = 15
        contentView.addSubview(weeklyWeatherCV)
        
        weeklyWeatherCV.snp.makeConstraints { make in
            make.top.equalTo(hourlyWeatherCV.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(270)
        }
        weeklyDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: weeklyWeatherCV, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil}
            let cell = self.configureCell(for: section, item: item, collectionView: self.weeklyWeatherCV, indexPath: indexPath)
            return cell
        })
        
        weeklyWeatherCV.register(WeeklyWeatherCell.classForCoder(), forCellWithReuseIdentifier: "WeeklyWeatherCell")
    }
    
    private func configureCell(for section: Section, item: Item, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch section{
        case .weekly:
            if let weeklyWeather = item as? WeeklyWeather {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeklyWeatherCell", for: indexPath) as! WeeklyWeatherCell
                cell.configure(weeklyWeather)
                return cell
            } else {
                return nil
            }
        case .hourly:
            if let hourlyWeather = item as? HourlyWeather {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
                cell.configure(hourlyWeather)
                return cell
            } else {
                return nil
            }
        }
    }
    
    private func applyHourlySnapshot(items: [Item], section: Section) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.hourly, .weekly])
        snapshot.appendItems(items, toSection: section)
        hourlyDataSource.apply(snapshot)
    }
    
    private func applyWeeklySnapshot(items: [Item], section: Section) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.hourly, .weekly])
        snapshot.appendItems(items, toSection: section)
        weeklyDataSource.apply(snapshot)
    }
    
    private func hourlyWeatherLayout() -> UICollectionViewCompositionalLayout {
        let spacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
        section.interGroupSpacing = spacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func weeklyWeatherLayout() -> UICollectionViewCompositionalLayout {
        let spacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
        section.interGroupSpacing = spacing
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
