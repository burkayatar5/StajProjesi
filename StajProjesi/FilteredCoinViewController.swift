//
//  FilteredCoinViewController.swift
//  StajProjesi

import UIKit

class FilteredCoinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private var cryptoListingsData: APICryptoResponse?
    private var filteredCoins = [listingLatestData]()
    private var coinImageUrl =  "https://s2.coinmarketcap.com/static/img/coins/64x64/"
    
    @IBOutlet var cryptoTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchBar.placeholder = "New Search"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        
       return searchController
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        cryptoTableView.dataSource = self
        cryptoTableView.delegate = self
        searchBar.delegate = self
        fetchCryptoListingsData()
    }
    
    private func fetchCryptoListingsData() {
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let cryptoData):
                self?.cryptoListingsData = cryptoData
                DispatchQueue.main.async {
                    self?.cryptoTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK- TableView Config
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchBar.text?.count == 0){
            return cryptoListingsData?.data.count ?? 0
        }else{
            return filteredCoins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = cryptoTableView.dequeueReusableCell(
            withIdentifier: "cryptoCell",
            for: indexPath
        ) as? customCoinTableViewCell else {
            fatalError()
        }
        
        let coin: listingLatestData?
        if(searchBar.text?.count == 0) {
            coin = cryptoListingsData?.data[indexPath.row]
        }else{
            coin = filteredCoins[indexPath.row]
        }
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
    
    //MARK: SearchBar Config
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.filteredCoins = []
            filterCoins(serchText: searchText)
        }
    
    func filterCoins(serchText: String?) {
            guard let search = serchText else {
                self.filteredCoins = self.cryptoListingsData!.data
                self.cryptoTableView.reloadData()
                return
            }

            if(search.isEmpty)  {
                self.filteredCoins = self.cryptoListingsData!.data
            } else {
                self.cryptoListingsData?.data.forEach({ coin in
                    if(coin.name.lowercased().contains(search.lowercased())
                        || coin.symbol.lowercased().contains(search.lowercased())){
                        self.filteredCoins.append(coin)
                    }
                })
            }
        self.cryptoTableView.reloadData()
    }
}

