//
//  ViewController.m
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/13.
//

#import "ViewController.h"

#import <StoreKit/StoreKit.h>

#import "ILDProductView.h"
#import "ILDIAPManager.h"

@interface ViewController () <SKProductsRequestDelegate, ILDProductViewDelegate>

@property (nonatomic, strong) SKProductsRequest *productsRequest;

@end

@implementation ViewController

- (BOOL)test
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self refreshProducts];
    
    UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 312, [UIScreen mainScreen].bounds.size.width, 48)];
    refreshButton.backgroundColor = [UIColor grayColor];
    [self.view addSubview:refreshButton];
    [refreshButton addTarget:self action:@selector(refreshProducts) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshProducts
{
    NSSet *products = [NSSet setWithObjects:@"com.ilord.test.product0", @"com.ilord.test.product1", nil];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (response.products.count > 0) {
            [response.products enumerateObjectsUsingBlock:^(SKProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == 0) {
                    ILDProductView *v = [[ILDProductView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 48) product:obj];
                    v.delegate = self;
                    [self.view addSubview:v];
                } else if (idx == 1) {
                    ILDProductView *v = [[ILDProductView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 48) product:obj];
                    v.delegate = self;
                    [self.view addSubview:v];
                }
            }];
        }
    });

}

- (void)tapView:(ILDProductView *)view product:(SKProduct *)product
{
    NSLog(@"tap: %@", product.localizedTitle);
    
    [[ILDIAPManager defaultManager] buyProduct:product applicationUsername:@"test_user"];
}

@end
