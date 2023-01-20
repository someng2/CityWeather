//
//  MainViewController.swift
//  CityWeather
//
//  Created by 백소망 on 2023/01/18.
//

import UIKit
import SnapKit
import RxSwift
import MapKit

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
    var etcWeatherCV: UICollectionView!
    var searchButton: UIButton!
    var mapCellView: UIView!
    var mapView: MKMapView!
    
    let viewModel = MainViewModel()
    let bag = DisposeBag()
    
    typealias Item = AnyHashable
    enum Section: Int {
        case hourly
        case weekly
        case etc
    }
    var hourlyDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var weeklyDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var etcDataSource: UICollectionViewDiffableDataSource<Section, Item>!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupContentView()
        setupSearchButton()
        setupCityInfoView()
        setupHourlyWeatherCV()
        setupWeeklyWeatherCV()
        setupMapView()
        setupEtcWeatherCV()
        subscribe()
    }
    
    private func subscribe() {
        viewModel.city
            .subscribe { city in
//                print("---> city: \(city)")
                self.viewModel.getWeatherData()
                self.configureMapLocation(city)
            }.disposed(by: bag)
        
        viewModel.weather
            .subscribe { weather in
                if let weatherData = weather {
                    self.showCityInfoData(weatherData)
                    self.viewModel.parseWeather(weatherData)
                    self.viewModel.parseEtcWeather(weatherData)
                }
            }.disposed(by: bag)
        
        viewModel.weeklyWeather
            .observe(on: MainScheduler.instance)
            .subscribe { weatherList in
                if let items = weatherList {
                    self.applyWeeklySnapshot(items: items, section: .weekly)
                }
            }.disposed(by: bag)
        
        viewModel.hourlyWeather
            .observe(on: MainScheduler.instance)
            .subscribe { list in
                if let items = list {
                    self.applyHourlySnapshot(items: items, section: .hourly)
                }
            }.disposed(by: bag)
        
        viewModel.etcWeather
            .observe(on: MainScheduler.instance)
            .subscribe { weatherList in
                if let items = weatherList {
                    self.applyEtcSnapshot(items: items, section: .etc)
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
            make.height.equalTo(1580)
        }
    }
    
    private func setupSearchButton() {
        searchButton = UIButton(frame: CGRect(x: 100, y: 100, width: self.view.bounds.width-40, height: 35))
        searchButton.backgroundColor = .white.withAlphaComponent(0.4)
        searchButton.layer.cornerRadius = 10
        searchButton.contentHorizontalAlignment = .left
        searchButton.setTitle("   도시/국가명 검색", for: .normal)
        searchButton.setTitleColor(.gray, for: .normal)
        let searchIcon = UIImage(systemName: "magnifyingglass")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        searchButton.setImage(searchIcon, for: .normal)
        searchButton.configuration = UIButton.Configuration.plain()
        searchButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        searchButton.addTarget(self, action: #selector(searchBtnTapped), for: .touchUpInside)
        
        contentView.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
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
            make.top.equalTo(searchButton.snp.bottom).offset(35)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(275)
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
        tmpLabel.font = .systemFont(ofSize: 82)
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
            make.top.equalTo(tmpLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        minMaxTmpLabel = UILabel()
        minMaxTmpLabel.textColor = .white
        minMaxTmpLabel.font = .systemFont(ofSize: 21)
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
            make.top.equalTo(cityInfoView.snp.bottom)
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
            make.top.equalTo(hourlyWeatherCV.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(280)
        }
        weeklyDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: weeklyWeatherCV, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil}
            let cell = self.configureCell(for: section, item: item, collectionView: self.weeklyWeatherCV, indexPath: indexPath)
            return cell
        })
        
        weeklyWeatherCV.register(WeeklyWeatherCell.classForCoder(), forCellWithReuseIdentifier: "WeeklyWeatherCell")
    }
    
    private func setupMapView() {
        mapCellView = UIView()
        mapCellView.backgroundColor = UIColor(named: "CellBackgroundColor")
        mapCellView.layer.cornerRadius = 15
        contentView.addSubview(mapCellView)
        mapCellView.snp.makeConstraints { make in
            make.top.equalTo(weeklyWeatherCV.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(330)
        }
        
        mapView = MKMapView()
        mapView.overrideUserInterfaceStyle = .light
        mapView.isZoomEnabled = true
        mapCellView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    private func setupEtcWeatherCV() {
        etcWeatherCV = HourlyCollectionView(frame: CGRect.zero, collectionViewLayout: etcWeatherLayout())
        etcWeatherCV.backgroundColor = UIColor(named: "BackgroundColor")
        contentView.addSubview(etcWeatherCV)
        etcWeatherCV.snp.makeConstraints { make in
            make.top.equalTo(mapCellView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(390)
        }
        
        etcDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: etcWeatherCV, cellProvider: { collectionView, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return nil}
            let cell = self.configureCell(for: section, item: item, collectionView: self.etcWeatherCV, indexPath: indexPath)
            cell?.contentView.backgroundColor = UIColor(named: "CellBackgroundColor")
            cell?.contentView.layer.cornerRadius = 15
            return cell
        })
        
        etcWeatherCV.register(EtcWeatherCell.classForCoder(), forCellWithReuseIdentifier: "EtcWeatherCell")
    }
    
    private func configureMapLocation(_ city: CityData) {
        mapView.removeAnnotations(mapView.annotations)
        let location = CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon)
        let pin = MKPointAnnotation()
        pin.coordinate = location
        pin.title = "현위치"
        mapView.addAnnotation(pin)
        mapView.setCenter(location, animated: true)
    }
    
    private func configureCell(for section: Section, item: Item, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch section{
        case .weekly:
            if let weeklyWeather = item as? WeeklyWeather {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeklyWeatherCell", for: indexPath) as! WeeklyWeatherCell
                cell.configure(weeklyWeather)
                cell.layer.addBorder(index: indexPath[1], edge: .top, color: .white.withAlphaComponent(0.3), thickness: 1)
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
        case .etc:
            if let etcWeather = item as? EtcWeather {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EtcWeatherCell", for: indexPath) as! EtcWeatherCell
                cell.configure(etcWeather)
                return cell
            }
            return nil
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
    
    private func applyEtcSnapshot(items: [Item], section: Section) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.hourly, .weekly, .etc])
        snapshot.appendItems(items, toSection: section)
        etcDataSource.apply(snapshot)
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func etcWeatherLayout() -> UICollectionViewCompositionalLayout {
        let spacing: CGFloat = 10
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        return UICollectionViewCompositionalLayout(section: section)
    }
}
