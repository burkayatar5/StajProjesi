//
//  APICaller.swift
//  StajProjesi

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init(){}
    
    struct Constants {
        static let baseUrl = "https://pro-api.coinmarketcap.com/v1/"
        static let apiKeyHeader = "X-CMC_PRO_API_KEY"
        static let apiKey = "d63721a4-c2a3-480e-804d-cd499e45cb19"
        //for global metrics like dominance and market cap
        static let endPointGlobalMetrics = "global-metrics/quotes/latest"
        //for cryptocurrencies
        static let endPointCryptoCurrency = "cryptocurrency/listings/latest"
    }
    
    enum APIError: Error {
        case invalidURL
    }
    
    //To get our dominance and marketcap like data from api.
    public func getGlobalMetricsData(
        completion: @escaping (Result<APIResponse, Error>) -> Void
    ) {
        guard let url = URL(string: Constants.baseUrl + Constants.endPointGlobalMetrics + "?convert=USD") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        //To ensure we get the expected url string before moving onward.
        print("\n\n API URL: \(url.absoluteString) \n\n")
        
        var request = URLRequest(url: url)
        request.setValue(Constants.apiKey, forHTTPHeaderField: Constants.apiKeyHeader)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // Unwrapping with if let because it will not live outside of scope
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            do {
                //Decoding Json response according to our model.
                let response: APIResponse = try JSONDecoder().decode(APIResponse.self
                                                                     , from: data)
                //To ensure we get the expected api result before coding viewController
                print("\n\n API RESULT: \(response) \n\n")
                
                completion(.success(response))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    //to get btc and eth data from api to use in main screen
    public func getAllCryptoData(completion: @escaping (Result<APICryptoResponse, Error>) -> Void
    ) {
        //after this call you will get 1...200 cmc rank coins.
        guard let url = URL(string: Constants.baseUrl + Constants.endPointCryptoCurrency + "?limit=200") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        //To ensure we get the expected url string before moving onward.
        print("\n\n API URL: \(url.absoluteString) \n\n")
        
        var request = URLRequest(url: url)
        request.setValue(Constants.apiKey, forHTTPHeaderField: Constants.apiKeyHeader)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // Unwrapping with if let because it will not live outside of scope
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                return
            }
            
            do {
        //!!TO GET RAW JSON RESPONSE DIRECTLY TO CHECK IF THE GIVEN MODEL IS WRONG
//                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print("\n\n \(json) \n\n")
                
                //Decoding Json response according to our model.
                let response: APICryptoResponse = try JSONDecoder().decode(APICryptoResponse.self
                                                                     , from: data)
                //To ensure we get the expected api result before coding viewController
                print("\n\n API RESULT: \(response) \n\n")
                
                completion(.success(response))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
