//
//  ViewController.m
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/13.
//

#import "ViewController.h"

#import <StoreKit/StoreKit.h>

#import "ILDProductView.h"

@interface ViewController () <SKProductsRequestDelegate, ILDProductViewDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) SKProductsRequest *productsRequest;

@end

@implementation ViewController

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
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
    
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = [NSUUID UUID].UUIDString;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

+ (NSString *)receipt
{
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    return [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.transactionState) {
            case SKPaymentTransactionStateFailed:
                NSLog(@"transaction id:%@ failed; reason: %@", obj.transactionIdentifier, obj.error.description);
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"transaction id:%@ deferred; reason: %@", obj.transactionIdentifier, obj.error.description);
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"transaction id:%@ purchasing;", obj.transactionIdentifier);
                break;
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"transaction id:%@ purchased;", obj.transactionIdentifier);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"transaction id:%@ finish;", obj.transactionIdentifier);
                    [[SKPaymentQueue defaultQueue] finishTransaction:obj];
                });
                break;
            }
            case SKPaymentTransactionStateRestored:
                NSLog(@"transaction id:%@ restored;", obj.transactionIdentifier);
                break;
            default:
                break;
        }
    }];
}

@end
