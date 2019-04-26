//
//  BizRequestCenter.swift
//  sst-ios
//
//  Created by Liang Zhang on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit

open class BizRequestCenter {
    
    let ntwkAccess = NetworkAccess()
    
    var user: SSTUser!
    var cart: SSTCart!

    var dealMessage = SSTDealMessage()
    var favoriteData = SSTFavoriteData()
    var guideData = SSTGuideData()
    var hotProductData = SSTHotProductData()
    var stockRemindIds = [String: Bool]()
    
    var oldUserId = ""
    
    init() {
        ntwkAccess.listen()
        
        if let data = FileOP.unarchive(kUserFileName) {
            if let tmpUser = SSTUser(JSON: validDictionary(data)) {
                self.user = tmpUser
            }
        } else {
            self.user = SSTUser()
        }
        NotificationCenter.default.addObserver(self.user, selector:#selector(SSTUser.timerAlarm), name: kEveryOneSecondNotification, object: nil)
    
        self.cart = SSTCart()
        if let dict = FileOP.unarchive(kCartFileName) as? Dictionary<String,AnyObject> {
            self.cart.update(dict)
        }
    }
    
    class var sharedInstance : BizRequestCenter {
        return biz
    }

    open func sendPaypalConfirmation(_ confirmation: NSDictionary, callback: @escaping RequestCallBack) {
        ntwkAccess.request(.post, url: kPayURLString + "api/rest/paymentwithpaypal/confirmation.json", parameters: confirmation as? [String : AnyObject]) { (resp,err) -> Void in
            callback(resp, err)
        }
    }
    
    open func getPaypalClientId(countryState: String, callback: @escaping RequestCallBack) {
        ntwkAccess.request(.post, url: kPayURLString + "api/rest/paymentwithpaypal/getClientId.json", parameters: [kPaypalCountryState : countryState]) { (resp,err) -> Void in
            callback(resp, err)
        }
    }
    
    open func createPayment(paras: Dictionary<String, Any>, callback: @escaping RequestCallBack) {
        ntwkAccess.request(.post, url: kPayURLString + "api/rest/paymentwithpaypal/createPayment.json", parameters: paras) { (data, error) -> Void in
            callback(data, error)
        }
    }
    
    /**
     1.获取首页信息
     
     - parameter callback: 返回结果
     */
    open func getHomePage(_ callback:@escaping RequestCallBack){
        let urlStr = "getHomePage.json"
        ntwkAccess.request(.get, url:kBaseURLString + urlStr) { (response, error) -> Void in
            callback(response, error)
        }
    }
    
    /**
     2.获取购物车
     - parameter callback: 返回结果
     */
    open func getCartItems(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "cart/getItems.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     3.添加商品到购物车
     
     - parameter parameter: post 请求参数
     productId：产品ID
     qty:产品数量
     userID:用户ID
     - parameter callback: 返回结果
     */
    func addCartItems(_ items: [SSTItem], qtys: [Int], callback: @escaping RequestCallBack) {
        let urlStr = "cart/addItems.json"
        
        var dataArr = [Dictionary<String,Any>]()
        for index in 0 ..< items.count {
            let dict = [
                "productId":items[index].id,
                "qty":validString(qtys[index]),
                ]
            dataArr.append(dict)
        }
        let tPara = [
            "data": dataArr,
            ]
        ntwkAccess.request(.post, url:kBaseURLString +  urlStr, parameters: validDictionary(tPara) ) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     4.更新购物车中的商品信息
     - parameter parameter: post请求参数
     productId：产品ID
     qty:产品数量
     userID:用户ID
     - parameter callback: 返回结果
     */
    func updateCartItems(_ items: [SSTCartItem], callback: @escaping RequestCallBack) {
        let urlStr = "cart/updateItems.json"
        
        var dataArr = [Dictionary<String,Any>]()
        for item in items {
            let dict = [
                "productId":item.id,
                "qty":validString(item.qty + item.addingQty),
                ]
            dataArr.append(dict)
        }
        let tPara = ["data": dataArr,
                     ]
        ntwkAccess.request(.post, url:kBaseURLString +  urlStr, parameters: validDictionary(tPara)) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     5.删除购物车里的某件商品信息
     
     - parameter parameter: post请求参数
     productId：产品ID
     userID:用户ID
     - parameter callback: 返回结果
     */
    open func removeCartItems(_ itemIds: Array<String>, callback: @escaping RequestCallBack) {
        let urlStr = "cart/deleteItems.json"
        
        var tPara =  Dictionary<String,AnyObject>()
        var data = [AnyObject]()
        for Id in itemIds {
            let dict = ["productId": Id]
            data.append(dict as AnyObject)
        }
        tPara["data"] = data as AnyObject?
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters:tPara) { (response, err) -> Void in
            callback(response, err)
        }
        
    }
    
    /**
     6.创建订单(保存订单)
     
     - parameter items:        产品
     - parameter billingAddressId: billing Id
     - parameter shippingAddressId: shipping Id
     - parameter shippingCompanyId:  物流公司Id
     - parameter discountRequestFlag: 是否申请更过折扣，1表示申请了更多折扣
     - parameter orderPaymentId:      支付方式的I的
     - parameter orderNote:      订单备注
     - parameter mergeShippingTargetorderId: 合并订单的I的
     - parameter mergeShippingRemarks:  合并订单的备注
     - parameter callback:     返回结果
     */
    func createOrder(_ itemIds: [String],
                     billingAddressId:  String,
                     shippingAddressId: String,
                     shippingCompanyId: String,
                     orderPaymentId: String,
                     orderNote: String,
                     discountRequestFlag: Bool,
                     mergeShippingTargetorderId: String,
                     mergeShippingTargetShippingId: String,
                     mergeShippingRemarks: String = "",
                     useWalletAmount: Double,
                     customerShippingAcc: String,
                     warehouses: [SSTOrderWarehouse],
                     callback: @escaping RequestCallBack) {
        let urlStr = "saveOrder.json"
        
        var orderItemDicts = Array<Dictionary<String,Any>>()
        for wh in warehouses {
            var itemDicts = Array<Dictionary<String,Any>>()
            for itm in wh.orderItems {
                let itmDict: Dictionary<String, Any> = ["orderProductQty": itm.qty, "orderProductId": itm.id, "itemId":validString(biz.cart.findItem(itm.id)?.itemId)]
                itemDicts.append(itmDict)
            }
            var orderItemDict: Dictionary<String, Any> = ["whId":validString(wh.warehouseId), "shippingCompanyId":validString(wh.shippingCompanyId), "productIdAndQtyVos":itemDicts]
            if customerShippingAcc.isNotEmpty {
                orderItemDict["customerShippingAcc"] = customerShippingAcc
            }
            orderItemDicts.append(orderItemDict)
        }
        
        var requestBody : [String : Any] = [
            "orderShipping": shippingCompanyId,
            "orderPayment": orderPaymentId,
            "discountRequestFlag": validInt(discountRequestFlag),
            "orderNote": orderNote,
            "billingAddressId": billingAddressId,
            "shippingAddressId": shippingAddressId,
            "useWalletAmount": useWalletAmount,
            "orderItems": orderItemDicts]
        
        if customerShippingAcc != "" {
            requestBody["customerShippingAcc"] = customerShippingAcc
        }
        
        let tPara = ["data": [requestBody]]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: validDictionary(tPara)) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    func moveItemToAnotherOrderWarehouse(order: SSTOrder, shippingAddressCountryCode: String, shippingAddressStateCode: String, callback: @escaping RequestCallBack) {
        let urlStr = "getShippingCostByWhIdAndProduct.json"
        
        var orderItemDicts = Array<Dictionary<String,Any>>()
        for wh in order.warehouses {
            if wh.orderItems.count > 0 {
                var itemDicts = Array<Dictionary<String,Any>>()
                for itm in wh.orderItems {
                    let itmDict: Dictionary<String, Any> = ["orderProductQty": itm.qty, "orderProductId": itm.id]
                    itemDicts.append(itmDict)
                }
                let orderItemDict: Dictionary<String, Any> = ["whId":validString(wh.warehouseId), "shippingCompanyId":validString(wh.shippingCompanyId), "productIdAndQtyVos":itemDicts]
                orderItemDicts.append(orderItemDict)
            }
        }
        
        let requestBody : [String : Any] = [
            "orderItems": orderItemDicts,
            "orderNote": "",
            "shippingAddressCountryCode": shippingAddressCountryCode,
            "shippingAddressStateCode": shippingAddressStateCode
        ]
        
        let tPara = ["data": [requestBody]]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: validDictionary(tPara)) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     7. 获取产品详情
     
     - parameter productId: 产品ID
     - parameter callback:  返回结果
     */
    open func getProductDetail(_ productId: String, callback: @escaping RequestCallBack){
        let urlStr = "getProductDetail.json?productId=\(productId)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr ){ (response, err) ->Void in
            callback(response, err)
        }
    }
    
    open func addItemViewLog(_ itemId: String, callback: @escaping RequestCallBack) {
        let urlString = "productAccessNotif.json?productId=\(itemId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlString) { (data, error) -> Void in
            callback(data, error)
        }
    }

    /**
     8.根据关键字搜索产品
     
     - parameter keyword:  关键字
     - parameter start:    开始的位置（已有数据的总和）
     - parameter rows:     每次请求返回数据的条数
     - parameter callback: 返回结果
     */
    open func searchItems(_ keyword: String?,
                          groupId: String?,
                          groupTitle: [String]?,
                          deviceId: String?,
                          price: String?,
                          excludeSoldOut: Bool?,
                          start: Int = 0,
                          rows: Int = 10,
                          sort: String = "",
                          facet: String = "",
                          color: [String]?,
                          carrierName: [String]?,
                          callback: @escaping RequestCallBack) {
        let urlStr = "productV2.json"
        
        let paras: [String : Any] = [
            "q":validString(keyword),
            "groupId":validString(groupId),
            "gTitle2L":validArray(groupTitle),//carrierName
            "deviceId":validString(deviceId),
            "price":validString(price),
            "excludeSoldOut": validBool(excludeSoldOut) == true ? "1" : "",
            "start":start,
            "rows":rows,
            "sort":sort,
            "facet":facet,
            "color":validArray(color),
            "carrierName":validArray(carrierName),
            "userId":validString(biz.user.id)
        ]
        
        ntwkAccess.request(.post, url:kBaseSearchURLString +  urlStr, parameters: paras) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    open func searchItemsWithPrefix(_ keyword: String = "",
                                    start: Int = 0,
                                    rows: Int = 10,
                                    sort: String = "",
                                    facet: String = "",
                                    callback: @escaping RequestCallBack) {
        let urlStr = "productWithPrefix.json"
        var paras = [String : Any]()
        paras = [
            "q":keyword,
            "start":start,
            "rows":rows,
            "sort":sort,
            "facet":facet,
            "userId":validString(biz.user.id)
        ]
        
        printDebug(paras)
        
        ntwkAccess.request(.post, url:kBaseSearchURLString +  urlStr, parameters: paras) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     9.输入字符，提示关键字
     
     - parameter keyword:  输入的字符
     - parameter callback: 返回结果
     */
    open func getSuggestions(_ keyword: String, callback: @escaping RequestCallBack) {
        let urlStr = "product/suggest.json"
        let para = [
            "q":keyword
        ]
        ntwkAccess.request(.post, url:kBaseSearchURLString +  urlStr, parameters: para ) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     10. 搜索订单
     - parameter keyword: 搜索关键字
     - parameter start: 分页开始的位置
     - parameter rows: 每页获取的数据个数
     - parameter sort: 排行
     - parameter callback: 返回结果

     */
    open func searchOrders(
             status: String,
            keyword: String,
              start: Int = 0,
               rows: Int = 10,
               sort: String = "",
           callback: @escaping RequestCallBack) {
        
        let urlStr = "order.json"
        
        let para = [
            "status": status,
            "q": keyword,
            "start":start,
            "rows":rows,
            "sort":sort,
            "userId":validString(biz.user.id)
            ] as [String : Any]
        ntwkAccess.request(.post, url:kBaseSearchURLString +  urlStr, parameters: para ) { (response, err) -> Void in
            callback(response, err)
            
        }
    }
    
    /**
     11.获取所有快递公司及信息
     
     - parameter callback: 返回结果
     */
    open func getAllShippingCompany(_ callback: @escaping RequestCallBack){
        let urlStr = "getAllShippingCompany.json"
        ntwkAccess.request(.get, url:kBaseURLString + urlStr) {(response, err) ->Void in
            callback(response, err)
        }
    }
    
    //    /**
    //     获取用户的订单列表
    //
    //     - parameter userId:   用户ID
    //     - parameter pageNum:  第几页
    //     - parameter pageSize: 当前页获取的订单数据（默认10）
    //     - parameter callback: 返回结果
    //     */
    //    public func getOrders(pageNum: Int, callback: RequestCallBack){
    //        let urlStr = "getOrdersByUserid/ios/\(kApiVersion)?userId=\(kUserIdValue)&pageNum=\(pageNum)&pageSize=\(kSearchOrderPageSize)"
    //        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, err) ->Void in
    //            callback(response, err)
    //        }
    //    }
    
    /**
     12.获取类别信息
     
     - parameter callback:
     */
    open func getCategories(parentId: String? = nil, _ callback: @escaping RequestCallBack) {
        var urlStr = "menus/getMenusInRoot.json" //  "menus/getAllMenus.json"
        if validBool(parentId?.isNotEmpty) {
            urlStr = "menus/getMenusByParentId.json?parentId=" + validString(parentId)
        }
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     13.获取 Address list
     
     - parameter callback: 返回结果
     */
    open func getAddressList(_ callback: @escaping RequestCallBack){
        let urlStr = "address/getAddresses.json"
        ntwkAccess.request(.get, url:kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    
    /**
     14.获取Primary address
     
     - parameter callback: 返回结果
     */
    open func getDefaultPrimaryAddress(_ callback: @escaping RequestCallBack) {
        let urlStr = "address/getPrimaryAddress.json"
        ntwkAccess.request(.get, url:kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     15.获取Default Billing Address
     
     - parameter callback: 返回结果
     */
    open func getDefaultBillingAddress(_ callback: @escaping RequestCallBack) {
        let urlStr = "address/getDefaultBillingAddress.json?primaryAddressifNotExist=true"
        ntwkAccess.request(.get, url:kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
        
    }
    
    /**
     16.获取Default Shipping Address
     
     - parameter callback: 返回结果
     */
    open func getDefaultShippingAddress(_ callback: @escaping RequestCallBack) {
        let urlStr = "address/getDefaultShippingAddress.json?primaryAddressIfNotExist=true"
        ntwkAccess.request(.get, url:kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     17. 添加地址
     
     - parameter info:      address
     - parameter callback: 返回结果
     */
    func addAddress(_ info: SSTShippingAddress, callback: @escaping RequestCallBack) {
        let urlStr = "address/addAddress.json"
        
        let tPara = ["data":[[
                "addrName":  validString(info.addressName),
                "company":   validString(info.companyName),
                "firstName": validString(info.firstName),
                "lastName":  validString(info.lastName),
                "country":   validString(info.countryCode),
                "state":     validString(info.stateCode),
                "city":      validString(info.city),
                "address":   validString(info.apt),
                "phone":     validString(info.phone),
                "phone2":    validString(info.phone2),
                "phone3":    validString(info.phone3),
                "zip":       validString(info.zip),
                "email":     validString(info.email),
            ]]
        ]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: tPara ) { (response, err) -> Void in
            callback(response, err)
            
        }
    }

    /**
     18.设置Default Primary 地址
     
     - parameter addressId: 地址ID
     - parameter callback:  返回结果
     */
    func setDefaultPrimaryAddress(_ addressId:String, callback: @escaping RequestCallBack) {
        let urlStr = "address/setPrimaryAddress.json"
        let tPara = ["data":[[
                "addrId": addressId
            ]]
        ]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: tPara ) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     19.设置Default billing 地址
     
     - parameter addressId: 地址ID
     - parameter callback:  返回结果
     */
    
    func setDefaultBillingAddress(_ addressId: String, callback: @escaping RequestCallBack) {
        let urlStr = "address/setDefaultBillingAddress.json"
        let tPara = ["data":[[
                "addrId": addressId
            ]]
        ]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: tPara ) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     20.设置Default shipping 地址
     
     - parameter addressId: 地址ID
     - parameter callback:  返回结果
     */
    
    func setDefaultShippingAddress(_ addressId: String, callback: @escaping RequestCallBack) {
        let urlStr = "address/setDefaultShippingAddress.json"
        let tPara = ["data":[[
            "addrId": addressId
            ]]
        ]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: tPara ) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     21. 删除地址
     
     - parameter info:     address
     - parameter callback: 返回结果
     */
    func deleteAddress(_ addressId: String, callback: @escaping RequestCallBack) {
        let urlStr = "address/deleteAddress.json"
        let tPara = ["data":[[
            "addrId": addressId
            ]]
        ]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: tPara ) { (response, err) -> Void in
            callback(response, err)
        }
    }

    
    /**
     22.修改地址
     
     - parameter info:     地址信息
     - parameter callback: 返回结果
     */
    func updateAdderss(_ info: SSTShippingAddress, callback: @escaping RequestCallBack) {
        let urlStr = "address/updateAddress.json"

        let tPara = ["data":[["addrId": validString(info.id),
                    "addrName": validString(info.addressName),
                    "firstName": validString(info.firstName),
                    "lastName": validString(info.lastName),
                    "company": validString(info.companyName),
                    "address": validString(info.apt),
                    "zip": validString(info.zip),
                    "country": validString(info.countryCode),
                    "state": validString(info.stateCode),
                    "city": validString(info.city),
                    "phone": validString(info.phone),
                    "phone2": validString(info.phone2),
                    "phone3": validString(info.phone3),
                    "email": validString(info.email),
                    ]]
        ]
        ntwkAccess.request(.post, url:kBaseURLString + urlStr, parameters: tPara ) { (response, err) -> Void in
            callback(response, err)
        }
    }
    

    /**
     23.获取GuestToken
     - parameter callback: 返回token
     */
    open func getGuestToken (_ callback: @escaping RequestCallBack) {
        let urlStr = "getGuestToken.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
    24. 获取国家和州
     - parameter callback: 返回结果
     */
    open func getCountryAndState(_ date: String, callback: @escaping RequestCallBack) {
        let urlStr = "getCountriesAndUsastates.json?date=\(date)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     25.获取deals数据
     
     - parameter callback: 返回结果
     */
    open func getDeals(_ callback: @escaping RequestCallBack) {
        let urlStr = "getDeals.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, err) ->Void in
            callback(response, err)
        }
    }

    /**
    26.获取购物车中最好销量
     
     - parameter callback: 返回结果
     */
    open func getCartBestSellings(_ callback: @escaping RequestCallBack) {
        let urlStr = "getCartBestSellings.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response , err) -> Void in
            callback(response, err)
        }
    }
    
    /*
     27.获取购物车中今日流行产品
     - parameter callback: 返回结果
     
     */
    open func getMostPopular(_ callback: @escaping RequestCallBack) {
        let urlStr = "getPopularToday.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response , err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     28.登陆
     
     - parameter Email:    邮箱
     - parameter password: 密码
     - parameter callback: 返回结果
     */
    func login(_ userInfo: SSTUser, callback: @escaping RequestCallBack) {
        let urlStr = "login.json"
        let tPara = [
            "data":[[
                "userEmail": validString(userInfo.email),
                "userPassword": validString(userInfo.password),
                "deviceToken": gDeviceTokenString,
                ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }
    }
    
    /**
     29.注册
     
     - parameter Email:     邮箱
     - parameter Password:  密码
     - parameter firstName: 名
     - parameter callback:  返回结果
     */
    func register(_ userInfo: SSTUser, callback: @escaping RequestCallBack) {
        let urlStr = "register.json"
        let tPara = [
            "data":[[
                "userEmail":    validString(userInfo.email),
                "alternativeEmail": validString(userInfo.alternativeEmail),
                "userPassword": validString(userInfo.password),
                "firstName":    validString(userInfo.firstName),
                "deviceToken":  gDeviceTokenString,
                ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }
        
    }
    
    /**
     30.修改密码
     
     - parameter oldPassword: 旧密码
     - parameter newPassword: 新密码
     - parameter callback:    返回结果
     */
    func changePassword(user: SSTUser, oldPassword: String, newPassword: String, callback: @escaping RequestCallBack) {
        let urlStr = "updatePassword.json"
        let tPara = [
            "data":[[
                "userPassword":oldPassword,
                "newUserPassword": newPassword,
                ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara, user: user) { (response, err) in
            callback(response, err)
        }
    }

    /**
     31.获取今日免邮费的物流公司信息
     
     - parameter callback: 返回结果
     */
    func getFreeShippingInfo(_ callback: @escaping RequestCallBack) {
        let urlStr = "getTodaysFreeShippingCompanies.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, err) in
            callback(response, err)
        }
    }
    
    /**
     32.修改用户firstName
     - parameter firstName: firstName
     - parameter callback:  返回结果
     */
    func updateFirstName(_ firstName: String, callback: @escaping RequestCallBack) {
        let urlStr = "updateFirstName.json"
        let tPara = [
            "data": [
                "firstName":firstName,
            ]
        ]
            ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }
    }
    /**
    32.2.修改用户的备用邮箱
     - parameter alternativeEmail: 备用邮箱
     - parameter callback:  返回结果
    */
    func updateAlternativeEmail(_ alternativeEmail: String, callback: @escaping RequestCallBack) {
        let urlStr = "updateAlternativeEmail.json"
        let tPara = [
            "data": [
                "alternativeEmail":alternativeEmail,
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }

    }
    /**
     33.退出登陆
     - parameter callback: 返回结果
     */
    func signOut(_ user: SSTUser, callback: @escaping RequestCallBack, errorCallback: @escaping ErrorCallBack) {
        let urlStr = "signout.json"
        let tPara = [
            "data": [
                "deviceToken": gDeviceTokenString,
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara, user: user) { (data, error) in
            callback(data, error)
        }
    }
    
    /**
     34.通过邮箱获取验证码
     
     - parameter email:    邮箱
     - parameter callback: 返回结果
     */
    func getVerificationCode(_ email: String, callback: @escaping RequestCallBack) {
        let urlStr = "vercode/resetPassword.json"
        let Para = [
            "email": email,
            ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: Para) { (response, err) in
            callback(response, err)
        }
    }

    /**
     35.根据验证码更改密码
     
     - parameter email:    邮箱
     - parameter password: 密码
     - parameter code:     验证码
     - parameter callback: 返回结果
     */
    func updatePasswordByVerificationCode(_ email: String, password: String, code: String, callback: @escaping RequestCallBack) {
        let urlStr = "updatePasswordByVerCode.json"
        let tPara = [
            "data":[
                "userEmail": email,
                "userPassword": password,
                "verificationCode": code,
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }
        
    }
    
    /**
     36.收藏产品
     
     - parameter itemId:   产品ID
     - parameter callback: 返回结果
     */
    func addItemToFavorite(_ itemId: String, callback: @escaping RequestCallBack) {
        let urlStr = "favoriteProducts/addFavoriteProduct.json"
        let tPara = ["productId":itemId]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }
        
        
    }
    
    /**
     37.获取收藏的产品
     
     - parameter callback: 返回结果
     */
    func getFavorites(_ callback: @escaping RequestCallBack) {
        let urlStr = "favoriteProducts/getFavoriteProducts.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr, parameters: nil) { (response, err) in
            callback(response, err)
        }
        
    }
    
    /** http://webdev05.sstparts.com:8088/sst-mobile/sst/api/message/getNormalMessages.json?pageNum=1&pageSize=10
     38.删除收藏产品
     
     - parameter itemId:   产品ID
     - parameter callback: 返回结果
     */
    func deleteFavoriteItem(_ itemId: String, callback: @escaping RequestCallBack) {
        let urlStr = "favoriteProducts/removeFavoriteProduct.json"
        let tPara = ["productId": itemId]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
        }
    }

    /**
     39.获取APP版本号
     - parameter callback: 返回结果
     */
    
    func getLastVersion(_ callback: @escaping RequestCallBack) {
        let urlStr = "versions/getLastVersion.json?devOs=1&channel=appstore"
        //        let urlStr = "http://10.3.1.180:8080/sst-mobile/sst/api/versions/getLastVersion.json?devOs=1&channel=appstore"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, err) in
            callback(response, err)
        }
    }

    /**
     40.获取订单详情
     
     - parameter orderId:
     - parameter callback: 返回结果
     */
    func getOrderDetail(_ orderId: String, callback: @escaping RequestCallBack) {
        let urlStr = "getOrderByOrderId.json?orderId=\(orderId)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, err) in
            callback(response, err)
        }
    }
    
    /**
     41.获取首页message信息
     pageNum=1&pageSize=10
     - parameter callback: 返回结果
     */
    func getHomeMessage(pageNum: Int = 1,
                        rows: Int = 10,
                        callback: @escaping RequestCallBack) {
        let urlStr = "message/getMessages.json?pageNum=\(pageNum)&pageSize=\(rows)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    func getMessage(msgId: String, callback: @escaping RequestCallBack) {
        let urlStr = "message/getMessageById.json?msgId=\(msgId)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr) { (data, error) -> Void in
            callback(data, error)
        }
    }

    /**
     42.获取最近浏览的记录
     - parameter pageNumber: 当前页
     - parameter pageSize: 每页返回的个数
     - parameter callback: 返回结果
     */
    func getBrowseHistory(_ pageNumber: Int = 1,
                          pageSize: Int = kPageSize,
                          callback: @escaping RequestCallBack) {
        let urlStr = "productbrowsinghistory/getProductBrowsingHistory.json?pageNum=\(pageNumber)&pageSize=\(pageSize)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, err) in
            callback(response, err)
        }
    }
    
    /**
     43.删除某个浏览历史记录
     - parameter items: 产品
     - parameter callback: 返回结果
     
     */
    
    func removeFromBrowseHistory(_ items: [SSTItem], callback: @escaping RequestCallBack) {
        var dataArr = [Dictionary<String,Any>]()
        for index in 0 ..< items.count {
            let dict = [
                "id": validString(items[index].browsingHistoryId),
                ]
            dataArr.append(dict)
        }
        let tPara = [
            "data": dataArr,
            ]
        let urlStr = "productbrowsinghistory/deleteProductHistory.json"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) in
            callback(response, err)
            
        }
    }
    
    /**
     44.删除所有的浏览记录
     - parameter callback: 返回结果
     
     */
    
    func removeAllBrowseHistory(_ callback: @escaping RequestCallBack) {
        let urlStr = "productbrowsinghistory/deleteAllProductHistory.json"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) { (response, err) in
            callback(response, err)
        }
    }
    
    /**
     45.获取打折信息，
     eg: Get extra 5% on orders over USD 1000.00
     - parameter callback: 返回结果
     
     */
    
    func getDealMessage(_ callback: @escaping RequestCallBack) {
        let urlStr = "message/getDealMessages.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     46.预算订单价格和税
     - parameter items: 产品Id
     - parameter billingAddressId: billing address
     - parameter shippingAddressId: shipping address
     - parameter shippingCompanyId: 物流公司Id
     - parameter callback: 返回结果
     */

    func getOrderPriceAndTax(_ itemIds: [String],
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
        let urlstr = "preCalculateOrderPrice.json"
        
        var orderItemDicts = Array<Dictionary<String,Any>>()
        for wh in warehouses {
            var itemDicts = Array<Dictionary<String,Any>>()
            for itm in wh.orderItems {
                let itmDict: Dictionary<String, Any> = ["orderProductQty": itm.qty, "orderProductId": itm.id]
                itemDicts.append(itmDict)
            }
            let orderItemDict: Dictionary<String, Any> = ["whId":validString(wh.warehouseId), "shippingCompanyId":validString(wh.shippingCompanyId), "productIdAndQtyVos":itemDicts]
            orderItemDicts.append(orderItemDict)
        }
        
        var requestBody: [String : Any] = [
            "orderPayment": orderPaymentId,
            "orderNote": "",
            "discountRequestFlag": discountRequestFlag.hashValue,
            "billingAddressId": billingAddressId,
            "shippingAddressId": shippingAddressId,
            "shippingAddressCountryCode": shippingAddressCountryCode,
            "shippingAddressStateCode": shippingAddressStateCode,
            "orderItems": orderItemDicts
        ]
        
        if customerShippingAcc != "" {
            requestBody["customerShippingAcc"] = customerShippingAcc
        }
        
        let tPara = ["data": [requestBody]]
        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) {  (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     47.获取help中所有的solution列表
     - parameter callback: 返回结果
     
     */

    func getSolutions(_ size: Int, callback: @escaping RequestCallBack) {
        var urlStr = ""
        if size > 0 {
            urlStr = "articles/getHelpSolution.json?size=\(size)"
        } else {
            urlStr = "articles/getHelpSolution.json?"
            
        }
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, err) -> Void in
            callback(response, err)
            
        }
    }
    
    /**
     48.上传feedback
     - parameter content: 需要上传的内容
     - parameter callback: 返回结果
     
     */
    func uploadFeedback(_ content: String, callback: @escaping RequestCallBack) {
        let urlStr = "feedback/save.json"
        let tPara = [
            "data": [
                "content": content,
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
        
    }
    
    /**
     49. getNewArrivals on HomePage
     */
    func getNewArrivals(_ callback: @escaping RequestCallBack) {
        let urlStr = "getNewArrivals.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     50.get featured product on home page
     
     */
    func getFeaturedProduct(_ callback: @escaping RequestCallBack) {
        let urlStr = "getFeaturedProducts.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlStr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    
    
    /**
     51. 获取支付方式
     - parameter countryCode:国家的Code，比如US
     - parameter orderPrice:订单价格
     - parameter shippingCompanyId：物流公司ID
     - parameter orderId: 从订单列表过来，需要orderId，正常下单的时候不需要这个字段
     - parameter
     */
    func getPaymentType(_ countryCode:String , codOrderPrice:Double, shippingCompanyId: String, orderId: String, mergeTargetOrderPaymentId: Int?, callback: @escaping RequestCallBack) {
        var urlstr = "payment/getPaymentType.json?countryCode=\(countryCode)&codOrderPrice=\(codOrderPrice)&shippingCompanyId=\(shippingCompanyId)"
        if orderId != "" {
            urlstr += "&orderId=\(orderId)"
        }
        if mergeTargetOrderPaymentId != nil {
            urlstr += "&mergeTargetOrderPayment=\(validString(mergeTargetOrderPaymentId))"
        }
        ntwkAccess.request(.get, url: kBaseURLString + urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     52. 获取热门商品logo in Brand
     */
    func getHotProductsInBrand(_ brandId:Int, callback: @escaping RequestCallBack) {
        let urlstr = "getHotProductsInBrand.json?brandId=\(brandId)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     53. 上传图片
     */
    func applyCOD(_ images: UIImage, title:String , callback: @escaping RequestCallBack) {
        let urlstr = "applyCod.json"
        ntwkAccess.uploadFile(url: kBaseURLString + urlstr, files: [images], fileFieldName: title) { (response, err) in
            callback(response, err)
        }
    }

    /**
     54.更换支付方式
     - parameter orderId： 订单Id
     - parameterorderPayment: 支付方式Id
     */
    func changePaymentMethod(_ orderId: String, orderPaymentId: String, callback: @escaping RequestCallBack) {
        let urlStr = "changePaymentMethod.json"
        let tPara = ["data":
            [[
                "orderId":orderId,
                "orderPayment":orderPaymentId
            ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
        
    }
    
    /**
     55.上传推送消息需要的device token
     - parameter devicetoken: 推送需要的devicetoken
     */
    func uploadPushDeviceToken(_ deviceToken: String,callback:@escaping RequestCallBack) {
        let urlStr = "token/uploadDeviceToken.json"
        let tPara = [
            "data": [
                "deviceToken": deviceToken
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     56.获取order confirm 页的所有数据，包括shipping,billing,shipping company，merge order
     
     */
    func getCartShippingDetail(itemsId: [String],itemsTotal: Double,_ callback: @escaping RequestCallBack) {
        let itemsStr = itemsId.joined(separator: ",")
        let urlStr = "cart/getShippingDetailInfo.json?cartItemIds=\(itemsStr)&itemsTotal=\(itemsTotal)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, error) -> Void in
            callback(response, error)
        }
    }
    
    /** 56-2
     获取order confirm 页的所有数据，包括shipping，billing，多个仓库和产品数据信息
     -- parameter itemsId:     产品ID
     -- parameter shippingId: shipping地址ID
     */
    func getCartShippingDetailInfo(itemsId:[String], shippingAddressId: String,_ callback: @escaping RequestCallBack) {
        let itemsStr = itemsId.joined(separator: ",")
        let urlStr = "cart/getCartShippingDetailInfo.json?cartItemIds=\(itemsStr)&shippingAddressId=\(shippingAddressId)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, error) -> Void in
            callback(response, error)
        }
    }
    
    /**
     57.根据订单更改的shpping address查找是否有对应的可合并的订单
     - parameter shippingAddressId:物流公司ID
     - itemsId: 产品ID
     - itemsTotal: 产品总价
     */
    func getLastMergableOrder(_ shippingAddressId: String, itemsId: [String],itemsTotal: Double, callback:@escaping RequestCallBack) {
        guard itemsId.count > 0 else {
            return
        }
        let itemsStr = itemsId.joined(separator: ",")
        let urlStr = "getLastMergableTargetOrder.json?shippingAddressId=\(shippingAddressId)&itemsTotal=\(itemsTotal)&cartItemIds=\(itemsStr)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, error) -> Void in
            callback(response, error)
            
        }
        
    }

    /**
     58.get COD
     //    http://10.3.1.140:8080/sst-mobile/sst/api/applyCOD.json   kBaseURLString
     */
    func getAppCOD(_ callback: @escaping RequestCallBack) {
        let urlStr = "getApplyCod.json" //
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) { (response, error) -> Void in
            callback(response, error)
        }
    }

    /**
     59.重新计算订单的价格（订单没有付款的时候，有时候会根据时间不同订单的价格有所改变，比如优惠）
     - parameter orderId：订单ID
     
     */
    func recalculateOrder(_ orderId: String, callback:@escaping RequestCallBack) {
        let urlStr = "recalculateOrderToPay.json?orderId=\(orderId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) {  (response, error) -> Void in
            callback(response, error)
        }
    }
    
    func preCancelOrder(_ orderId: String, callback: @escaping RequestCallBack) {
        let urlStr = "checkCancelOrderRefundTotal.json?orderId=\(orderId)"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr, parameters: nil) { (response, error) in
            callback(response, error)
        }
    }
    
    func cancelOrder(_ orderId: String, callback: @escaping RequestCallBack) {
        let urlStr = "cancelOrder.json?orderId=\(orderId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) { (response, error) in
            callback(response, error)
        }
    }
    
    /**
     60.隐藏订单
     - parameter orderId：订单ID
     
     */
    func hideOrder(_ orderId: String, callback: @escaping RequestCallBack) {
        let urlStr = "hideOrder.json?orderId=\(orderId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) { (response, error) in
            callback(response, error)
        }
    }
    
    /**
     61. get guides
     */
    func getGuides(_ callback: @escaping RequestCallBack) {
        let urlStr = "appadvs/getGuides.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr, parameters: nil) { (response, error) in
            callback(response, error)
        }
    }
    
    /**
    62. save stock notification 对于缺货的产品，用户可以选择订阅有货推送
     - parameter  itemId: 缺货产品Id
     */
    func saveStockNotification(_ itemId: String, callback: @escaping RequestCallBack) {
        let urlStr = "saveStockNotifications.json?notItemId=\(itemId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) { (response, error) in
            callback(response, error)
            
        }
    }
    
    /**
     63. get stock notifications 获取已经订阅过的产品信息
     
     */
    func getStockNotifications(_ callback: @escaping RequestCallBack) {
        let urlStr = "getStockNotifications.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr, parameters: nil) { (response, error) in
            callback(response, error)
        }
    }
    
    /**
     64. delete stock notification 取消订阅
     - parameter  itemId: 需要取消订阅产品Id
     */
    func deleteStockNotification(_ itemId: String, callback: @escaping RequestCallBack) {
        let urlStr = "deleteStockNotifications.json?notItemId=\(itemId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     65. 获取欠款订单（可能会有多个订单）
     */
    
    func getAmountDueOrders(_ callback:@escaping RequestCallBack) {
        let urlStr = "getAmountDueOrders.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     66. create Billing 获取一次付清的billingID（多个订单一起支付有且只有一个billingID）
     - parameter: orderIds
     */
    func createBilling(_ orderIds:[String], callback: @escaping RequestCallBack) {
        let urlStr = "billings/createBilling.json"
        let tPara = [
           "data":[
                "orderIds": orderIds,
                ]
            ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     67. 删除cod  图片
     */
    func deleteCODImageById(_ fileId:Int, callback: @escaping RequestCallBack) {
        
        let urlStr = "deleteApplyCodImage.json"
        let tPara = [
            "data": [
                "fileId": fileId
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    /**
     68 udpate COD title
     */
    func updateCODTitleById(_ fileId:Int, title:String, callback: @escaping RequestCallBack) {
        
        let urlStr = "updateApplyCodImageName.json"
        let tPara = [
            "data": [
                "fileId": fileId,
                "fileName": title
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     69 getApplyCodRecords
     */
    func getApplyCodRecords(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "getApplyCodRecords.json"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    /**
     70. getApplyTaxFree
     */
    func getApplyTaxFree(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "getApplyTaxFree.json"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     71 getApplyTaxRecords
     */
    func getApplyTaxRecords(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "getApplyTaxFreeRecords.json"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     72. TAX 上传图片
     */
    func applyTAX(_ images: UIImage, title:String , callback: @escaping RequestCallBack) {
        let urlstr = "applyTaxFree.json"
        ntwkAccess.uploadFile(url: kBaseURLString + urlstr, files: [images], fileFieldName: title) { (response, err) in
            callback(response, err)
        }
    }
    
    
    /**
     73. udpate TAX title
     */
    func updateTAXTitleById(_ fileId:Int, title:String, callback: @escaping RequestCallBack) {
        
        let urlStr = "updateTaxFreeImageName.json"
        let tPara = [
            "data": [
                "fileId": fileId,
                "fileName": title
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     74. 删除 tax 图片
     */
    func deleteTAXImageById(_ fileId:Int, callback: @escaping RequestCallBack) {
        
        let urlStr = "deleteTaxFreeImage.json"
        let tPara = [
            "data": [
                "fileId": fileId
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     75. 首页点击message调用
     */
    func saveMessageRecord(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "message/saveMessageRecord.json"
        ntwkAccess.request(.post, url: kBaseURLString + urlStr, parameters: nil) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     76. 获取setting 信息列表
     
     */
    func getSettingInformations(_ callback: @escaping RequestCallBack) {
        let urlStr = "getHelpDocuments.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlStr)  { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     77.获取订单状态的个数
     
     */
    func getOrderNumbers(_ callback:  @escaping RequestCallBack) {
        let urlStr = "order/nums.json"
        ntwkAccess.request(.get, url: kBaseSearchURLString + urlStr) {(response, err) -> Void in
            callback(response, err)
            
        }
    }
    
    /**
     78. getApplyCodAndTaxFreeStatus.json
     */
    func getApplyCodAndTaxFreeStatus(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "getApplyCodAndTaxFreeStatus.json"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    /**
     78. getBrands.json
     */
    func getBrands(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "devices/getBrands.json"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     79. getSeriess.json
     */
    func getSeriess(brandId:Int, _ callback: @escaping RequestCallBack) {
        
        let urlStr = "devices/getSeries.json?brandId=\(brandId)"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     80. getDevicess.json
     */
    func getDevices(seriesId:Int, _ callback: @escaping RequestCallBack) {
        
        let urlStr = "devices/getDevices.json?seriesId=\(seriesId)"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    /**
     81. getAdvertisingProducts.json
     */
    func getAdvertisingProducts(_ callback: @escaping RequestCallBack) {
        
        let urlStr = "getAdvertisingProducts.json"
        
        ntwkAccess.request(.get, url: kBaseURLString + urlStr) {(response, error) in
            callback(response, error)
        }
    }
    
    
    /**
     82. 获取热门商品logo in Category
     */
    func getHotProductsInCategory(_ groupId:Int, callback: @escaping RequestCallBack) {
        let urlstr = "getHotProducts.json?groupId=\(groupId)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     83. 获取热门商品logo in Series
     */
    func getHotProductsInSeries(_ seriesId:Int, callback: @escaping RequestCallBack) {
        let urlstr = "getHotProductsInSeries.json?seriesId=\(seriesId)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     84. 首页弹窗信息（24小时一次）
     */
    func getDiscountInformation(callback: @escaping RequestCallBack){
        let urlstr = "getDiscountInfomation.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     85.获取钱包页详情
     */
    
    func getWalletDetailInfo(pageNum:Int, callback: @escaping RequestCallBack) {
        let urlstr = "wallets/getBalanceAndDetails.json?pageNum=\(pageNum)&pageSize=\(kPageSize)"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     86.获取钱包余额
     
     */
    func getWalletBalance(callback: @escaping RequestCallBack) {
        let urlstr = "wallets/getBalance.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
//    /**
//     86.预算重新支付的订单对应的价格（订单列表和订单详情点击进入payment option时显示的数据）
//     - parameter: orderId 订单id
//     */
//    func recalculateOrderToPay(orderId: String,callback: @escaping RequestCallBack) {
//        let urlstr = "recalculateOrderToPay.json?orderId=\(orderId)"
//        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
//            callback(response, err)
//        }
//    }
    
    
    /**
     87.重新支付订单（从订单列表或者订单详情进入支付页面，pay）
     */
    func payOrder(orderId:String, orderPaymentId: Int, useWalletAmount: Double, orderFinalTotal: Double, payAnywayForDiscountReq: Int, callback: @escaping RequestCallBack) {
        let urlstr = "payOrder.json"
        let tPara = [
            "data": [[
                "orderId": orderId,
                "orderPayment": orderPaymentId,
                "useWalletAmount": useWalletAmount,
                "orderFinalTotal": orderFinalTotal.formatMoney(),
                "payAnywayForDiscountReq":payAnywayForDiscountReq
            ]]
        ]

        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     88.把钱包支付的金额传给后台
     - parameter: orderId 订单ID
     - parameter: useWalletAmount 钱包支付的数目
     
     */
    func payOrderWithWallet(orderId: String, useWalletAmount: Double, callback: @escaping RequestCallBack) {
        let urlstr = "payOrderWithWallet.json"
        let tPara = [
            "data": [[
                "orderId": orderId,
                "useWalletAmount": validString(useWalletAmount),
                ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    func payBalanceOrdersWithWallet(billingId: String, useWalletAmount: Double, callback: @escaping RequestCallBack) {
        let urlstr = "payBillWithWallet.json"
        let tPara = [
            "data": [[
                "billingId": billingId,
                "useWalletAmount": validString(useWalletAmount),
                ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     89.获取欠款情况下的订单支付方式
     */
    func getRepayPaymentType(callback: @escaping RequestCallBack) {
        let urlstr = "payment/getRepayPaymentType.json"
        ntwkAccess.request(.get, url:kBaseURLString +  urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     90.根据欠款订单列表，获取billing id
     */
    func createBiling(orderIds: [String], callback: @escaping RequestCallBack) {
        let urlstr = "billings/createBilling.json"
        let tPara = [
            "orderIds": orderIds
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     91.欠款订单批量还款，如果选择钱包支付，则需要调用这个接口 （跟接口88）
     */
    func payBillWithWallet(billingId: String, walletAmount: Double, callback: @escaping RequestCallBack) {
        let urlstr = "payBillWithWallet.json"
        let tPara = [
            "data": [[
                "billingId": billingId,
                "useWalletAmount": validString(walletAmount),
                ]]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
        
    }
    
    /**
     92.当天发货的下单提醒
     */
    func getDailyShippingTips(callback: @escaping RequestCallBack) {
        let urlstr = "getDailyShippingTips.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlstr) { (response, err) -> Void in
            callback(response, err)
        }
        
    }
    
    /**
     93.获取订单的物流信息（从订单列表中支付，如果合并的订单已经发货，则需要重新选择物流）
     - parameter: orderId 订单ID
     */
    func getOrderShippingDetail(orderId: String, callback: @escaping RequestCallBack) {
        let urlstr = "getOrderShippingDetailInfo.json?orderId=\(validString(orderId))"
        ntwkAccess.request(.get, url: kBaseURLString + urlstr) { (response, err) -> Void in
            callback(response, err)
        }
    }

    /**
     94.更新订单的详细信息（根据API93，重新选择物流方式之后，调用这个接口获取payment option信息）
     
     */
    func updateOrderShippingDetailInfo(orderId: String,
                                       orderShipping: String,
                                       billingId: String,
                                       shippingId: String,
                                       customerShippingAcc: String,
                                       mergeShippingTargetOrderId: String,
                                       warehouses: [SSTOrderWarehouse],
                                       callback: @escaping RequestCallBack) {
        let urlstr = "updateOrderShippingDetailInfo.json"
        
        var orderItemDicts = Array<Dictionary<String,Any>>()
        for wh in warehouses {
            var itemDicts = Array<Dictionary<String,Any>>()
            for itm in wh.orderItems {
                let itmDict: Dictionary<String, Any> = ["orderProductQty": itm.qty, "orderProductId": itm.id, "itemId":""]
                itemDicts.append(itmDict)
            }
            let orderItemDict: Dictionary<String, Any> = ["whId":validString(wh.warehouseId), "shippingCompanyId":validString(wh.shippingCompanyId), "productIdAndQtyVos":itemDicts]
            orderItemDicts.append(orderItemDict)
        }
        
        var requestBody : [String : Any] = [
            "orderId": orderId,
            "orderWarehouseItems":orderItemDicts
        ]
        
        if billingId != "" {
            requestBody["billingAddressId"] = billingId
        }
        if shippingId != "" {
            requestBody["shippingAddressId"] = shippingId
        }
        
        if customerShippingAcc != "" {
            requestBody["customerShippingAcc"] = customerShippingAcc
        }
        
        let tPara = ["data": requestBody]
        
        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
            callback(response, err)
        }
    }
    
//    /**
//     95.在用户输入shipping account 之后调用，重算订单价格
//     */
//    func getOrderByShippingAccount(orderId: String, customerAcc: String, callback: @escaping RequestCallBack) {
//        let urlstr = "getOrderByCustomerShippingAcc.json?orderId=\(validString(orderId))&customerShippingAcc=\(validString(customerAcc))"
//        ntwkAccess.request(.get, url: kBaseURLString + urlstr) {(response, err) -> Void in
//            callback(response, err)
//
//        }
//        
//    }
//    
//    /**
//     96.在Pay order接口之前调用，调用成功再调用Pay order接口开始支付过程。
//     */
//    func updateOrderShippingAccount(orderId: String, customerShippingAcc: String, callback: @escaping RequestCallBack) {
//        let urlstr = "updateOrderCustomerShippingAcc.json"
//        let tPara = [
//            "data":[
//                "orderId": orderId,
//                "customerShippingAcc": customerShippingAcc,
//                ]
//        ]
//        ntwkAccess.request(.post, url: kBaseURLString + urlstr, parameters: tPara) { (response, err) -> Void in
//            callback(response, err)
//        }
//    }
    
    /**
     97.order shipping detail 页面，重新选择地址后，更新物流信息
     */
    func getlastMergableTargetOrderByOrderId(shippingAddressId:String, orderId: String, callback: @escaping RequestCallBack) {
        let urlstr = "getLastMergableTargetOrderByOrderId.json?shippingAddressId=\(validString(shippingAddressId))&orderId=\(validString(orderId))"
        ntwkAccess.request(.get, url: kBaseURLString + urlstr) {(response, err) -> Void in
            callback(response, err)
        }
    }
    
    /**
     98. get article by id
     */
    func getArticle(id: String, callback: @escaping RequestCallBack) {
        let urlstr = "getArticle.json?articleId=\(id)"
        ntwkAccess.request(.get, url: kBaseURLString + urlstr) { (data, error) in
            callback(data, error)
        }
    }
    
    /**
     99. get global configs
     */
    func getGlobalConfigs(callback: @escaping RequestCallBack) {
        let urlstr = "getGlobalConfigs.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlstr) { (data, error) in
            callback(data, error)
        }
    }
    
    /**
     100. get city and state by postal code
     */
    func getCityAndState(countryCode: String, postalCode: String, callback: @escaping RequestCallBack) {
        let urlString = "address/getCityAndStateByPostalCode.json?countryCode=\(countryCode)&postalCode=\(postalCode)"
        ntwkAccess.request(.get, url: kBaseURLString + urlString) { (data, error) in
            callback(data, error)
        }
    }
    
    func buyOrderAgain(orderId: String, callback: @escaping RequestCallBack) {
        let urlString = "buyAgain.json?orderId=\(orderId)"
        ntwkAccess.request(.post, url: kBaseURLString + urlString) { (data, error) in
            callback(data, error)
        }
    }
    
    func getContactData(callback: @escaping RequestCallBack) {
        let urlString = "question/getQuestions.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlString) { (data, error) in
            callback(data, error)
        }
    }
    
    func addContactRecord(title: String, content: String, files: [UIImage]? = nil, callback: @escaping RequestCallBack) {
        let urlString = "question/saveQuestion.json"
        ntwkAccess.uploadFile(url: kBaseURLString + urlString, files: files, fileFieldName: "byte", fieldNames: ["question","message"], fieldValues: [title,content]) { (data, error) in
            callback(data, error)
        }
    }
    
    func getContactRecordReplies(id: String, callback: @escaping RequestCallBack) {
        let urlString = "question/getQuestionReplies.json?questionId=\(id)"
        ntwkAccess.request(.get, url: kBaseURLString + urlString) { (data, error) in
            callback(data, error)
        }
    }
    
    func addContactReply(questionId: String, msg: String, callback: @escaping RequestCallBack) {
        let urlString = "question/saveQuestionReply.json"
        let tPara = [
            "data": [
                "questionId": questionId,
                "reply": msg
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlString, parameters: tPara) { (data, error) in
            callback(data, error)
        }
    }
    
    func addContactReplyImage(questionId: String, image: UIImage, fileName: String, callback: @escaping RequestCallBack) {
        let urlString = "question/saveQuestionReplyImage.json"
        ntwkAccess.uploadFile(url: kBaseURLString + urlString, files: [image], fileFieldName: "file", fieldNames: ["questionId","fileName"], fieldValues: [questionId,fileName]) { (data, error) in
            callback(data, error)
        }
    }
    
    func getContactStatus(callback: @escaping RequestCallBack) {
        let urlString = "getNewStatus.json"
        ntwkAccess.request(.get, url: kBaseURLString + urlString) { (data, error) in
            callback(data, error)
        }
    }
    
    func addRateAndSuggestion(questionId: String, score: Int, suggestion: String, callback: @escaping RequestCallBack) {
        let urlString = "question/rateTheQuestionList.json"
        let tPara = [
            "data": [
                "questionId": questionId,
                "score": score,
                "feedback": suggestion
            ]
        ]
        ntwkAccess.request(.post, url: kBaseURLString + urlString, parameters: tPara) { (data, error) in
            callback(data, error)
        }
    }
    
}
