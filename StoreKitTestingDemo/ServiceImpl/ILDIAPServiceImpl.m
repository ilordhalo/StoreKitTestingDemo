//
//  ILDIAPServiceImpl.m
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/23.
//

#import "ILDIAPServiceImpl.h"

#import "ILDIAPManager.h"

@interface ILDIAPServiceImpl ()

@end

@implementation ILDIAPServiceImpl

- (void)startService
{
    [[ILDIAPManager defaultManager] startService];
}

- (void)requestProducts:(NSSet *)productIdentifiers
{
    [[ILDIAPManager defaultManager] requestProducts:productIdentifiers];
}

- (void)buyProduct:(SKProduct *)product applicationUsername:(NSString *)applicationUsername
{
    [[ILDIAPManager defaultManager] buyProduct:product applicationUsername:applicationUsername];
}

- (void)buyProductWithIdentifier:(NSString *)productIdentifier applicationUsername:(NSString *)applicationUsername
{
    [[ILDIAPManager defaultManager] buyProductWithIdentifier:productIdentifier applicationUsername:applicationUsername];
}

- (void)setDelegate:(id<ILDIAPServiceDelegate>)delegate
{
    [ILDIAPManager defaultManager].delegate = (id<ILDIAPDelegate>)delegate;
}

@end
