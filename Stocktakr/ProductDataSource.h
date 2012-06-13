//
//  ProductDataSource.h
//  Stocktakr
//
//  Created by Sherman Lo on 9/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProductDataSource <NSObject>

- (NSNumber *)quantityForBarcode:(NSString *)barcode;
- (NSNumber *)incrementQuantityForBarcode:(NSString *)barcode;
- (BOOL)setQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode;

- (NSArray *)records;
- (NSUInteger)numberOfRecords;

- (void)deleteForProduct:(NSString *)productCode;

- (void)uploadWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL success))complete;

- (BOOL)shouldAutoIncrementQuantity;

@end
