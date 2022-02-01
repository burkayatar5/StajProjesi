//
//  ViewController.swift
//  StajProjesi

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var globalMetricsData: APIResponse?
    private var cryptoListingsData = [APICryptoResponse?]()
    private var btcEthArray = [APICryptoResponse?]()
    
    public var coinImageArray = [String?]()
    private var coinImageUrl =  "https://s2.coinmarketcap.com/static/img/coins/64x64/"
    
    @IBOutlet var btcDominanceLabel: UILabel!
    @IBOutlet var ethDominanceLabel: UILabel!
    @IBOutlet var totalMarketCapLabel: UILabel!
    @IBOutlet var totalVolume24HLabel: UILabel!
    @IBOutlet var btcEthTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btcEthTableView.delegate = self
        btcEthTableView.dataSource = self
        //API CALLS
        fetchGlobalMetricsData()
        fetchCryptoListingsData()
        
        btcEthTableView.tableFooterView = UIView()
        btcEthTableView.isScrollEnabled = false
        
    }
    //to get dominance and etc.
    private func fetchGlobalMetricsData() {
        APICaller.shared.getGlobalMetricsData { [weak self] result in
            switch result {
            case .success(let data):
                self?.globalMetricsData = data
                DispatchQueue.main.async {
                    self?.setUpViewModels()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //to get crypto all crypto price and stuff.
    private func fetchCryptoListingsData() {
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let cryptoData):
                self?.cryptoListingsData.append(cryptoData)
                DispatchQueue.main.async {
                    self?.setUpViewModels()
                    self?.btcEthArray.insert(contentsOf: self!.cryptoListingsData, at: 0)
                    self?.btcEthArray.insert(contentsOf: self!.cryptoListingsData, at: 1)
                    self?.btcEthTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    private func setUpViewModels() {
        createUILabels()
        //table view if any needed adjusment needed programatically
    }
    
    private func createUILabels() {
        guard let btcDominance = globalMetricsData?.data.btcDominance else {
            return
        }
        guard let ethDominance = globalMetricsData?.data.ethDominance else {
            return
        }
        guard let totalMarketCap = globalMetricsData?.data.quote["USD"]?.marketCapUsd else {
            return
        }
        guard let totalVolume24H = globalMetricsData?.data.quote["USD"]?.volume24hUsd else {
            return
        }
        btcDominanceLabel.text = "BTC Dominance: \(btcDominance)"
        btcDominanceLabel.textAlignment = .left
        btcDominanceLabel.frame = CGRect(x: 10, y: 110, width: 400, height: 20)
        
        ethDominanceLabel.text = "ETH Dominance: \(ethDominance)"
        ethDominanceLabel.textAlignment = .left
        ethDominanceLabel.frame = CGRect(x: 10, y: 160, width: 400, height: 20)
        
        totalMarketCapLabel.text = "Total Market Cap: \(totalMarketCap)"
        totalMarketCapLabel.textAlignment = .left
        totalMarketCapLabel.frame = CGRect(x: 10, y: 210, width: 400, height: 20)
        
        totalVolume24HLabel.text = "Total Volume 24H: \(totalVolume24H)"
        totalVolume24HLabel.textAlignment = .left
        totalVolume24HLabel.frame = CGRect(x: 10, y: 260, width: 400, height: 20)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.btcEthArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = btcEthTableView.dequeueReusableCell(
                withIdentifier: "btcEthCell"
        ) as? customCoinTableViewCell else {
            fatalError()
        }
        //creating a shortcut to be used in btc and eth related information.
        let coin = btcEthArray[indexPath.row]?.data[indexPath.row]
        cell.coinName.text = coin?.name
        cell.coinSymbol.text = coin?.symbol
        cell.coinPrice.text = coin?.quote["USD"]?.priceUsdString
        if let doublePercent = coin?.quote["USD"]?.percent_change_24h {
            if doublePercent < 0 {
                cell.coinPercentChange24h.textColor = UIColor.red
                cell.coinPercentChange24h?.text = (coin?.quote["USD"]?.percentChangeString)! + "% ▼"
            } else {
                cell.coinPercentChange24h.textColor = UIColor.green
                cell.coinPercentChange24h?.text =
                    (coin?.quote["USD"]?.percentChangeString)! + "% ▲"
            }
        }
        //creating a shortcut to be used in coin images.
        if let imageId = coin?.id {
            let imageUrl = String(coinImageUrl + String(imageId) + ".png").trimmingCharacters(in: .whitespaces)
            if let urlImage = URL(string: imageUrl) {
                cell.coinImage?.downloadedFrom(url: urlImage, contentMode: .scaleAspectFit)
            }
        }
        
        return cell
    }

}
 
