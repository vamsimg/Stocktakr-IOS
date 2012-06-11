//
//  ProductManager.m
//  Stocktakr
//
//  Created by Sherman Lo on 14/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductManager.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "NSData+Base64.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "SSZipArchive.h"
#import "NSString+URLEncoding.h"


#define DOWNLOAD_BATCH_SIZE 5000

static NSString *const HostName = @"http://www.stocktakr.com";
static NSString *const ItemCountPath = @"MobileItemHandler/ItemCount";
static NSString *const TestConnectionPath = @"MobileItemHandler/TestConnection";
static NSString *const ZippedItemsPath = @"MobileItemHandler/ZippedItems";
static NSString *const ZippedStocktakeTransactionsPath = @"MobileItemHandler/ZippedStocktakeTransactions";
static NSString *const PurchaseOrderItemsPath = @"MobileItemHandler/PurchaseOrderItems";

static NSString *const ProductsTable = @"products";
static NSString *const StocktakeQuantitiesTable = @"stocktake_quantities";
static NSString *const PurchaseOrderQuantitiesTable = @"purchase_order_quantities";


@interface ProductManager ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

- (void)itemCountWithStoreId:(NSString *)storeId password:(NSString *)password success:(void (^)(id JSON))success;
- (void)zippedItemsWithStoreId:(NSString *)storeId password:(NSString *)password page:(NSInteger)page success:(void (^)())success;

- (NSString *)productCodeForBarcode:(NSString *)barcode;

- (NSData *)zipRecords:(NSArray *)records;
- (NSArray *)productsFromZippedText:(NSString *)zippedText;

- (NSDateFormatter *)urlDateFormatter;
- (NSDateFormatter *)dateFormatter;
- (NSString *)clientType;

- (void)deleteAll;

- (NSArray *)recordsForTable:(NSString *)table;
- (NSNumber *)quantityForTable:(NSString *)table andBarcode:(NSString *)barcode;
- (NSNumber *)incrementQuantityForTable:(NSString *)table andBarcode:(NSString *)barcode;
- (BOOL)setQuantity:(NSNumber *)quantity forTable:(NSString *)table andBarcode:(NSString *)barcode;
- (void)deleteRecordForTable:(NSString *)table andProductCode:(NSString *)productCode;

@end


@implementation ProductManager

@synthesize databaseQueue = databaseQueue_;


#pragma mark - Public class methods

+ (id)sharedManager {
	static dispatch_once_t once;
	static ProductManager *sharedManager;
	dispatch_once(&once, ^{ sharedManager = [[self alloc] init]; });
	return sharedManager;
}


#pragma mark - Init / dealloc

- (id)init {
	if (self = [super init]) {
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[documentsDirectory stringByAppendingPathComponent:@"stocktakr.sqlite"]];
		[self.databaseQueue inDatabase:^(FMDatabase *db) {
			[db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (code TEXT PRIMARY KEY, barcode TEXT, description TEXT, price TEXT)", ProductsTable]];
			[db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (code TEXT PRIMARY KEY, quantity DOUBLE, last_modified TEXT)", StocktakeQuantitiesTable]];
			[db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (code TEXT PRIMARY KEY, quantity DOUBLE, last_modified TEXT)", PurchaseOrderQuantitiesTable]];
		}];
	}
	return self;
}

- (void)dealloc {
	[self.databaseQueue close];
}


#pragma mark - Networking

- (void)loadProductListWithStoreId:(NSString *)storeId password:(NSString *)password complete:(void (^)(BOOL success))complete progress:(void (^)(double))progress {
	[self itemCountWithStoreId:storeId password:password success:^(id JSON) {
		NSInteger itemCount = [[JSON valueForKey:@"itemCount"] integerValue];
		[self.databaseQueue inDatabase:^(FMDatabase *db) {
			[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", ProductsTable]];
		}];
		if (itemCount == 0) {
			// We want the completion handler to be run after this method returns to mimic what happens if items are actually fetched
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
				complete(YES);
			});
		} else {
			NSInteger lastPage = (itemCount / DOWNLOAD_BATCH_SIZE);
			double numPages = lastPage + 1;
			__block NSMutableIndexSet *downloadedPages = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, lastPage + 1)];
			for (int i = 0; i <= lastPage; i++) {
				[self zippedItemsWithStoreId:storeId password:password page:i success:^{
					[downloadedPages removeIndex:i];
					if ([downloadedPages count]) {
						progress((numPages - [downloadedPages count]) / numPages);
					} else {
						complete(YES);
					}
				}];
			}
		}
	}];
}

- (void)validateCredentialsWithStoreId:(NSString *)storeId password:(NSString *)password complete:(void (^)(BOOL success))complete {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", HostName, TestConnectionPath, storeId, password]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request addValue:@"application/json " forHTTPHeaderField:@"Content-type"];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		BOOL successful = ![[JSON valueForKey:@"is_error"] boolValue];
		[self deleteAll];
		complete(successful);
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		NSLog(@"FAILURE: %@", JSON);
		//TODO: Call delegate error handling method
	}];
	
	[operation start];
}

- (void)uploadStocktakeRecordsWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL))complete {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@", HostName, ZippedStocktakeTransactionsPath, storeId, password, [self clientType], [name urlEncode]]];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request addValue:@"application/json " forHTTPHeaderField:@"Content-type"];
		[request setHTTPMethod:@"POST"];
		
		__block NSMutableArray *records = [NSMutableArray array];
		[self.databaseQueue inDatabase:^(FMDatabase *db) {
			FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %1$@, %2$@ WHERE %1$@.code = %2$@.code", ProductsTable, StocktakeQuantitiesTable]];
			while ([rs next]) {
				NSMutableDictionary *record = [NSMutableDictionary dictionary];
				[record setValue:[rs stringForColumn:@"code"] forKey:@"product_code"];
				[record setValue:[rs stringForColumn:@"barcode"] forKey:@"product_barcode"];
				[record setValue:[rs stringForColumn:@"description"] forKey:@"description"];
				[record setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"quantity"]] forKey:@"quantity"];
				[record setValue:[rs stringForColumn:@"last_modified"] forKey:@"stocktake_datetime"];
				
				[records addObject:record];
			}
		}];
		
		NSDictionary *payload = [NSDictionary dictionaryWithObject:[self zipRecords:records] forKey:@"transactions"];
		[request setHTTPBody:[[CJSONSerializer serializer] serializeDictionary:payload error:nil]];
		
		AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
			BOOL success = ![[JSON valueForKey:@"is_error"] boolValue];
			if (success) {
				[self.databaseQueue inDatabase:^(FMDatabase *db) {
					[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", StocktakeQuantitiesTable]];
				}];
			}
			complete(success);
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
			complete(NO);
		}];
		
		[operation start];
	});
}

- (void)uploadPurchaseOrdersWithStoreId:(NSString *)storeId password:(NSString *)password name:(NSString *)name complete:(void (^)(BOOL success))complete {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@/%@", HostName, PurchaseOrderItemsPath, storeId, password, [self clientType], [name urlEncode], [[self urlDateFormatter] stringFromDate:[NSDate date]]]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request addValue:@"application/json " forHTTPHeaderField:@"Content-type"];
	[request setHTTPMethod:@"POST"];
	
	__block NSMutableArray *records = [NSMutableArray array];
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %1$@, %2$@ WHERE %1$@.code = %2$@.code", ProductsTable, PurchaseOrderQuantitiesTable]];
		while ([rs next]) {
			NSMutableDictionary *record = [NSMutableDictionary dictionary];
			[record setValue:[rs stringForColumn:@"code"] forKey:@"product_code"];
			[record setValue:[rs stringForColumn:@"barcode"] forKey:@"product_barcode"];
			[record setValue:[rs stringForColumn:@"description"] forKey:@"description"];
			[record setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"quantity"]] forKey:@"quantity"];
			[record setValue:[rs stringForColumn:@"last_modified"] forKey:@"stocktake_datetime"];
			
			[records addObject:record];
		}
	}];
	
	NSString *recordsString = [[NSString alloc] initWithData:[[CJSONSerializer serializer] serializeArray:records error:nil] encoding:NSUTF8StringEncoding];
	
	NSDictionary *payload = [NSDictionary dictionaryWithObject:recordsString forKey:@"transactions"];
	[request setHTTPBody:[[CJSONSerializer serializer] serializeDictionary:payload error:nil]];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		BOOL success = ![[JSON valueForKey:@"is_error"] boolValue];
		if (success) {
			[self.databaseQueue inDatabase:^(FMDatabase *db) {
				[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", PurchaseOrderQuantitiesTable]];
			}];
		}
		complete(success);
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		complete(NO);
	}];
	
	[operation start];

}


#pragma mark - Products

- (NSInteger)numberOfProducts {
	__block NSInteger numProducts = 0;
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		numProducts = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", ProductsTable]];
	}];
	return numProducts;
}

- (NSDictionary *)productForBarcode:(NSString *)barcode {
	__block NSMutableDictionary *product = nil;
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE barcode = ?", ProductsTable], barcode];
		// Get the first record, if there isn't one then we can't find the barcode
		if (![rs next]) {
			return;
		}
		
		product = [NSMutableDictionary dictionary];
		[product setValue:[rs stringForColumn:@"code"] forKey:@"code"];
		[product setValue:[rs stringForColumn:@"barcode"] forKey:@"barcode"];
		[product setValue:[rs stringForColumn:@"description"] forKey:@"description"];
		[product setValue:[rs stringForColumn:@"price"] forKey:@"price"];
		
		[rs close];
	}];
	
	return product;
}


#pragma mark - Stocktake

- (NSArray *)stocktakeRecords {
	return [self recordsForTable:StocktakeQuantitiesTable];
}

- (NSNumber *)incrementStocktakeQuantityForBarcode:(NSString *)barcode {
	return [self incrementQuantityForTable:StocktakeQuantitiesTable andBarcode:barcode];
}

- (BOOL)setStocktakeQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode {
	return [self setQuantity:quantity forTable:StocktakeQuantitiesTable andBarcode:barcode];
}

- (NSNumber *)stocktakeQuantityForBarcode:(NSString *)barcode {
	return [self quantityForTable:StocktakeQuantitiesTable andBarcode:barcode];
}

- (void)deleteStocktakeRecordForProduct:(NSString *)productCode {
	[self deleteRecordForTable:StocktakeQuantitiesTable andProductCode:productCode];
}


#pragma mark - Purchase Order

- (NSArray *)purchaseOrderRecords {
	return [self recordsForTable:PurchaseOrderQuantitiesTable];
}

- (NSNumber *)incrementPurchaseOrderQuantityForBarcode:(NSString *)barcode {
	return [self incrementQuantityForTable:PurchaseOrderQuantitiesTable andBarcode:barcode];
}

- (BOOL)setPurchaseOrderQuantity:(NSNumber *)quantity forBarcode:(NSString *)barcode {
	return [self setQuantity:quantity forTable:PurchaseOrderQuantitiesTable andBarcode:barcode];
}

- (NSNumber *)purchaseOrderQuantityForBarcode:(NSString *)barcode {
	return [self quantityForTable:PurchaseOrderQuantitiesTable andBarcode:barcode];
}
- (void)deletePurchaseOrderRecordForProduct:(NSString *)productCode {
	
}

#pragma mark - Private methods

- (void)itemCountWithStoreId:(NSString *)storeId password:(NSString *)password success:(void (^)(id JSON))success {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", HostName, ItemCountPath, storeId, password]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request addValue:@"application/json " forHTTPHeaderField:@"Content-type"];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		success(JSON);
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		NSLog(@"ERROR: %@", error);
	}];
	
	[operation start];
}

- (void)zippedItemsWithStoreId:(NSString *)storeId password:(NSString *)password page:(NSInteger)page success:(void (^)())success {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@/%@/%d/%d", HostName, ZippedItemsPath, storeId, password, [self clientType], page * DOWNLOAD_BATCH_SIZE, DOWNLOAD_BATCH_SIZE]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSArray *products = [self productsFromZippedText:[JSON valueForKey:@"zippedText"]];
			
			[self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
				for (NSDictionary *product in products) {
					NSMutableDictionary *values = [NSMutableDictionary dictionary];
					[values setValue:[product valueForKey:@"product_code"] forKey:@"code"];
					[values setValue:[product valueForKey:@"product_barcode"] forKey:@"barcode"];
					[values setValue:[product valueForKey:@"description"] forKey:@"description"];
					[values setValue:[product valueForKey:@"sale_price"] forKey:@"price"];
					[db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (code, barcode, description, price) VALUES (:code, :barcode, :description, :price)", ProductsTable] withParameterDictionary:values];
				}
			}];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				success();
			});
		});
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		NSLog(@"ERROR: %@ %@", response, error);
	}];
	
	[operation start];
}

- (NSString *)productCodeForBarcode:(NSString *)barcode {
	__block NSString *code = nil;
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT code FROM %@ WHERE barcode = ?", ProductsTable], barcode];
		// Get the first record, if there isn't one then we can't find the barcode
		if (![rs next]) {
			return;
		}
		code = [rs stringForColumn:@"code"];
		[rs close];
	}];
	return code;
}

- (NSString *)zipRecords:(NSArray *)records {
	NSString *dataFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"data"];
	[[[CJSONSerializer serializer] serializeArray:records error:nil] writeToFile:dataFile atomically:YES];
	
	NSString *zipFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload.zip"];
	[SSZipArchive createZipFileAtPath:zipFile withFilesAtPaths:[NSArray arrayWithObject:dataFile]];
	
	NSString *encodedRecords = [[NSData dataWithContentsOfFile:zipFile] base64EncodedString];
	
	// Clean up the temporary files
	[[NSFileManager defaultManager] removeItemAtPath:dataFile error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:zipFile error:nil];
	
	return encodedRecords;
}

- (NSArray *)productsFromZippedText:(NSString *)zippedText {
	NSData *zippedData = [NSData dataFromBase64String:zippedText];
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
	CFRelease(uuid);
	
	NSString *filename = [NSTemporaryDirectory() stringByAppendingFormat:@"%d.zip", uuidString];
	NSString *folder = [NSTemporaryDirectory() stringByAppendingFormat:@"%d", uuidString];
	
	[zippedData writeToFile:filename atomically:YES];
	
	[SSZipArchive unzipFileAtPath:filename toDestination:folder];

	NSData *productData = [NSData dataWithContentsOfFile:[folder stringByAppendingPathComponent:@"data"]];
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];
	deserializer.allowedEncoding = NSISOLatin1StringEncoding;
	NSArray *products = [deserializer deserialize:productData error:nil];
	
	[[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:folder error:nil];
	
	return products;
}

- (NSDateFormatter *)urlDateFormatter {
	static NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	}
	return dateFormatter;
}

- (NSDateFormatter *)dateFormatter {
	static NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	}
	return dateFormatter;
}

- (NSString *)clientType {
	return [[NSString stringWithFormat:@"iPhone|%@", [[UIDevice currentDevice] systemVersion]] urlEncode];
}

- (void)deleteAll {
	[self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
		[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", ProductsTable]];
		[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", StocktakeQuantitiesTable]];
		[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@", PurchaseOrderQuantitiesTable]];
	}];
}

- (NSArray *)recordsForTable:(NSString *)table {
	__block NSMutableArray *records = [NSMutableArray array];
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %1$@, %2$@ WHERE %1$@.code = %2$@.code", ProductsTable, table]];
		while ([rs next]) {
			NSMutableDictionary *record = [NSMutableDictionary dictionary];
			[record setValue:[rs stringForColumn:@"code"] forKey:@"code"];
			[record setValue:[rs stringForColumn:@"barcode"] forKey:@"barcode"];
			[record setValue:[rs stringForColumn:@"description"] forKey:@"description"];
			[record setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"quantity"]] forKey:@"quantity"];
			
			[records addObject:record];
		}
	}];
	return records;
}
- (NSNumber *)quantityForTable:(NSString *)table andBarcode:(NSString *)barcode {
	NSString *code = [self productCodeForBarcode:barcode];
	if (!code) {
		return nil;
	}
	
	__block NSNumber *quantity = nil;
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT quantity FROM %@ WHERE code = ?", table], code];
		if ([rs next]) {
			quantity = [NSNumber numberWithDouble:[rs doubleForColumn:@"quantity"]];
		} else {
			quantity = [NSNumber numberWithInt:0];
		}
		[rs close];
	}];
	
	return quantity;
}

- (NSNumber *)incrementQuantityForTable:(NSString *)table andBarcode:(NSString *)barcode {
	NSString *code = [self productCodeForBarcode:barcode];
	if (!code) {
		return nil;
	}
	
	NSString *lastModified = [[self dateFormatter] stringFromDate:[NSDate date]];
	__block NSNumber *newQuantity = nil;
	
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT quantity FROM %@ WHERE code = ?", table], code];
		if ([rs next]) {
			// A current record exists
			double quantity = [rs doubleForColumn:@"quantity"];
			newQuantity = [NSNumber numberWithDouble:quantity + 1];
			[db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET quantity = ?, last_modified = ? WHERE code = ?", table], newQuantity, lastModified, code];
		} else {
			newQuantity = [NSNumber numberWithInt:1];
			// No record exists, make a new one
			[db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (code, quantity, last_modified) VALUES (?, ?, ?)", table], code, newQuantity, lastModified];
		}
		[rs close];
	}];
	
	return newQuantity;
}

- (BOOL)setQuantity:(NSNumber *)quantity forTable:(NSString *)table andBarcode:(NSString *)barcode {
	NSString *code = [self productCodeForBarcode:barcode];
	if (!code) {
		return NO;
	}
	
	if ([quantity isEqualToNumber:[NSNumber numberWithInt:0]]) {
		[self deleteStocktakeRecordForProduct:code];
		return YES;
	}
	
	NSString *lastModified = [[self dateFormatter] stringFromDate:[NSDate date]];
	
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		int numRecords = [db intForQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE code = ?", table], code];
		if (numRecords) {
			[db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET quantity = ?, last_modified = ? WHERE code = ?", table], quantity, lastModified, code];
		} else {
			[db executeUpdate:[NSString stringWithFormat:@"INSERT INTO %@ (code, quantity, last_modified) VALUES (?, ?, ?)", table], code, quantity, lastModified];
		}
	}];
	
	return YES;
}

- (void)deleteRecordForTable:(NSString *)table andProductCode:(NSString *)productCode {
	[self.databaseQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE code = ?", StocktakeQuantitiesTable], productCode];
	}];
}

@end
