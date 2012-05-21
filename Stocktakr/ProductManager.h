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

- (void)loadProductListWithStoreId:(NSString *)storeId password:(NSString *)password complete:(void (^)(BOOL success))complete progress:(void (^)(double progress))progress;
- (void)validateCredentialsWithStoreId:(NSString *)storeId password:(NSString *)password complete:(void (^)(BOOL success))complete;
- (void)uploadStocktakeRecordsWithStoreId:(NSString *)storeId password:(NSString *)password person:(NSString *)person complete:(void (^)(BOOL success))complete;

- (NSInteger)numberOfProducts;
- (NSInteger)numberOfRecords;

- (NSArray *)records;

- (NSDictionary *)productForBarcode:(NSString *)barcode;

- (NSNumber *)incrementQuantityForBarcode:(NSString *)barcode;
- (BOOL)setQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode;

@end
