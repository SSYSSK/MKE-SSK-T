//
//  SSTOrderVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/14.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import PullToRefreshKit


let kDelayAfterOrderPaid = 2.9

class SSTOrderVC: SSTBaseVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    /*
     unpaid = 0,PaymentStatus ->unpaid
     unshipped = 1,shippingStatus -> picked
     unreceived = 2,shippingStatus -> shipped
     allOrder = 3
     */
    var orderType = 3 //默认是all order（因为从pay result vc 过来的时候orderType应该是all order）
    
    var orderData = SSTOrderData()
    var sectionClicked: Int?
    var orderClicked: SSTOrder?
    
    fileprivate var status: String {
        get {
            switch orderType {
            case 0:
                return "unPaid"
            case 1:
                return "inProcess"
            case 2:
                return "inTransit"
            default:
                return "all"
            }
        }
    }
    
    fileprivate var searchKey: String {
        get {
            return validString(searchBar.text)
        }
    }
    
    fileprivate var scrollViewContentOffset: CGPoint?
    fileprivate var needRefreshViewAfterPaid = false
    fileprivate var needRefreshViewAfterArchived = false
    
    fileprivate var isCellButtonEnable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        switch orderType {
        case 0:
            self.title = "Unpaid"
        case 1:
            self.title = "In Process"
        case 2:
            self.title = "In Transit"
        case 3:
            self.title = "All Orders"
        default:
            break
        }
        
        setSearchBar(vw: searchBar)
        searchBar.delegate = self
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = myTableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.upPullLoadData()
        }
        _ = myTableView.setUpFooterRefresh { [weak self] in
            self?.downPullLoadData()
            }.SetUp { (footer) in
                setRefreshFooter(footer)
        }
        
        SSTProgressHUD.show(view: self.view)
        orderData.delegate = self
        self.upPullLoadData()
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight + 44, width: kScreenWidth, height: kScreenViewHeight - 44)
        emptyView.setData(imgName: kNoOrderImgName, msg: kNoOrderTip, buttonTitle: "Go Shopping", buttonVisible: true)
        emptyView.buttonClick = {
            self.tabBarController?.selectedIndex = 0
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
    }
    
    func setSearchBar(vw: UIView) {
        for subV in vw.subviews {
            if subV.isKind(of: UITextField.classForCoder()) {
                (subV as! UITextField).font = UIFont.systemFont(ofSize: 13)
                return
            } else {
                setSearchBar(vw: subV)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.needRefreshViewAfterPaid {
            self.needRefreshViewAfterPaid = false
            self.refreshViewAfterPaid2()
        }
        
        if self.needRefreshViewAfterArchived {
            self.needRefreshViewAfterArchived = false
            TaskUtil.delayExecuting(0.8) {
                self.refreshViewAfterArchived2()
            }
        }
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.orderData.orders.removeAll()
        myTableView.reloadData()
        SSTProgressHUD.show(view: self.view)
        self.upPullLoadData()
    }
    
    func refreshViewAfterPaid() {
        self.needRefreshViewAfterPaid = true
    }
    
    func refreshViewAfterPaid2() {
        let tmpOrderId = validString(orderClicked?.id).trim()
        if tmpOrderId.isNotEmpty {
            SSTProgressHUD.show(view: self.view)
            TaskUtil.delayExecuting(kDelayAfterOrderPaid, block: {
                SSTOrder.fetchOrder(tmpOrderId) { (data, error) in
                    if let tmpOrder = data as? SSTOrder, let tmpSection = self.sectionClicked, tmpSection < self.orderData.orders.count {
                        self.orderData.orders[tmpSection] = tmpOrder
                        self.myTableView.reloadSections([tmpSection], with: .none)
                        
                        let tOrderData = SSTOrderData()
                        tOrderData.searchOrders(status: self.status, key: "orderId:\(tmpOrder.id)", start: self.orderData.orders.count, rows: kSearchOrderPageSize) { data, error in
                            SSTProgressHUD.dismiss(view: self.view)
                            if error == nil {
                                if tOrderData.orders.count == 0 {
                                    self.orderData.orders.remove(at: tmpSection)
                                    self.myTableView.reloadData()
                                }
                            }
                        }
                    } else {
                        SSTProgressHUD.dismiss(view: self.view)
                    }
                }
            })
        }
    }
    
    func refreshViewAfterArchived() {
        self.needRefreshViewAfterArchived = true
    }
    
    func refreshViewAfterArchived2() {
        self.orderData.orders.remove(at: validInt(self.sectionClicked))
        self.myTableView.deleteSections([validInt(self.sectionClicked)], with: .automatic)
    }
    
    override func clickedBackBarButton() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: -- XWSwiftRefresh
    
    func upPullLoadData() {
        orderData.searchOrders(status: status, key: searchKey, start: 0, rows: kSearchOrderPageSize)
        scrollViewContentOffset = CGPoint.zero
    }
    
    func downPullLoadData(){
        orderData.searchOrders(status: status, key: searchKey, start: orderData.orders.count, rows: kSearchOrderPageSize)
        scrollViewContentOffset = myTableView.contentOffset
    }
}

// MARK: -- UITableViewDelegate, UITableViewDataSource

extension SSTOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderData.orders.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSTOrderListCell") as! SSTOrderListCell
        
        guard orderData.orders.count >= indexPath.section else {
            return cell
        }
        
        cell.order = orderData.orders[indexPath.section]
        
        cell.clickToPayBlock = { [weak self] order in
            if self?.isCellButtonEnable == false {
                return
            }
            self?.sectionClicked = indexPath.section
            self?.orderClicked = cell.order
            SSTOrder.clickedPayButton(payButton: cell.toPayBtn, orderId: validString(order.id), afterCallbackBlock: {
                self?.isCellButtonEnable = true
            })
        }
        
        cell.clickHiddenBlock = { [weak self] order in
            if self?.isCellButtonEnable == false {
                return
            }
            SSTOrder.clickedHideButton(hideButton: cell.toPayBtn, orderId: validString(order.id), afterCallbackBlock: { [weak self] data, error in
                self?.isCellButtonEnable = true
                if nil == error {
                    self?.sectionClicked = indexPath.section
                    self?.refreshViewAfterArchived2()
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tmpOrder = orderData.orders.validObjectAtIndex(indexPath.section) as? SSTOrder {
            self.orderClicked = tmpOrder
            self.sectionClicked = indexPath.section
            self.performSegueWithIdentifier(.SegueToOrderDetail, sender: self)
        } else {
            //
        }
    }

}

//MARK:-- searachBar delegate
extension SSTOrderVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
        for view in searchBar.subviews {
            for subview in view.subviews {
                if let navClass = NSClassFromString("UINavigationButton") {
                    if subview.isKind(of: navClass) {
                        let tButton = subview as! UIButton
                        tButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        orderData.searchOrders(status: status, key: searchKey, start: 0, rows: kSearchOrderPageSize)
        exitSearchBarEditing()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            orderData.searchOrders(status: status, key: searchKey, start: 0, rows: kSearchOrderPageSize)
        }
        exitSearchBarEditing()
    }
    
    func exitSearchBarEditing() {
        if searchBar != nil {
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}

//MARK:-- Segue delegate
extension SSTOrderVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToOrderDetail     = "ToOrderDetailVC"
        case SegueToOrderPayVC      = "toOrderPaymentVC"
        case SegueToOrderShippingVC = "ToOrderShippingVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        exitSearchBarEditing()
        switch segueIdentifierForSegue(segue) {
        case .SegueToOrderDetail:
            let destVC = segue.destination as! SSTOrderDetailVC
            destVC.orderId = validString(self.orderClicked?.id)
        case .SegueToOrderPayVC:
            let destVC = segue.destination as! SSTOrderPaymentVC
            destVC.order = self.orderClicked
        case .SegueToOrderShippingVC:
            let destVC = segue.destination as! SSTOrderShippingDetailVC
            destVC.orderId = validString(self.orderClicked?.id)
            destVC.order = self.orderClicked    // the order will be updated by calling api
        }
    }
}

// MARK: -- refreshUI delegate
extension SSTOrderVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        
        if (data as? SSTOrderData) == nil {
            myTableView.endHeaderRefreshing(.failure, delay: 0.5)
        } else {
            myTableView.endHeaderRefreshing(.success, delay: 0.5)
            if orderData.orders.count < orderData.numFound {
                myTableView.endFooterRefreshing()
            } else {
                myTableView.endFooterRefreshingWithNoMoreData()
            }
            
            if orderData.orders.count <= 0 && validString(searchBar.text).isEmpty {
                myTableView.isHidden = true
            }
            
            if orderData.orders.count <= 0 {
                emptyView.isHidden = false
                if validString(searchBar.text).isEmpty {
                    emptyView.setData(imgName: kNoOrderImgName, msg: kNoOrderTip, buttonTitle: "Go Shopping", buttonVisible: true)
                } else {
                    emptyView.setData(imgName: kNoOrderImgName, msg: kNoDataTip, buttonTitle: "Go Shopping", buttonVisible: false)
                }
            } else {
                emptyView.isHidden = true
            }
            
            self.myTableView.reloadData()
            
            if scrollViewContentOffset != nil {
                if validDouble(scrollViewContentOffset?.y).equalZero() {
                    myTableView.scrollsToTop = true
                } else {
                    myTableView.setContentOffset(scrollViewContentOffset!, animated: false)
                }
           }
        }
    }
}
