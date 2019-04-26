//
//  SSTWarehouseItemsVC.swift
//  sst-ios
//
//  Created by Amy on 2017/12/28.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kPopViewWarehouseItemHeight: CGFloat = 44

class SSTWarehouseItemsVC: SSTBaseVC, UITableViewDataSource, UITableViewDelegate {

    var order: SSTOrder?
    var warehourse: SSTOrderWarehouse?
    var usableWarehouses: [SSTWarehouse]?
    
    @IBOutlet weak var tableView: UITableView!
    
    var popView: UIView!
    var maskView: UIView!
    
    var orderItemClicked: SSTOrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Shipping From \(validString(warehourse?.warehouseName))"
        
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        maskView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        let tap = UITapGestureRecognizer(target: self, action: #selector(SSTWarehouseItemsVC.clickedMaskView(_:)))
        maskView.addGestureRecognizer(tap)
    }
    
    @objc func timerAlarm() {
        for itm in validArray(warehourse?.orderItems) as! [SSTOrderItem] {
            itm.minusOneToPromoCountdown()
        }
        for cell in tableView.visibleCells {
            for subV in cell.subviews {
                if subV.isKind(of: SSTWarehouseItemView.classForCoder()) {
                    (subV as? SSTWarehouseItemView)?.refreshCountdown()
                }
            }
        }
    }
    
    @objc func clickedMaskView(_ sender: UITapGestureRecognizer) {
        maskView?.removeFromSuperview()
        popView?.removeFromSuperview()
    }
    
    // MARK: -- UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validInt(warehourse?.orderItems.count)

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kSearchResultViewListHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let itemV = SSTWarehouseItemView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kSearchResultViewListHeight))
        if let itm = warehourse?.orderItems.validObjectAtIndex(indexPath.row) as? SSTOrderItem {
            itemV.orderItem = itm
            itemV.setViewFrame(layout: .list)
            itemV.totalLabel.text = " Quantity: \(itm.qty)      Total: \(itm.sumFinalPrice.formatC())"
            itemV.updateWarehouseButton.addTarget(self, action: #selector(SSTWarehouseItemsVC.clickedUpdateWarehouseButton), for: UIControlEvents.touchUpInside)
            itemV.deleteButton.addTarget(self, action: #selector(SSTWarehouseItemsVC.clickedDeleteButton), for: UIControlEvents.touchUpInside)
            itemV.usableWarehouses = self.getItemAvailableWarehouses(item: itm)
        }
        cell.addSubview(itemV)
        return cell
    }
    
    @objc func clickedDeleteButton(sender: UIButton) {
        if let oItmClicked = (sender.superview as? SSTWarehouseItemView)?.orderItem {
            self.moveOrderItemBetweenWarehouses(orderItem: oItmClicked, toWarehouseId: "")
        }
    }
    
    func getItemAvailableWarehouses(item: SSTOrderItem) -> [SSTWarehouse] {
        var tWarehouses = [SSTWarehouse]()
        for wh in validArray(self.usableWarehouses) as! [SSTWarehouse] {
            if wh.isItemInStock(itemId: item.id, itemQty: item.qty) {
                tWarehouses.append(wh)
            }
        }
        return tWarehouses
    }
    
    func getPopViewHeight(_ warehouseCnt: Int) -> CGFloat {
        return validCGFloat(warehouseCnt) * kPopViewWarehouseItemHeight + kPopViewButtonHeight + kTriangleHeight
    }
    
    @objc func clickedUpdateWarehouseButton(sender: UIButton) {
        
        self.orderItemClicked = (sender.superview as? SSTWarehouseItemView)?.orderItem
        if let oItmClicked = self.orderItemClicked {
            
            let avaliableWarehouses = self.getItemAvailableWarehouses(item: oItmClicked)
            popView?.removeFromSuperview()
            maskView?.removeFromSuperview()
            
            var hLine: UIView!
            var cancelButton: UIButton!
            var vLine: UIView!
            var okButton: UIButton!
            var whViewsTopSpace: CGFloat = kTriangleHeight + 1
            
            let vcTableview: UITableView? = (getTopVC() as? SSTWarehouseItemsVC)?.tableView
          
            if sender.absoluteY - validCGFloat(vcTableview?.contentOffset.y) + getPopViewHeight(avaliableWarehouses.count) > kScreenHeight - kScreenTabbarHeight {
                let viewY: CGFloat = sender.absoluteY - getPopViewHeight(avaliableWarehouses.count) - kScreenNavigationHeight
                popView = SSTSquareWithInverseTriangleView(frame: CGRect(x: sender.absoluteX + 10, y: viewY, width: kPopViewWidth, height: getPopViewHeight(avaliableWarehouses.count)))
                let buttonY: CGFloat = getPopViewHeight(avaliableWarehouses.count) - kPopViewButtonHeight - kTriangleHeight
                hLine = UIView(frame: CGRect(x: 0, y: buttonY, width: popView.width, height: 1))
                cancelButton = UIButton(frame: CGRect(x: 0, y: buttonY, width: popView.width / 2, height: kPopViewButtonHeight))
                vLine = UIView(frame: CGRect(x: popView.width / 2, y: buttonY, width: 1, height: kPopViewButtonHeight))
                okButton = UIButton(frame: CGRect(x: popView.width / 2, y: buttonY, width: popView.width / 2, height: kPopViewButtonHeight))
                whViewsTopSpace = 1
            } else {
                let viewY: CGFloat = sender.absoluteY - 35
                popView = SSTSquareWithTriangleView(frame: CGRect(x: sender.absoluteX + 10, y: viewY, width: kPopViewWidth, height: getPopViewHeight(avaliableWarehouses.count)))
                let buttonY: CGFloat = getPopViewHeight(avaliableWarehouses.count) - kPopViewButtonHeight
                hLine = UIView(frame: CGRect(x: 0, y: buttonY, width: popView.width, height: 1))
                cancelButton = UIButton(frame: CGRect(x: 0, y: buttonY, width: popView.width / 2, height: kPopViewButtonHeight))
                vLine = UIView(frame: CGRect(x: popView.width / 2, y: buttonY, width: 1, height: kPopViewButtonHeight))
                okButton = UIButton(frame: CGRect(x: popView.width / 2, y: buttonY, width: popView.width / 2, height: kPopViewButtonHeight))
            }
            
            for ind in 0 ..< validInt(avaliableWarehouses.count) {
                let whView = loadNib("\(SSTWarehouseForSelectingView.classForCoder())") as! SSTWarehouseForSelectingView
                whView.frame = CGRect(x: 1, y: whViewsTopSpace + kPopViewWarehouseItemHeight * validCGFloat(ind), width: kPopViewWidth - 2, height: kPopViewWarehouseItemHeight)
                whView.cornerRadius = 5
                whView.warehouse = avaliableWarehouses.validObjectAtIndex(ind) as? SSTWarehouse
                whView.selectedStatus = validString(whView.warehouse?.warehouseId) == validString(self.warehourse?.warehouseId)
                if let itm = (sender.superview as? SSTWarehouseItemView)?.orderItem {
                    var destOrderWarehouseItemQty = 0
                    for owh in validArray(order?.warehouses) as! [SSTOrderWarehouse] {
                        if owh.warehouseId == whView.warehouse?.warehouseId {
                            destOrderWarehouseItemQty = owh.getItemQty(itemId: itm.id)
                        }
                    }
                    if whView.selectedStatus == true || validInt(whView.warehouse?.productInventory[itm.id]) - destOrderWarehouseItemQty >= itm.qty {
                        whView.alpha = 1
                        whView.stockStatusLabel.isHidden = true
                    } else {
                        whView.alpha = 0.5
                        whView.stockStatusLabel.isHidden = false
                    }
                }
                whView.updateWarehouse = { warehouseId in
                    for subV in self.popView.subviews {
                        if subV.isKind(of: SSTWarehouseForSelectingView.classForCoder()) {
                            let tWhView = (subV as! SSTWarehouseForSelectingView)
                            tWhView.selectedStatus = validString(tWhView.warehouse?.warehouseId) == validString(warehouseId)
                        }
                    }
                }
                popView.addSubview(whView)
            }
            
            hLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            popView.addSubview(hLine)
            
            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(UIColor.darkGray, for: .normal)
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            cancelButton.addTarget(self, action: #selector(SSTWarehouseItemsVC.clickedCancelButton), for: .touchUpInside)
            popView.addSubview(cancelButton)
            
            vLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            popView.addSubview(vLine)
            
            okButton.setTitle("OK", for: .normal)
            okButton.setTitleColor(UIColor.darkGray, for: .normal)
            okButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            okButton.addTarget(self, action: #selector(SSTWarehouseItemsVC.clickedOKButton), for: .touchUpInside)
            popView.addSubview(okButton)
            
            let contentHeight = validCGFloat(vcTableview?.contentSize.height)
            maskView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: contentHeight > kScreenHeight ? contentHeight : kScreenHeight)

            vcTableview?.addSubview(maskView)
            vcTableview?.addSubview(popView)
        }
    }
    
    @objc func clickedCancelButton(sender: UIButton) {
        sender.superview?.removeFromSuperview()
        maskView.removeFromSuperview()
    }
    
    @objc func clickedOKButton(sender: UIButton) {
        for subV in self.popView.subviews {
            if subV.isKind(of: SSTWarehouseForSelectingView.classForCoder()) {
                let tWhView = (subV as! SSTWarehouseForSelectingView)
                if tWhView.selectedStatus == true && validString(tWhView.warehouse?.warehouseId) != validString(self.warehourse?.warehouseId) {
                    if let oItmClicked = self.orderItemClicked {
                        self.moveOrderItemBetweenWarehouses(orderItem: oItmClicked, toWarehouseId: validString(tWhView.warehouse?.warehouseId))
                    }
                }
            }
        }
        sender.superview?.removeFromSuperview()
        maskView.removeFromSuperview()
    }

    func moveOrderItemBetweenWarehouses(orderItem: SSTOrderItem, toWarehouseId: String) {     // need to update order's warehouses and call API to update
        if let prevVC = self.navigationController?.childViewControllers.validObjectAtLoopIndex(-2) as? SSTBaseOrderShippingVC {
            prevVC.moveItemToAnotherOrderWarehouse(
                item: orderItem,
                fromWarehouseId: validString(self.warehourse?.warehouseId),
                toWarehouseId: toWarehouseId
            ) { data, error in
                if error == nil {
                    if toWarehouseId.isEmpty, let cartItm = biz.cart.findItem(orderItem.id) {
                        biz.cart.updateItem(cartItm, addingQty: -orderItem.qty) { data, error in
                            SSTProgressHUD.dismiss(view:getTopVC()?.view)
                        }
                    } else {
                        SSTProgressHUD.dismiss(view:getTopVC()?.view)
                    }
                    self.maskView?.removeFromSuperview()
                    self.tableView.reloadData()
                    if validInt(self.warehourse?.orderItems.count) == 0 {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else {
                    SSTToastView.showError(validString(error))
                }
            }
        }
    }
}
