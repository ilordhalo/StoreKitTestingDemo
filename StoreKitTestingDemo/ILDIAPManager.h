//
//  ILDIAPManager.h
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/22.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

typedef NS_ENUM (NSInteger, ILDIAPManagerBuyingState) {
    ILDIAPManagerBuyingStateBeforeBuy,
    ILDIAPManagerBuyingStateHandleTransaction,
    ILDIAPManagerBuyingStateComplete
};

typedef NS_ENUM (NSInteger, ILDIAPManagerErrorCode) {
    ILDIAPManagerErrorUnknown,
    ILDIAPManagerErrorNoProduct,
    ILDIAPManagerErrorReceiptVerifyFailure,
};

@protocol ILDIAPDelegate <NSObject>

- (void)buyProductFinished:(BOOL)finished state:(ILDIAPManagerBuyingState)state transaction:(SKPaymentTransaction *)transaction error:(NSError *)error;
- (void)requestProductFinished:(BOOL)finished error:(NSError *)error;

@end

@interface ILDIAPManager : NSObject

@property (nonatomic, weak) id<ILDIAPDelegate> delegate;

+ (instancetype)defaultManager;

- (void)startService;
- (void)requestProducts:(NSSet *)productIdentifiers;
- (void)buyProduct:(SKProduct *)product applicationUsername:(NSString *)applicationUsername;
- (void)buyProductWithIdentifier:(NSString *)productIdentifier applicationUsername:(NSString *)applicationUsername;

@end
