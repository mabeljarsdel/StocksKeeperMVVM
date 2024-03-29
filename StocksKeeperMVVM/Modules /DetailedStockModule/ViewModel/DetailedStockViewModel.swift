//
//  MainViewModel.swift
//  StocksKeeperMVVM
//
//  Created by dev on 8.10.21.
//

import Foundation
import CoreData

protocol DetailedStockViewModelProtocol {
    var updateViewData: ((DetailedViewData)->())? {get set }
    func startFetch()
    func add<T: NSManagedObject>(type: T.Type) -> T?
    func save()
    func delete<T: NSManagedObject>(object: T)
    func fetch<T: NSManagedObject>(type: T.Type) -> [T]?
    func fetchBags() -> [StocksBag]?
    func fetchBag(name: String) -> StocksBag?
}

final class DetailedStockViewModel: DetailedStockViewModelProtocol {
    public var updateViewData: ((DetailedViewData) -> ())?
    private var networkService: NetworkServiceProtocol?
    private var coreDataManager: CoreDataManagerProtocol?
    
    private var symbol: String!
    
    init(_ networkService: NetworkServiceProtocol, _ coreDataManager: CoreDataManagerProtocol, _ symbol: String) {
        self.networkService = networkService
        self.coreDataManager = coreDataManager
        self.symbol = symbol
    }
    
    public func startFetch() {
        updateViewData?(.loading(DetailedViewData.CompanyOverview(name: nil, symbol: nil, description: nil, day: nil, dayBefore: nil, bookmarked: nil)))
        
        if (coreDataManager?.fetch(Stock.self)?.contains(where: { stock in //if database already contains element by this key, then get it from db
            stock.symbol == symbol
        })) == true {
            let fetchRequest = NSFetchRequest<Stock>(entityName: "Stock")
            fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
            DispatchQueue.global().async { [weak self] in
                do {
                    let dataBaseStock = try self?.coreDataManager?.viewContext.fetch(fetchRequest)
                    let stock = DetailedViewData.CompanyOverview(name: dataBaseStock?.first?.name,
                                                                 symbol: dataBaseStock?.first?.symbol,
                                                                 description: dataBaseStock?.first?.desctiption,
                                                                 day: dataBaseStock?.first?.day,
                                                                 dayBefore: dataBaseStock?.first?.dayBefore,
                                                                 bookmarked: dataBaseStock?.first?.bookmarked)
                    self?.updateViewData?(.success(stock))
                } catch {
                    dump(error)
                }
            }
        } else {
            networkService?.getCompanyOverview(bySymbol: symbol, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let company):
                    self.updateViewData?(.success(DetailedViewData.CompanyOverview(name: company?.name,
                                                                                   symbol: company?.symbol,
                                                                                   description: company?.description,
                                                                                   day: company?.day,
                                                                                   dayBefore: company?.dayBefore,
                                                                                   bookmarked: false)))
                case .failure(let error):
                    dump(error)
                }
            })
        }
    }
    
    func fetch<T>(type: T.Type) -> [T]? where T : NSManagedObject {
        return coreDataManager?.fetch(type)
    }
    
    func fetchBags() -> [StocksBag]? {
        let bags = coreDataManager?.fetch(StocksBag.self)
        return bags
    }
    
    func fetchBag(name: String) -> StocksBag? {
        let bag = coreDataManager?.fetch(StocksBag.self, name)
        return bag
    }
    
    func add<T: NSManagedObject>(type: T.Type) -> T? {
        return coreDataManager?.add(type)
    }
    
    func save() {
        coreDataManager?.save()
    }
    
    func delete<T: NSManagedObject>(object: T) {
        coreDataManager?.delete(object: object)
    }
    
    func delete<T: NSManagedObject>(type: T.Type, symbol: String?) {
        coreDataManager?.delete(type, symbol: symbol)
    }
}
