//
//  SSTOrder.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/14/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kOrderId             = "orderId"
let kStatusCode          = "statusCode"
let kStatusValue         = "statusValue"
let kOrderUpdateDate     = "updateDate"
let kOrderCreateDate     = "createDate"
let kOrderItems          = "orderItemVos"
let kOrderTotal          = "orderTotal"
let kOrderApprovedTotal  = "approvedTotal"
let kOrderFinalTotal     = "orderFinalTotal"
let kOrderTax            = "orderTax"
let kOrderDiscountTotal  = "discountTotal"
let kOrderShippingAddr   = "orderShippingAddress"
let kOrderBillingAddr    = "orderBillingAddress"
let kOrderStatusDesc     = "userOrderStatusDesc"
let kOrderShippingFinalTotal  = "shippingFinalTotal"
let kOrderPaymentMethodStatus  = "selectPaymentMethodStatus"
let kOrderStatus         = "userOrderStatus"
let kOrderPaymentStatus  = "paymentStatus"
let kOrderItemsTotal     = "orderItemsTotal"
let kOrderApprovalStatus = "orderApprovalStatus"
let kOrderShippingStatus = "shippingStatus"
let kOrderItemsQty       = "itemsQty"
let kOrderPayment        = "orderPayment"
let kOrderNote           = "orderNote"
let kOrderCanApplyDiscount = "canApplyMoreDiscount"
let kOrderDiscountTip      = "applyOrderDiscountOrCateDiscountTips"
let kOrderPaidTotal        = "paidTotal"
let kOrderLastMergableOrderShippingId   = "orderShipping"
let kOrderPaymentOrderPrices            = "paymentMethodOrderPrices"
let kOrderWalletPaid                    = "useWalletAmount"
let kOrderUncleardTotal                 = "unclearedTotal"
let kOrderShippingCompanyName           = "orderShippingCompanyName"
let kOrderMergeTargetOrderId            = "mergeShippingTargetOrderId"
let kOrderMergeShippingTargeShippingId  = "mergeShippingTargetShippingId"
let kOrderMergeShippingTargePaymentId   = "mergeShippingTargetPaymentId"
let kOrderBalanceDueFlag   = "balanceDueFlage"
let kOrderMandatoryFlag    = "mandatory"

// Search Keyword
let kSearchOrderId            = "orderId"
let kSearchOrderUpdateDate    = "createDate"
let kSearchOrderPaymentMethodStatus = "SELECTPAYMENTMETHODSTATUS"
let kSearchShippingStatus     = "SHIPPINGSTATUS"
let kSearchApprovalStatus     = "ORDERAPPROVALSTATUS"
let kSearchPaymentStatus      = "PAYMENTSTATUS"
let kSearchUserOrderStatus    = "USERORDERSTATUS"
let kSearchOrderItemsQty      = "ITEMSQTY"
let kSearchOrderTotal         = "ORDERTOTAL"
let kSearchOrderTax           = "ORDERTAX"
let kSearchOrderDiscount      = "DISCOUNTTOTAL"
let kSearchOrderItemsTotal    = "ORDERITEMSTOTAL"
let kSearchOrderShippingTotal = "shippingFinalTotal"
let kSearchOrderShippingCompany = "SHIPPINGCOMPANYNAME"
let kSearchOrderStatusDesc    = "USERORDERSTATUSDESC"
let kSearchOrderPayment       = "orderPayment"
let KSearchOrderNote          = "orderNote"
let kSearchOrderFinalTotal    = "orderFinalTotal"
let kFreeTaxApplyStatus       = "freeTaxEndDateAndApplyStatus"
let kOrderBilingId            = "billingId"

let kDiscountRequestStatus    = "discountRequestStatus"
let kOrderNativeShippingTotal = "nativeShippingTotal"
//let kShippingInfoVos          = "shippingInfoVos"

let kOrderHidByCustomer       = "hidByCustomer"
let kOrderWarehouseVos        = "orderWarehouseVos"
let kOrderShippingTotal       = "orderShippingTotal"

//支付方式及选择状态，当状态为UNSELECTED时，显示“To pay”按钮
enum SSTPaymentMethod: Int {
    case unselected = 50
    case credit_CARD_SELECTED = 51
    case paypal_SELECTED = 52
    case western_UNION_SELECtED = 53
    case banktransfer_SELECTED = 54
    case cod_SELECTED = 55
    case local_PICKUP_BY_CASH_SELECTED = 56
    case wallet_SELECTED  = 57
    case check_SELECTED = 58
}

//订单确认状态，当状态为FINISHED或CANCEL_CHECKED或REJECTING_CHECKED时，显示“Delete”按钮。
enum SSTOrderApprovalStatus: Int {
    case created = 1
    case unapproved = 2
    case approved = 3
    case canceled = 4
    case finished = 5
    case rejected = 6
    case cancel_CHECKED_OR_REJECTING_CHECKED = 7
    
}

//支付状态，当状态为UNPAID、PARTIAL_PAID时，显示“To pay”按钮。
enum SSTPaymentStatus: Int {
    case unpaid = 70
    case partial_PAID = 72
    case paid = 73
    case refuned = 75
    case over_PAID = 76
}

//配送状态当状态为SHIPPED时，显示“Confirm receipt”按钮
enum SSTShippingStatus: Int {
    case unpicked = 80
    case partial_PICKED = 81
    case partial_SHIPPED = 82
    case partial_DELIVERY = 83
    case picked = 84
    case shipped = 85
    case delivery = 86
}

class SSTOrder: BaseModel {
    
    var id: String!
    var itemsTotal = 0.0            // order items total , maybe  = order total - discount
    var approvedTotal: Double?      // approved total which input by admin, if not nil, then show it instead of itemsTotal
    var orderTotal = 0.0            // 代表原产品总价（不含税和运费）
    var orderFinalTotal = 0.0       // 商品应付价格（最终价格），计算方式 total = order items total + tax + shippng fee
    var paidTotal = 0.0             // 订单中已经支付的费用，所以订单的最终价格应该是 orderFinalTotal - paidTotal

    var shippingFee = 0.0
    var nativeShippingTotal = 0.0    // Origin shipping cost without any discount
    var shippingAddress: SSTShippingAddress?
    var billingAddress: SSTShippingAddress?
    var tax = 0.0
    var discount = 0.0

    var dateCreated: Date?
    var paymentMethod = 0   //支付方式及选择状态,对应SSTPaymentMethod枚举
    var approvalStatus = 0   //订单确认状态，对应SSTOrderApprovalStatus枚举
    var paymentStatus = 0   //支付状态，对应SSTPaymentStatus枚举
    var shippingStatus = 0   //配送状态，对应SSTShippingStatus枚举
    var orderStatus = 0  //订单状态，显示"To be payed"
    var orderPayment = 0  //订单当前的支付方式 0没选择，2，paypal，5，COD
    var orderStatusDesc: String?
    var qty = 0
    var note = String()
    
    var items = [SSTOrderItem]()
    var shippingCompany: SSTShippingCompany?
    var shippingCostInfo: SSTShippingCostInfo?
    var taxInfo: SSTFreeTaxInfo?
    var shippingCompanyName: String?
    var billingId: String?
    var canApplyMoreDiscount = false
    var discountTips: String?
    var mergableOrderShippingId: String?    //上一个可以合并的订单的mergeShippingTargetShippingId
    var orderShippingId: String?            //上一个可以合并的订单的order shipping
    var mergeShippingTargetOrderId: String? //从订单列表重算订单后， 上一个可以合并订单的order id
    var mergeShippingTargetPaymentId: Int?  // the payment id which need to merged to
    var paymentMethodOrderPrices = [SSTPaymentMethodOrderPrice]() //订单对应所有的支付方式应付费的信息
    var walletPaid = 0.0     //代表钱包支付金额
    var unclearedTotal = 0.0 // date:03.29 代表还需要支付的金额
    var paymentType: SSTOrderPaymentType?
    var balaneDueFlage: Bool? //True 表示该订单是欠款订单
    var mandatory: Bool? //此处在订单的MANDATORY=1，并且支付状态是未支付或部分支付时，也像AmountDueFlag=1一样处理。
    
    var discountRequestStatus: Int?
    var shippingInfoVos = [SSTShippingInfoVos]()    // tracking number
    var warehouses = [SSTOrderWarehouse]()        // 订单中的多仓库
    var shippingTotal = 0.0                         // shipping total when multiple warehouses
    
    var hidByCustomer: Int?
    
    var amountUnpaid: Double {
        get {
            return orderFinalTotal - paidTotal
        }
    }
    
    var subTotal: Double {
        get {
            if approvedTotal != nil {
                return validDouble(approvedTotal)
            }
            return itemsTotal
        }
    }
    
    var isPayable: Bool {
        get {
            if  ( approvalStatus == SSTOrderApprovalStatus.created.rawValue || approvalStatus == SSTOrderApprovalStatus.unapproved.rawValue || approvalStatus == SSTOrderApprovalStatus.approved.rawValue )
                &&
                ( paymentStatus == SSTPaymentStatus.unpaid.rawValue || paymentStatus == SSTPaymentStatus.partial_PAID.rawValue ) {
                return true
            }
            return false
        }
    }
    
    var isArchivable: Bool {
        get {
            if approvalStatus == SSTOrderApprovalStatus.finished.rawValue || approvalStatus == SSTOrderApprovalStatus.cancel_CHECKED_OR_REJECTING_CHECKED.rawValue || approvalStatus == SSTOrderApprovalStatus.canceled.rawValue {
                return true
            }
            return false
        }
    }
    
    var isCancelable: Bool {
        get {
            if approvalStatus != SSTOrderApprovalStatus.canceled.rawValue && shippingStatus == SSTShippingStatus.unpicked.rawValue {
                return true
            }
            return false
        }
    }
    
    var priceOfCOD: Double {
        get {
            return getPriceByPaymetTypeId(paymentTypeId: validString(SSTOrderPaymentType.COD.rawValue))
        }
    }
    
    var priceOfCurrentPaymentType: Double {
        get {
            return getPriceByPaymetTypeId(paymentTypeId: validString(orderPayment))
        }
    }
    
    var isBalanceOrder: Bool {
        get {
            if balaneDueFlage == true || ( mandatory == true && (paymentStatus == SSTPaymentStatus.unpaid.rawValue || paymentStatus == SSTPaymentStatus.partial_PAID.rawValue)) {
                return true
            }
            return false
        }
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if map.JSON[kOrderId] == nil {
//            printDebug("Error: Order Id is empty. JSON: \(map.JSON)")
//            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        id                              <- map[kSearchOrderId]
        if id == nil {
            id                          <- (map[kOrderId],transformIntToString)
        }
        
        qty                             <- map[kOrderItemsQty]
        itemsTotal                      <- map[kOrderItemsTotal]
        approvedTotal                   <- map[kOrderApprovedTotal]
        orderTotal                      <- map[kOrderTotal]
        shippingFee                     <- map[kOrderShippingFinalTotal]
        shippingTotal                   <- map[kOrderShippingTotal]
        nativeShippingTotal             <- map[kOrderNativeShippingTotal]
        orderFinalTotal                 <- map[kOrderFinalTotal]
        paidTotal                       <- map[kOrderPaidTotal]
        note                            <- map[kOrderNote]
    
        shippingAddress                 <- map[kOrderShippingAddr]
        billingAddress                  <- map[kOrderBillingAddr]
        taxInfo                         <- map[kFreeTaxApplyStatus]
        
        paymentMethodOrderPrices        <- map[kOrderPaymentOrderPrices]
        shippingInfoVos                 <- map[kShippingInfoVos]
        
        tax                             <- map[kOrderTax]
        discount                        <- map[kOrderDiscountTotal]
        dateCreated                     <- (map[kOrderCreateDate],transformStringToDate)
        paymentMethod                   <- map[kOrderPaymentMethodStatus]
        approvalStatus                  <- map[kOrderApprovalStatus]
        paymentStatus                   <- map[kOrderPaymentStatus]
        shippingStatus                  <- map[kOrderShippingStatus]
        orderStatus                     <- map[kOrderStatus]
        orderStatusDesc                 <- map[kOrderStatusDesc]
        orderPayment                    <- map[kOrderPayment]
        canApplyMoreDiscount            <- map[kOrderCanApplyDiscount]
        discountTips                    <- map[kOrderDiscountTip]
        orderShippingId                 <- (map[kOrderLastMergableOrderShippingId],transformIntToString)
        shippingCompanyName             <- map[kOrderShippingCompanyName]
        mergableOrderShippingId         <- (map[kOrderMergeShippingTargeShippingId],transformIntToString)
        mergeShippingTargetPaymentId    <- map[kOrderMergeShippingTargePaymentId]
        mergeShippingTargetOrderId      <- (map[kOrderMergeTargetOrderId],transformIntToString)
        balaneDueFlage                  <- map[kOrderBalanceDueFlag]
        mandatory                       <- map[kOrderMandatoryFlag]

        items                           <- map[kOrderItems]
        
        discountRequestStatus           <- map[kDiscountRequestStatus]
        hidByCustomer                   <- map[kOrderHidByCustomer]
        warehouses                      <- map[kOrderWarehouseVos]
    }
    
    func getPriceByPaymetTypeId(paymentTypeId: String) -> Double {
//        for paymentPrice in paymentMethodOrderPrices {
//            if paymentTypeId == paymentPrice.paymentId {
//                return paymentPrice.orderFinalTotal
//            }
//        }
        return self.orderFinalTotal
    }
    
    func getOrderPrice(paymentTypeId: String) -> SSTPaymentMethodOrderPrice? {
        for paymentPrice in paymentMethodOrderPrices {
            if paymentTypeId == paymentPrice.paymentId {
                return paymentPrice
            }
        }
        return nil
    }
    
    static func createOrder(
        itemIds: [String],
        billingAddressId: String,
        shippingAddressId:String,
        shippingCompanyId: String,
        orderPaymentId: String,
        orderNote: String,
        discountFlag: Bool,
        mergeOrderId: String,
        mergeShippingTargetShippingId: String,
        mergeShippingRemarks: String,
        useWalletAmount: Double,
        customerShippingAcc: String,
        warehouses: [SSTOrderWarehouse],
        callback: @escaping RequestCallBack) {
        
        guard itemIds.count > 0 else {
            return
        }
        biz.createOrder(itemIds,
                        billingAddressId: billingAddressId,
                        shippingAddressId: shippingAddressId,
                        shippingCompanyId: shippingCompanyId,
                        orderPaymentId: orderPaymentId,
                        orderNote: orderNote,
                        discountRequestFlag: discountFlag,
                        mergeShippingTargetorderId: mergeOrderId,
                        mergeShippingTargetShippingId: mergeShippingTargetShippingId,
                        mergeShippingRemarks: mergeShippingRemarks,
                        useWalletAmount: useWalletAmount,
                        customerShippingAcc: customerShippingAcc,
                        warehouses: warehouses) { (data, error) in
            if error == nil {
                let dic = validDictionary(data)
                if let order = SSTOrder(JSON: validDictionary(dic)) {
                    order.billingId = validString(dic[kOrderBilingId])
                    order.walletPaid = validDouble(dic[kOrderWalletPaid])
                    order.unclearedTotal = validDouble(dic[kOrderUncleardTotal])
                    
                    callback(order, nil)
                } else {
                    printDebug("SERVER API DATA ERROR, IT CANNOT BUILD OBJECT WITH DATA: \(data.debugDescription)")
                    callback(nil, error)
                }
            } else {
                callback(data, error)
            }
        }
    }
    
    static func fetchOrder(_ orderId: String, callback: @escaping RequestCallBack) {
        guard orderId.isNotEmpty else {
            callback(nil, kNoOrderFetchedTip)
            return
        }
        biz.getOrderDetail(orderId) { (data, error) in
            if nil == error {
                if let order = SSTOrder(JSON: validDictionary(data)) {
                    callback(order, nil)
                } else {
                    callback(nil, kNoOrderFetchedTip)
                }
            } else {
                callback(data, error)
            }
        }
    }

    static func precalculateOrderPrice(
                           itemIds: [String],
                           orderPaymentId: String,
                           mergeShippingTargeOrderId: String,
                           mergeShippingId: String,
                           mergeShippingRemarks: String,
                           discountRequestFlag: Bool,
                          billingAddressId: String,
                         shippingAddressId: String,
                         shippingCompanyId: String,
                         shippingAddressCountryCode: String,
                         shippingAddressStateCode: String,
                         customerShippingAcc: String,
                         warehouses: [SSTOrderWarehouse],
                                  callback: @escaping RequestCallBack) {
        biz.getOrderPriceAndTax(itemIds,
                                orderPaymentId: orderPaymentId,
                                mergeShippingTargeOrderId: mergeShippingTargeOrderId,
                                mergeShippingId: mergeShippingId,
                                mergeShippingRemarks: mergeShippingRemarks,
                                discountRequestFlag: discountRequestFlag,
                                billingAddressId: billingAddressId,
                                shippingAddressId: shippingAddressId,
                                shippingCompanyId: shippingCompanyId,
                                shippingAddressCountryCode: shippingAddressCountryCode,
                                shippingAddressStateCode: shippingAddressStateCode,
                                customerShippingAcc: customerShippingAcc,
                                warehouses: warehouses) { (data, error) in
            if nil == error {
                if let order = SSTOrder(JSON: validDictionary(data)) {
                    callback(order, nil)
                } else {
                    callback(nil, kErrorTip)
                }
            } else {
                callback(data, error)
            }
            
        }
    }
    
    //重新计算订单的价格
    static func recalculateOrderPrice(_ orderId: String, callback: @escaping RequestCallBack) {
        biz.recalculateOrder(orderId) { (data, error) in
            if nil == error {
                if let order = SSTOrder(JSON: validDictionary(data)) {
                    callback(order, nil)
                } else {
                    callback(nil, kErrorTip)
                }
            } else {
                callback(data, error)
            }
        }
    }
    
    //改变订单支付方式
    static func changePaymentMethod(orderId: String, paymentId: String, callback: @escaping RequestCallBack) {
        biz.changePaymentMethod(orderId, orderPaymentId: paymentId) { (data, error) in
            if nil == error {
                let dic = validDictionary(data)
                if let order = SSTOrder(JSON: validDictionary(dic["order"])) {
                    order.billingId = validString(dic[kOrderBilingId])
                    callback(order, nil)
                } else {
                    callback(nil, kErrorTip)
                }
            } else {
                callback(data, error)
            }
        }
    }
    
    static func preCanceOrder(_ orderId: String, callback: RequestCallBack?) {
        biz.preCancelOrder(orderId) { data, error in
            if error == nil {
                callback?(data, nil)
            } else {
                callback?(nil, error)
            }
        }
    }
    
    static func cancelOrder(_ orderId: String, callback: RequestCallBack?) {
        biz.cancelOrder(orderId) { data, error in
            if error == nil, let order = SSTOrder(JSON: validDictionary(data)) {
                callback?(order, nil)
            } else {
                callback?(nil, error)
            }
        }
    }
    
    //隐藏订单
    static func hideOrder(_ orderId: String, callback: RequestCallBack?) {
        biz.hideOrder(orderId) { (data, error) in
            callback?(data, error)
        }
    }
    
    //重新支付订单
    static func payOrder(orderId: String,
                         paymentId: Int,
                         useWalletAmount: Double,
                         orderFinalTotal: Double,
                         payAnywayForDiscountReq: Int = 0,
                         callback: @escaping RequestCallBack) {
        biz.payOrder(orderId: orderId, orderPaymentId: paymentId, useWalletAmount: useWalletAmount, orderFinalTotal: orderFinalTotal, payAnywayForDiscountReq: payAnywayForDiscountReq) {(data, error) in
            if nil == error {
                let dic = validDictionary(data)
                if let order = SSTOrder(JSON: validDictionary(dic["order"])) {
                    order.billingId = validString(dic[kOrderBilingId])
                    order.walletPaid = validDouble(dic[kOrderWalletPaid])
                    callback(order, nil)
                } else {
                    callback(nil, kErrorTip)
                }
            } else {
                callback(data, error)
            }
        }
    }
    
    // paypal支付成功后，告知后台支付过程中使用了钱包中的金额数
    static func payOrderWithWallet(orderId: String, useWalletAmount: Double, callback: @escaping RequestCallBack) {
        biz.payOrderWithWallet(orderId: orderId, useWalletAmount: useWalletAmount) { (data, error) in
            callback(data, error)
        }
    }
    
    // 
    static func payBalanceOrdersWithWallet(billingId: String, useWalletAmount: Double, callback: @escaping RequestCallBack) {
        biz.payBalanceOrdersWithWallet(billingId: billingId, useWalletAmount: useWalletAmount) { (data, error) in
            callback(data, error)
        }
    }
    
    //根据订单id列表，获取billing id
    static func createBilling(orderIds:[String], callback: @escaping RequestCallBack) {
        biz.createBilling(orderIds) { (data, error) in
            if nil == error {
                callback(data, error)
            }
        }
    }
    
    //paypal支付后，告知后台当前合并了的欠款订单使用了钱包中的金额数
    static func payBillingWithWallet(billingId: String, useWalletAmount: Double, callback: @escaping RequestCallBack) {
        biz.payBillWithWallet(billingId: billingId, walletAmount: useWalletAmount) { (data, error) in
            callback(data, error)
        }
    }
    
    //获取订单的物流详情（包括地址和物流方式）
    static func getOrderShippingDetails(orderId: String, callback:@escaping RequestCallBack) {
        biz.getOrderShippingDetail(orderId: orderId) { (data, error) in
            callback(data, error)
        }
    }

    //order shipping detail 页面，重新选择地址后，更新物流信息
    static func getLastMergableTargetOrderByOrderId(orderShippingAddressId: String, orderId: String, callback: @escaping RequestCallBack) {
        biz.getlastMergableTargetOrderByOrderId(shippingAddressId: orderShippingAddressId, orderId: orderId) { (data, error) in
            callback(data, error)
        }
    }
    
    //点击continue 页，更新订单的详细信息
    static func updateOrderShppingDetailInfo(orderId: String,
                                             orderShipping: String,
                                             shippingAddressId: String,
                                             billingAddressId: String,
                                             customerShippingAcc: String,
                                             mergeableOrderId: String,
                                             warehouses: [SSTOrderWarehouse],
                                             callback: @escaping RequestCallBack) {
        biz.updateOrderShippingDetailInfo(orderId: orderId,
                                          orderShipping: orderShipping,
                                          billingId: billingAddressId,
                                          shippingId: shippingAddressId,
                                          customerShippingAcc: customerShippingAcc,
                                          mergeShippingTargetOrderId: mergeableOrderId, warehouses: warehouses) { (data, error) in
            if nil == error {
                if let order = SSTOrder(JSON: validDictionary(data)) {
                    callback(order, nil)
                } else {
                    callback(nil, kErrorTip)
                }
            } else {
                callback(data, error)
            }
        }
    }
    
//    //order payment option 页，输入via account之后调用这个接口更新
//    static func getOrderByCustomerShippingAccount(orderId: String,
//                                                  customerShippingAcc: String,
//                                                  callback: @escaping RequestCallBack) {
//        biz.getOrderByShippingAccount(orderId: orderId, customerAcc: customerShippingAcc) { (data, error) in
//            if nil == error {
//                if let order = SSTOrder(JSON: validDictionary(data)) {
//                    callback(order, nil)
//                } else {
//                    printDebug("SERVER API DATA ERROR, IT CANNOT BUILD OBJECT WITH DATA: \(data.debugDescription)")
//                }
//            }else {
//                callback(data, error)
//            }
//        }
//    }
//    
//    //order payment option 页,点击pay 按钮之前调用这个接口告诉后台修改订单数据
//    static func updateOrderCustomerShippingAccount(orderId: String, customerShippingAcc: String, callback: @escaping RequestCallBack) {
//        biz.updateOrderShippingAccount(orderId: orderId, customerShippingAcc: customerShippingAcc) { (data, error) in
//            if nil == error {
//                if let order = SSTOrder(JSON: validDictionary(data)) {
//                    callback(order, nil)
//                } else {
//                    printDebug("SERVER API DATA ERROR, IT CANNOT BUILD OBJECT WITH DATA: \(data.debugDescription)")
//                }
//            }else {
//                callback(data, error)
//            }
//        }
//    }
    
    static func buyAgain(orderId: String, callback: @escaping RequestCallBack) {
        biz.buyOrderAgain(orderId: orderId) { (data, error) in
            callback(data, nil)
        }
    }
    
    static func clickedPayButton(payButton: UIButton?, orderId: String, afterCallbackBlock: ( () -> Void)? = nil ) {   // 重新计算订单价格（daily deals价格根据时间的变化而改变）
        SSTProgressHUD.show(view: payButton?.viewController()?.view)
        payButton?.isEnabled = false
        SSTOrder.recalculateOrderPrice(orderId) { (data, error) in
            SSTProgressHUD.dismiss(view: payButton?.viewController()?.view)
            payButton?.isEnabled = true
            afterCallbackBlock?()
            if error == nil {
                toPayVC(data: data, error: error)
            } else if validInt(data) == APICodeType.OrderItemOutOfStock.rawValue {
                let mAC = UIAlertController(title: "", message: validString(error), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                })
                mAC.addAction(okAction)
                payButton?.viewController()?.present(mAC, animated: true, completion: nil)
            } else if validInt(data) == APICodeType.MainOrderIsInProcess.rawValue {
                let mAC = UIAlertController(title: "", message: validString(error), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                    toShippingVC()
                })
                mAC.addAction(cancelAction)
                mAC.addAction(okAction)
                payButton?.viewController()?.present(mAC, animated: true, completion: nil)
            } else {
                SSTToastView.showError("\(validString(error))")
            }
        }
    }
    
    static func toPayVC(data: Any?, error: Any?) {
        if let tOrder = data as? SSTOrder {
            if let orderVC = getTopVC() as? SSTOrderVC {
                orderVC.orderClicked = tOrder
                orderVC.performSegue(withIdentifier: SSTOrderVC.SegueIdentifier.SegueToOrderPayVC.rawValue, sender: self)
            } else if let orderDetailVC = getTopVC() as? SSTOrderDetailVC {
                orderDetailVC.order = tOrder
                orderDetailVC.performSegue(withIdentifier: SSTOrderDetailVC.SegueIdentifier.SegueToOrderPayVC.rawValue, sender: nil)
            }
        }
    }
    
    static func toShippingVC() {
        if let orderVC = getTopVC() as? SSTOrderVC {
            orderVC.performSegue(withIdentifier: SSTOrderVC.SegueIdentifier.SegueToOrderShippingVC.rawValue, sender: self)
        } else if let orderDetailVC = getTopVC() as? SSTOrderDetailVC {
            orderDetailVC.performSegue(withIdentifier: SSTOrderDetailVC.SegueIdentifier.SegueToOrderShippingVC.rawValue, sender: self)
        }
    }
    
    static func clickedHideButton(hideButton: UIButton?, orderId: String, afterCallbackBlock: RequestCallBack? = nil ) {
        let iconActionSheet: UIAlertController = UIAlertController(title: nil, message: kOrderHidePayButtonText, preferredStyle: UIAlertControllerStyle.actionSheet)
        iconActionSheet.addAction(UIAlertAction(title: kOrderButtonTitleHide, style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            hideButton?.isEnabled = false
            SSTProgressHUD.show(view: hideButton?.viewController()?.view)
            SSTOrder.hideOrder(validString(orderId)) { data, error in
                SSTProgressHUD.dismiss(view: hideButton?.viewController()?.view)
                hideButton?.isEnabled = true
                afterCallbackBlock?(data, error)
                if nil == error {
                    SSTToastView.showSucceed("\(kOrderButtonTitleHide) order successfully!")
                } else {
                    SSTToastView.showError("\(kOrderButtonTitleHide) order failed!")
                }
            }
        }))
        
        iconActionSheet.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler:nil))
        getTopVC()?.present(iconActionSheet, animated: true, completion: nil)
    }
    
    func moveItemToAnotherOrderWarehouse(shippingAddressCountryCode: String, shippingAddressStateCode: String, callback: @escaping RequestCallBack) {
        biz.moveItemToAnotherOrderWarehouse(order: self, shippingAddressCountryCode: shippingAddressCountryCode, shippingAddressStateCode: shippingAddressStateCode) { (data, error) in
            callback(data, error)
        }
    }
}

