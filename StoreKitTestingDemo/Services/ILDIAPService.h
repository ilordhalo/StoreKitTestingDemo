//
//  ILDIAPService.h
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/23.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

typedef NS_ENUM (NSInteger, ILDIAPServiceBuyingState) {
    ILDIAPServiceBuyingStateBeforeBuy,
    ILDIAPServiceBuyingStateHandleTransaction,
    ILDIAPServiceBuyingStateComplete
};

typedef NS_ENUM (NSInteger, ILDIAPServiceErrorCode) {
    ILDIAPServiceErrorUnknown,
    ILDIAPServiceErrorNoProduct,
    ILDIAPServiceErrorReceiptVerifyFailure
};

@protocol ILDIAPServiceDelegate <NSObject>

- (void)buyProductFinished:(BOOL)finished state:(ILDIAPServiceBuyingState)state transaction:(SKPaymentTransaction *)transaction error:(NSError *)error;
- (void)requestProductFinished:(BOOL)finished error:(NSError *)error;

@end

@protocol ILDIAPService <NSObject>

- (void)startService;
- (void)requestProducts:(NSSet *)productIdentifiers;
- (void)buyProduct:(SKProduct *)product applicationUsername:(NSString *)applicationUsername;
- (void)buyProductWithIdentifier:(NSString *)productIdentifier applicationUsername:(NSString *)applicationUsername;
- (void)setDelegate:(id<ILDIAPServiceDelegate>)delegate;

@end
