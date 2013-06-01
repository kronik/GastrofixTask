//
//  DKDataParser.m
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKDataParser.h"
#import "DKStreetEntity+CSV.h"

#define kDKDataParserDefaultFileName @"data"
#define kDKDataParserDefaultFileExtension @"csv"
#define kDKDataParserDefaultFileHeaderLinesNumber 1
#define kDKDataParserDefaultFileColumnsCount 3

@interface DKDataParser ()

@property (nonatomic, assign) BOOL isParsing;
@property (nonatomic, strong) NSString *firstColumnData;

@end

@implementation DKDataParser

@synthesize fileName = _fileName;
@synthesize columnsSeparator = _columnsSeparator;
@synthesize skipLinesNumber = _skipLinesNumber;
@synthesize isParsing = _isParsing;
@synthesize columnsCount = _columnsCount;
@synthesize delegate = _delegate;
@synthesize onRowsParseComplete = _onRowsParseComplete;
@synthesize parsedRows = _parsedRows;

+ (DKDataParser *)sharedInstance {
   	static DKDataParser *dataParser = nil;

	if (dataParser == nil) {
		@synchronized(self) {
            if (dataParser == nil) {
                dataParser = [[DKDataParser alloc] initWithFileName: kDKDataParserDefaultFileName
                                                       andSeparator: kDKDataParserDefaultColumnsSeparator
                                                withSkipLinesNumber: kDKDataParserDefaultFileHeaderLinesNumber
                                                    andColumnsCount: kDKDataParserDefaultFileColumnsCount];
            }
        }
	}
	
	return dataParser;
}

- (id)initWithFileName: (NSString *)fileName
          andSeparator: (NSString *)columnsSeparator
   withSkipLinesNumber: (UInt32)skipLinesNumber
       andColumnsCount: (UInt32)columnsCount {
    
	if (self = [super init]) {
        _fileName = fileName;
        _columnsSeparator = columnsSeparator;
        _skipLinesNumber = skipLinesNumber;
        _columnsCount = columnsCount;
    }
    
    return self;
}

- (NSMutableArray *) parsedRows {
    if (_parsedRows == nil) {
        _parsedRows = [NSMutableArray new];
    }
    
    return _parsedRows;
}

- (void)parseWithDelegate: (id<DKDataParserDelegate>) delegate {
    
    _delegate = delegate;
    
    dispatch_queue_t queue = dispatch_queue_create ("Parse with Delegate Queue", NULL);
    
    dispatch_async (queue, ^ {
        [self parseFile];
    });
    
    dispatch_release (queue);
}

- (void)parseWithCompleteBlock: (RowsParseComplete) onRowsParseComplete {
    _onRowsParseComplete = onRowsParseComplete;
    
    [self parseFile];
}

- (void)parseFile {
    
    @synchronized (self) {
        if (self.isParsing == YES) {
            return;
        }
        
        self.isParsing = YES;
    }
    
    NSError *error = nil;
    NSString *bundleDataFilePath = [[NSBundle mainBundle] pathForResource: self.fileName
                                                                   ofType: kDKDataParserDefaultFileExtension];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: bundleDataFilePath] == NO) {
        return;
    }
    
    NSString *csvFileDataAsString = [NSString stringWithContentsOfFile: bundleDataFilePath
                                                              encoding: NSUTF8StringEncoding
                                                                 error: &error];
    if ((error != nil) || (csvFileDataAsString.length == 0) || (self.columnsSeparator.length == 0)) {
        return;
    }

    _parsedRows = [NSMutableArray new];
    
    NSDate *startTime = [NSDate date];
    
    NSArray *rawRecords = [csvFileDataAsString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    
    // Release extra memory
    csvFileDataAsString = nil;
        
    if (rawRecords.count > self.skipLinesNumber) {
    
        for (int i = self.skipLinesNumber; i < rawRecords.count; i++) {
            NSString *rawRecord = rawRecords [i];
            
            if (rawRecord.length > 0) {
                [self parseRow: rawRecord];
            }
        }
    }
    
    // Release extra memory
    rawRecords = nil;
    
    [self notifyRequestor];
    
    double processingTime = [[NSDate date] timeIntervalSinceDate: startTime];
    
    NSLog(@"Total processing time: %.2f", processingTime);

    @synchronized (self) {
        self.isParsing = NO;
    }
}

- (void)notifyRequestor {
    if ((self.delegate != nil) &&
        ([self.delegate respondsToSelector:@selector(dataParser:didParseRowWithData:)])) {
        
        dispatch_async (dispatch_get_main_queue(), ^{
            [self.delegate dataParser: self didFinishParseRows: self.parsedRows];
        });
    }
    
    if (self.onRowsParseComplete != nil) {
        self.onRowsParseComplete (self.parsedRows);
    }
}

- (void)parseRow: (NSString *)rowData{
    
    if (rowData.length == 1) {
        self.firstColumnData = rowData;
    } else if ([rowData rangeOfString: self.columnsSeparator].location == NSNotFound) {
        self.firstColumnData = rowData;
    } else {
        NSArray *cells = [rowData componentsSeparatedByString: self.columnsSeparator];
        
        [self wrapAndSaveParsedData: cells];
    }
}

- (void)wrapAndSaveParsedData: (NSArray *)cellValues {
    
    if ((cellValues.count != self.columnsCount) || (self.firstColumnData.length != 1)) {
        return;
    }
    
    NSDictionary *parsedData = @{kDKStreetEntityGroupIdKey : self.firstColumnData,
                                 kDKStreetEntityNameKey : cellValues [1],
                                 kDKStreetEntityMapIndexKey: cellValues [2]};
    
    [self.parsedRows addObject: parsedData];    
}

@end
