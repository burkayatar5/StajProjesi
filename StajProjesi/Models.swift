//
//  Models.swift
//  StajProjesi

import Foundation

//First API call model for GlobalMetrics
struct APIResponse: Codable {
    let data: globalMetricsCryptoData
}

struct globalMetricsCryptoData: Codable {
    let btc_dominance: Double
    let eth_dominance: Double
    let quote: [String: Quote]
}

struct Quote: Codable {
    let total_market_cap: Double
    let total_volume_24h: Double
}

//Second API call model for getting CryptoCurrency Information

struct APICryptoResponse: Codable {
    let data: [listingLatestData]
}

struct listingLatestData: Codable {
    let id: Int
    let name: String
    let symbol: String
    let slug: String
    let cmc_rank: Int
    let quote: [String: QuoteCrypto]
}

struct QuoteCrypto: Codable {
    let price: Double
    let volume_24h: Double
    let percent_change_24h: Double?
}

extension QuoteCrypto {
    var percentChangeString: String? {
        guard let percent = self.percent_change_24h else {
            return nil
        }
        return String(percent)
    }
    var priceUsdString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencySymbol = "$"
        numberFormatter.maximumFractionDigits = 4
        numberFormatter.numberStyle = .currencyAccounting
        guard let formatted = numberFormatter.string(from: NSNumber(value: self.price)) else {
            return "0"
        }
        return formatted
    }
}

extension globalMetricsCryptoData {
    var btcDominance: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.groupingSize = 2
        guard let formated = numberFormatter.string(from: NSNumber(value: self.btc_dominance)) else {
            return "0"
        }
        return formated
    }
    var ethDominance: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.groupingSize = 2
        guard let formated = numberFormatter.string(from: NSNumber(value: self.eth_dominance)) else {
            return "0"
        }
        return formated
    }
}

extension Quote {
    var marketCapUsd: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencySymbol = "$"
        numberFormatter.groupingSize = 3
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = .currencyAccounting
        guard let formated = numberFormatter.string(from: NSNumber(value: self.total_market_cap)) else {
            return "0"
        }
        return formated
    }
    var volume24hUsd: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencySymbol = "$"
        numberFormatter.groupingSize = 3
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = .currencyAccounting
        guard let formated = numberFormatter.string(from: NSNumber(value: self.total_volume_24h)) else {
            return "0"
        }
        return formated
    }
}
