//
//  PurchaseViewController.swift
//  Streamini
//
//  Created by Vasiliy Evreinov on 24.06.16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseViewController: BaseTableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var productIDs: Array<String?> = []
    
    var productsArray: Array<SKProduct?> = []
    
    var selectedProductIndex: Int!
    
    var transactionInProgress = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = NSLocalizedString("credits", comment: "")
        
        SKPaymentQueue.default().add(self)
        
        productIDs.append("credits.100")
        productIDs.append("credits.500")
        productIDs.append("credits.1000")
        productIDs.append("credits.5000")
        productIDs.append("credits.10000")
        
        requestProductInfo()
        
        let tblView =  UIView(frame: CGRect.zero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.isHidden = true
        //tableView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs) as! Set<String>
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
            }
            
            tableView.reloadData()
        }
        else {
            print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellProduct", for: indexPath)
        let product = productsArray[indexPath.row]
        
        cell.textLabel?.text = product?.localizedTitle
        cell.detailTextLabel?.text = product?.localizedPrice()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProductIndex = indexPath.row
        showActions()
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func showActions() {
        if transactionInProgress {
            return
        }
        
        let payment = SKPayment(product: self.productsArray[self.selectedProductIndex] as! SKProduct)
        SKPaymentQueue.default().add(payment)
        self.transactionInProgress = true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                didBuy()
                
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func paymentSuccess()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func paymentFailure(_ error: NSError)
    {
        handleError(error)
    }
    
    func didBuy()
    {
        let receiptURL = Bundle.main.appStoreReceiptURL! //;
        let receipt: Data = try! Data(contentsOf: receiptURL)
        let receiptData: NSString = receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) as NSString
        StreamConnector().payment(receiptData as String, success: paymentSuccess, failure: paymentFailure)
    }
    
    @IBAction func cancelTouched(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
