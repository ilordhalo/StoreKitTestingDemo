//
//  ILDIAPManager.m
//  StoreKitTestingDemo
//
//  Created by zhangjiahao.me on 2020/11/22.
//

#import "ILDIAPManager.h"

static NSString *const ILDIAPManagerErrorDomain = @"ILDIAPManagerErrorDomain";

@interface ILDIAPManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *productsRequest;

@property (nonatomic, strong) NSMutableArray<SKProduct *> *products;
 
@end

@implementation ILDIAPManager

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

+ (instancetype)defaultManager
{
    static ILDIAPManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ILDIAPManager alloc] init];
    });
    return instance;
}

+ (NSString *)receipt
{
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    return [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (void)startService
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)requestProducts:(NSSet *)productIdentifiers
{
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void)buyProduct:(id)product applicationUsername:(NSString *)applicationUsername
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = applicationUsername;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)buyProductWithIdentifier:(NSString *)productIdentifier applicationUsername:(NSString *)applicationUsername
{
    __block SKProduct *product = nil;
    [self.products enumerateObjectsUsingBlock:^(SKProduct * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.productIdentifier isEqualToString:productIdentifier]) {
            product = obj;
            *stop = YES;
        }
    }];
    
    if (!product) {
        NSError *error = [NSError errorWithDomain:ILDIAPManagerErrorDomain code:ILDIAPManagerErrorNoProduct userInfo:nil];
        !self.delegate ?: [self.delegate buyProductFinished:NO state:ILDIAPManagerBuyingStateBeforeBuy transaction:nil error:error];
        return;
    }
    
    !self.delegate ?: [self.delegate buyProductFinished:YES state:ILDIAPManagerBuyingStateBeforeBuy transaction:nil error:nil];
    [self buyProduct:product applicationUsername:applicationUsername];
}

- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (response.products.count > 0) {
            self.products = [response.products mutableCopy];
            !self.delegate ?: [self.delegate requestProductFinished:YES error:nil];
        } else {
            NSError *error = [NSError errorWithDomain:ILDIAPManagerErrorDomain code:ILDIAPManagerErrorNoProduct userInfo:nil];
            !self.delegate ?: [self.delegate requestProductFinished:NO error:error];
        }
    });
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    [transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.transactionState) {
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"transaction id:%@ failed; reason: %@", obj.transactionIdentifier, obj.error.description);
                [self handleFailedTransaction:obj];
                break;
            }
            case SKPaymentTransactionStateDeferred:
            {
                NSLog(@"transaction id:%@ deferred;", obj.transactionIdentifier);
                [self handleDeferredTransaction:obj];
                break;
            }
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"transaction id:%@ purchasing;", obj.transactionIdentifier);
                [self handlePurchasingTransaction:obj];
                break;
            }
            case SKPaymentTransactionStatePurchased:
            {
                NSLog(@"transaction id:%@ purchased;", obj.transactionIdentifier);
                [self verifyTransaction:obj];
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"transaction id:%@ restored;", obj.transactionIdentifier);
                [self handleRestoredTransaction:obj];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"transaction id:%@ finish;", transaction.transactionIdentifier);
        [self finishTransaction:transaction];
        !self.delegate ?: [self.delegate buyProductFinished:YES state:ILDIAPManagerBuyingStateComplete transaction:transaction error:nil];
    });
}

- (void)handleFailedTransaction:(SKPaymentTransaction *)transaction
{
    [self finishTransaction:transaction];
    
    NSError *error = [NSError errorWithDomain:ILDIAPManagerErrorDomain code:ILDIAPManagerErrorUnknown userInfo:nil];
    !self.delegate ?: [self.delegate buyProductFinished:NO state:ILDIAPManagerBuyingStateHandleTransaction transaction:transaction error:error];
}

- (void)handleDeferredTransaction:(SKPaymentTransaction *)transaction
{
    !self.delegate ?: [self.delegate buyProductFinished:NO state:ILDIAPManagerBuyingStateHandleTransaction transaction:transaction error:nil];
}

- (void)handlePurchasingTransaction:(SKPaymentTransaction *)transaction
{
    !self.delegate ?: [self.delegate buyProductFinished:NO state:ILDIAPManagerBuyingStateHandleTransaction transaction:transaction error:nil];
}

- (void)handleRestoredTransaction:(SKPaymentTransaction *)transaction
{
    !self.delegate ?: [self.delegate buyProductFinished:NO state:ILDIAPManagerBuyingStateHandleTransaction transaction:transaction error:nil];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
