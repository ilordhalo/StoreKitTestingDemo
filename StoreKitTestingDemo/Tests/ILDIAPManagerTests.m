//
//  ILDIAPServiceTests.m
//  StoreKitTestingDemoTests
//
//  Created by zhangjiahao.me on 2020/11/22.
//

#import <StoreKitTest/StoreKitTest.h>
#import <XCTest/XCTest.h>

#import "ILDServiceLocator+IAPService.h"

static NSString *const ILDIAPServiceTestMainProgressCaseKey = @"main progress";
static NSString *const ILDIAPServiceTestInterruptedCaseKey = @"interrupted";
static NSString *const ILDIAPServiceTestAskToBuyCaseKey = @"ask to buy";
static NSString *const ILDIAPServiceTestExternalCaseKey = @"external";
static NSString *const ILDIAPServiceTestFailCaseKey = @"fail";

static NSString *const ILDIAPServiceTestInterruptedProductID = @"com.ilord.utest.product.main";
static NSString *const ILDIAPServiceTestMainProgressProductID = @"com.ilord.utest.product.interrupted";
static NSString *const ILDIAPServiceTestAskToBuyProductID = @"com.ilord.utest.product.askToBuy";
static NSString *const ILDIAPServiceTestExternalProductID = @"com.ilord.utest.product.external";
static NSString *const ILDIAPServiceTestFailProductID = @"com.ilord.utest.product.fail";

@interface ILDIAPServiceTestCase : NSObject

@property (nonatomic, copy) NSString *caseDesc;
@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation ILDIAPServiceTestCase

@end

@interface ILDIAPServiceTests : XCTestCase <ILDIAPServiceDelegate>

@property (nonatomic, strong) ILDIAPServiceTestCase *testingCase;
@property (nonatomic, strong) XCTestExpectation *setUpExpectation;

@property (nonatomic, assign) NSTimeInterval limitDuraion;

@property (nonatomic, strong) NSMutableArray *products;

@property (nonatomic, strong) SKTestSession *currentSession;

@end

@implementation ILDIAPServiceTests

- (void)setUp
{
    [super setUp];
    
    [[ILDServiceLocator iapService] startService];
    [[ILDServiceLocator iapService] setDelegate:self];
    self.testingCase = [ILDIAPServiceTestCase new];
    self.limitDuraion = 3.f;
    
    NSError *sessionCreateError = nil;
    SKTestSession *session = [[SKTestSession alloc] initWithConfigurationFileNamed:@"IAPUnitTestConfiguration" error:&sessionCreateError];
    self.currentSession = session;
    
    XCTAssertTrue(!sessionCreateError);
    
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"fetch products timeout"]];
    self.setUpExpectation = expectation;
    [[ILDServiceLocator iapService] requestProducts:[NSSet setWithObjects:ILDIAPServiceTestMainProgressProductID, ILDIAPServiceTestInterruptedProductID, ILDIAPServiceTestAskToBuyProductID, ILDIAPServiceTestExternalProductID,ILDIAPServiceTestFailProductID, nil]];
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

    NSString *caseDesc = ILDIAPServiceTestMainProgressCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDServiceLocator iapService] buyProductWithIdentifier:ILDIAPServiceTestMainProgressProductID applicationUsername:@""];

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)testIAPInterrupted
{
    [self.currentSession clearTransactions];
    [self.currentSession resetToDefaultState];
    self.currentSession.disableDialogs = YES;
    self.currentSession.interruptedPurchasesEnabled = YES;

    NSString *caseDesc = ILDIAPServiceTestInterruptedCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDServiceLocator iapService] buyProductWithIdentifier:ILDIAPServiceTestInterruptedProductID applicationUsername:@""];

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

    NSString *caseDesc = ILDIAPServiceTestAskToBuyCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDServiceLocator iapService] buyProductWithIdentifier:ILDIAPServiceTestAskToBuyProductID applicationUsername:@""];

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

    NSString *caseDesc = ILDIAPServiceTestExternalCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    NSError *buyError = nil;
    BOOL success = [self.currentSession buyProductWithIdentifier:ILDIAPServiceTestExternalProductID error:&buyError];
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

    NSString *caseDesc = ILDIAPServiceTestFailCaseKey;
    XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithFormat:@"%@ verify timeout", caseDesc]];
    self.testingCase.expectation = expectation;
    self.testingCase.caseDesc = caseDesc;

    [[ILDServiceLocator iapService] buyProductWithIdentifier:ILDIAPServiceTestFailProductID applicationUsername:@""];

    [self waitForExpectationsWithTimeout:self.limitDuraion handler:nil];
}

- (void)requestProductFinished:(BOOL)finished error:(NSError *)error
{
    XCTAssertTrue(finished, @"fetch product failure, error: %@", error);
    if (finished) {
        [self.setUpExpectation fulfill];
    }
}

- (void)buyProductFinished:(BOOL)finished state:(ILDIAPServiceBuyingState)state transaction:(SKPaymentTransaction *)transaction error:(NSError *)error
{
    if (state == ILDIAPServiceBuyingStateComplete) {
        XCTAssertTrue(finished, @"%@ case failed error:%@", self.testingCase.caseDesc, error.description);
        XCTAssertTrue(self.currentSession.allTransactions.lastObject.identifier == (NSUInteger)transaction.transactionIdentifier.integerValue, @"testing transaction:%lu, verified transaction:%lu", self.currentSession.allTransactions.lastObject.identifier, (NSUInteger)transaction.transactionIdentifier.integerValue);
        
        [self.testingCase.expectation fulfill];
    } else if (state == ILDIAPServiceBuyingStateHandleTransaction) {
        if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            XCTAssertFalse([[SKPaymentQueue defaultQueue].transactions containsObject:transaction], @"%@ case should finish failed transaction first", self.testingCase.caseDesc);
            if ([self.testingCase.caseDesc isEqualToString:ILDIAPServiceTestFailCaseKey]) {
                [self.testingCase.expectation fulfill];
            }
        }
    }
}

@end
