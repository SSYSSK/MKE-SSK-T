//
//  SSTTextCart.swift
//  sst-ios
//
//  Created by Zal Zhang on 4/1/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kOrderShippingAddress    = "Shipping Address"
let kOrderBillingAddress     = "Billing Address"
let kOrderDeliveryMethods    = "Shipping From"

let kOrderShippingAddressTip = "Please select shipping address first"
let kOrderBillingAddressTip  = "Please select billing address first"
let kOrderShippingCompanyTip = "Please select shipping company first"
let kOrderShippingAccountTip = "Please enter your FedEx account first"

let kOrderConfirmContinueFailed = "Please try again later"

let kOrderPaymentTypeTip = "Please select payment type first"
let kOrderNoteTip = "Order note should contains account and shipping method"
let kPaymentOptionsTitle = "Payment Options"

let kOrderResultOK = "Thanks for your order"
let kOrderResultUnpaidTip = "Your order has been created, but payment has not yet completed!"
let kOrderResultCODTip = "Please prepare Money Order or Cashier’s check payable to: SST before time of deliver"
let kOrderResultRequestDiscountTip = "We will review your discount request as soon as possible. Please notice we cannot guarantee the review processing time of discount request order."

let kOrderWalletFailedTip = "Failed to pay with wallet, please try again later"

let kCartCellQtyText = "You must enter a positive integer"
let kCartUpdateQtyFailedText = "Failed to adjust item quantity"
let kCartRemoveFailedText = "Failed to remove item"

let kErrorTip = "Something went wrong, please try again later"

let kCartCellDiscountTip = "Contains %d item%@ with Daily Deals discount"

let kCartPayFaildWhenPaypalOKAndWalletFailedTip = "Order paid successfully with PayPal, but failed with wallet. Please pay the unpaid total again"
let kCartArchivePaypalConfirmationErrorTip = "Error, fail to archive the confirmation locally from Paypal SDK"

let kPaypalSubtotalErrorTip = "Unable to process payment. Please check the subtotal again"
let kPaypalOpenErrorTip = "Failed to open PayPal SDK, please try again later"
let kPaypalCancelTip = "Are you sure to exit PayPal payment process? Unpaid order can be viewed in order list"
let kPaypalCancelResultText = "Payment process cancelled"

let kViaAccountIsEmpty = "You have selected \"Ship via my FedEx account \" option. Please enter your FedEx account number before proceeding"

let kNoOrderFetchedTip = "Unfortunately, this order record is no longer available"

let kItemNotOkForCheckoutTip = "A product in your Shopping Cart is no longer available or out of stock already. Please remove it from Shopping Cart to continue."
let kItemsNotOkForCheckoutTip = "Some products in your Shopping Cart are no longer available or out of stock already. Please remove them from Shopping Cart to continue."

let kCartIsUpdatingTip = "Please wait a few seconds to allow Shopping Cart updates"
let kWarehouseNotice   = "Dear customer,our system suggested to ship your order from different warehouses due to the item availability."

let kEmptyAllWharehouseItemsTip = "You are about to delete the last item from your shopping cart. Do you wish to continue?"
