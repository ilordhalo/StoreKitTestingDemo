//
//  ILDServiceLocator+IAPService.h
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/23.
//

#import <Foundation/Foundation.h>

#import "ILDServiceLocator.h"
#import "ILDIAPService.h"

@interface ILDServiceLocator (IAPService)

+ (id<ILDIAPService>)iapService;

@end
