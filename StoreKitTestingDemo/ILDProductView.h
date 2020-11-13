//
//  ILDProductView.h
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/13.
//

#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ILDProductView;
@protocol ILDProductViewDelegate <NSObject>

- (void)tapView:(ILDProductView *)view product:(SKProduct *)product;

@end

@interface ILDProductView : UIView

@property (nonatomic, weak) id<ILDProductViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame product:(SKProduct *)product;

@end

NS_ASSUME_NONNULL_END
