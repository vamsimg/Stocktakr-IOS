//
//  ProductManager.h
//  Stocktakr
//
//  Created by Sherman Lo on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductManager : NSObject

+ (id)sharedManager;


#pragma mark - Networking
- (void)loadProductListWithStoreId:(NSString *)storeId password:(NSString *)password complete:(void (^)(BOOL success))complete progress:(void (^)(double progress))progress;
- (void)validateCredentialsWithStoreId:(NSString *)storeId password:(NSString *)password complete:(void (^)(BOOL success))complete;
- (void)uploadStocktakeRecordsWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL success))complete;
- (void)uploadPurchaseOrdersWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL success))complete;

#pragma mark - Products
- (NSInteger)numberOfProducts;
- (NSDictionary *)productForBarcode:(NSString *)barcode;

#pragma mark - Stocktake
- (NSArray *)stocktakeRecords;
- (NSNumber *)incrementStocktakeQuantityForBarcode:(NSString *)barcode;
- (BOOL)setStocktakeQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode;
- (NSNumber *)stocktakeQuantityForBarcode:(NSString *)barcode;
- (void)deleteStocktakeRecordForProduct:(NSString *)productCode;

#pragma mark - Purchase Order
- (NSArray *)purchaseOrderRecords;
- (NSNumber *)incrementPurchaseOrderQuantityForBarcode:(NSString *)barcode;
- (BOOL)setPurchaseOrderQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode;
- (NSNumber *)purchaseOrderQuantityForBarcode:(NSString *)barcode;
- (void)deletePurchaseOrderRecordForProduct:(NSString *)productCode;

@end
