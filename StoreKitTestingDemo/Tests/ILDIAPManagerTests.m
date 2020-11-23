//
//  ILDIAPManagerTests.m
//  StoreKitTestingDemoTests
//
//  Created by zhangjiahao.me on 2020/11/22.
//

#import <StoreKitTest/StoreKitTest.h>

#import "ILDBaseTests.h"
#import "ILDIAPManager.h"

static NSString *const ILDIAPManagerTestMainProgressCaseKey = @"main progress";
static NSString *const ILDIAPManagerTestInterruptedCaseKey = @"interrupted";
static NSString *const ILDIAPManagerTestAskToBuyCaseKey = @"ask to buy";
static NSString *const ILDIAPManagerTestExternalCaseKey = @"external";
static NSString *const ILDIAPManagerTestFailCaseKey = @"fail";

static NSString *const ILDIAPManagerTestInterruptedProductID = @"com.ilord.utest.product.main";
static NSString *const ILDIAPManagerTestMainProgressProductID = @"com.ilord.utest.product.interrupted";
static NSString *const ILDIAPManagerTestAskToBuyProductID = @"com.ilord.utest.product.askToBuy";
static NSString *const ILDIAPManagerTestExternalProductID = @"com.ilord.utest.product.external";
static NSString *const ILDIAPManagerTestFailProductID = @"com.ilord.utest.product.fail";

@interface ILDIAPManagerTestCase : NSObject

@property (nonatomic, copy) NSString *caseDesc;
@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation ILDIAPManagerTestCase

@end

@interface ILDIAPManagerTests : ILDBaseTests <ILDIAPDelegate>

@property (nonatomic, strong) ILDIAPManagerTestCase *testingCase;
@property (nonatomic, strong) XCTestExpectation *setUpExpectation;

@property (nonatomic, strong) NSMutableArray *products;

@property (nonatomic, strong) SKTestSession *currentSession;

@end

@implementation ILDIAPManagerTests

- (void)setUp
{
    [super setUp];
    
    [[ILDIAPManager defaultManager] startService];
    [ILDIAPManager defaultManager].delegate = self;
    self.testingCase = [ILDIAPManagerTestCase new];
    self.limitDuraion = 3.f;
    
    NSError *sessionCreateError = nil;
    SKTestSession *session = [[SKTestSession alloc] initWithConfigurationFileNamed:@"IAPUnitTestConfiguration" error:&sessionCreateError];
    self.currentSession = session;
    
    XCTAssertTrue(!sessionCreateError);
    
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"fetch products timeout"]];
    self.setUpExpectation = expectation;
    [[ILDIAPManager defaultManager] requestProducts:[NSSet setWithObjects:ILDIAPManagerTestMainProgressProductID, ILDIAPManagerTestInterruptedProductID, ILDIAPManagerTestAskToBuyProductID, ILDIAPManagerTestExternalProductID,ILDIAPManagerTestFailProductID, nil]];
    [self waitForExpectationsWithTimeout:2.f handler:nil];
}

- (void)tearDown
{
    [super tearDown];
    
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
}

- (void)testIAPMainProgress
{
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
    self.currentSession.disableDialogs = YES;

    NSString *caseDesc = ILDIAPManagerTestMainProgressCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDIAPManager defaultManager] buyProductWithIdentifier:ILDIAPManagerTestMainProgressProductID applicationUsername:@""];

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)testIAPInterrupted
{
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
    self.currentSession.disableDialogs = YES;
    self.currentSession.interruptedPurchasesEnabled = YES;

    NSString *caseDesc = ILDIAPManagerTestInterruptedCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDIAPManager defaultManager] buyProductWithIdentifier:ILDIAPManagerTestInterruptedProductID applicationUsername:@""];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *resolveError = nil;
        BOOL success = [self.currentSession resolveIssueForTransactionWithIdentifier:self.currentSession.allTransactions.lastObject.identifier error:&resolveError];
        XCTAssertTrue(success && !resolveError);
    });

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)testIAPAskToBuy
{
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
    self.currentSession.disableDialogs = YES;
    self.currentSession.askToBuyEnabled = YES;

    NSString *caseDesc = ILDIAPManagerTestAskToBuyCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDIAPManager defaultManager] buyProductWithIdentifier:ILDIAPManagerTestAskToBuyProductID applicationUsername:@""];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *approveError = nil;
        BOOL success = [self.currentSession approveAskToBuyTransactionWithIdentifier:self.currentSession.allTransactions.lastObject.identifier error:&approveError];
        XCTAssertTrue(success && !approveError);
    });

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)testIAPExternal
{
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
    self.currentSession.disableDialogs = YES;

    NSString *caseDesc = ILDIAPManagerTestExternalCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    NSError *buyError = nil;
    BOOL success = [self.currentSession buyProductWithIdentifier:ILDIAPManagerTestExternalProductID error:&buyError];
    XCTAssertTrue(success && !buyError);

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)testIAPFailTransaction
{
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
    self.currentSession.disableDialogs = YES;
    self.currentSession.failTransactionsEnabled = YES;
    self.currentSession.failureError = SKErrorUnknown;

    NSString *caseDesc = ILDIAPManagerTestFailCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDIAPManager defaultManager] buyProductWithIdentifier:ILDIAPManagerTestFailProductID applicationUsername:@""];

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)requestProductFinished:(BOOL)finished error:(NSError *)error
{
    XCTAssertTrue(finished, @"fetch product failure, error: %@", error);
    if (finished) {
        [self.setUpExpectation fulfill];
    }
}

- (void)buyProductFinished:(BOOL)finished state:(ILDIAPManagerBuyingState)state transaction:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    if (state == ILDIAPManagerBuyingStateComplete) {
        XCTAssertTrue(finished, @"%@ case failed error:%@", self.testingCase.caseDesc, error.description);
        XCTAssertTrue(self.currentSession.allTransactions.lastObject.identifier == (NSUInteger)transaction.transactionIdentifier.integerValue, @"testing transaction:%lu, verified transaction:%lu", self.currentSession.allTransactions.lastObject.identifier, (NSUInteger)transaction.transactionIdentifier.integerValue);
        
        [self.testingCase.expectation fulfill];
    } else if (state == ILDIAPManagerBuyingStateHandleTransaction) {
        if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            XCTAssertFalse([[SKPaymentQueue defaultQueue].transactions containsObject:transaction], @"%@ case should finish failed transaction first", self.testingCase.caseDesc);
            if ([self.testingCase.caseDesc isEqualToString:ILDIAPManagerTestFailCaseKey]) {
                [self.testingCase.expectation fulfill];
            }
        }
    }
}

@end
