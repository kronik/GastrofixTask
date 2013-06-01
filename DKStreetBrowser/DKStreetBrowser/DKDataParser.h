//
//  DKDataParser.h
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RowsParseComplete)(NSArray *parsedData);

@class DKDataParser;

@protocol DKDataParserDelegate <NSObject>

- (void) dataParser: (DKDataParser *)parser didFinishParseRows: (NSArray *)rowData;

@end

@interface DKDataParser : NSObject

#define kDKDataParserDefaultColumnsSeparator @","

+ (DKDataParser *)sharedInstance;

@property (nonatomic, strong, readonly) NSString *columnsSeparator;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, readonly) UInt32 skipLinesNumber;
@property (nonatomic, readonly) UInt32 columnsCount;
@property (nonatomic, strong) id <DKDataParserDelegate> delegate;
@property (nonatomic, strong, readonly) RowsParseComplete onRowsParseComplete;
@property (nonatomic, strong, readonly) NSMutableArray *parsedRows;

- (id)initWithFileName: (NSString *)fileName
          andSeparator: (NSString *)columnsSeparator
   withSkipLinesNumber: (UInt32)skipLinesNumber
       andColumnsCount: (UInt32)columnsCount;

- (void)parseWithDelegate: (id<DKDataParserDelegate>) delegate;
- (void)parseWithCompleteBlock: (RowsParseComplete) onRowsParseComplete;

@end
