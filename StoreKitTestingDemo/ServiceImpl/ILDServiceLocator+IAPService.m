//
//  ILDServiceLocator+IAPService.m
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/23.
//

#import "ILDServiceLocator+IAPService.h"

#import "ILDIAPManager.h"
#import "ILDIAPServiceImpl.h"

@implementation ILDServiceLocator (IAPService)

+ (id<ILDIAPService>)iapService
{
    static id<ILDIAPService> service = nil;
    if (!service) {
        service = [ILDIAPServiceImpl new];
    }
    return service;
}

@end
