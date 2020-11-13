//
//  ILDProductView.m
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/13.
//

#import "ILDProductView.h"

@interface ILDProductView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) SKProduct *product;

@end

@implementation ILDProductView

- (instancetype)initWithFrame:(CGRect)frame product:(nonnull SKProduct *)product
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self updateProduct:product];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tap
{
    [self.delegate tapView:self product:self.product];
}

- (void)setupUI
{
    self.backgroundColor = [UIColor grayColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];
    [self addSubview:self.priceLabel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:8]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.priceLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.priceLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:16]];
}

- (void)updateProduct:(SKProduct *)product
{
    self.titleLabel.text = product.localizedTitle;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    self.priceLabel.text = formattedString;
    
    _product = product;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.font = [UIFont systemFontOfSize:12];
        _priceLabel.textColor = [UIColor blackColor];
    }
    return _priceLabel;
}

@end
