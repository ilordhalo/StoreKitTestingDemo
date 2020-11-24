# StoreKit
### 使用
执行test.sh开始测试
默认测试内置的ILDIAPManager

支持通过服务定位灵活替换不同的IAP支付流程，进行测试
### 单测case
* 正常购买流程-transactionPurchased
* 正常购买流程-transactionFailed
* 中断购买流程-transaction先失败后成功
* 询问购买流程-transactionDeferred
* 应用外购买流程