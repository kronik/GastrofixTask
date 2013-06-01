//
//  DKStreetCell.m
//  DKStreetBrowser
//
//  Created by Dmitry Klimkin on 1/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKStreetCell.h"

#define kDKStreetCellDefaultWidth 100.0f
#define kDKStreetCellDefaultBottomBorderSize 5.0f
#define kDKStreetCellDefaultRightBorderSize 40.0f

#define kDKSteetCellDefaultTitleFont @"HelveticaNeue-Bold"
#define kDKSteetCellDefaultSubTitleFont @"HelveticaNeue"
#define kDKSteetCellDefaultMapIndexFont kDKSteetCellDefaultSubTitleFont

#define kDKSteetCellDefaultTitleFontSize 18.0f
#define kDKSteetCellDefaultSubTitleFontSize 12.0f
#define kDKSteetCellDefaultMapIndexFontSize kDKSteetCellDefaultSubTitleFontSize

@implementation DKStreetCell

@synthesize mapIndexLabel = _mapIndexLabel;

- (id)initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    
    if (self) {
        // Initialization code
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.font = [UIFont fontWithName: kDKSteetCellDefaultTitleFont
                                              size: kDKSteetCellDefaultTitleFontSize];
        
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.textColor = [UIColor darkGrayColor];
        
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        self.detailTextLabel.font = [UIFont fontWithName: kDKSteetCellDefaultSubTitleFont
                                                    size: kDKSteetCellDefaultSubTitleFontSize];
        
        self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.textColor = [UIColor grayColor];
        
        self.mapIndexLabel = [[UILabel alloc] init];
        
        self.mapIndexLabel.backgroundColor = [UIColor clearColor];
        self.mapIndexLabel.textAlignment = NSTextAlignmentRight;
        self.mapIndexLabel.textColor = [UIColor grayColor];
        self.mapIndexLabel.font = [UIFont fontWithName: kDKSteetCellDefaultMapIndexFont
                                                  size: kDKSteetCellDefaultMapIndexFontSize];
        
        [self.contentView addSubview: self.mapIndexLabel];        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x,
                                            self.frame.size.height - self.detailTextLabel.frame.size.height - kDKStreetCellDefaultBottomBorderSize,
                                            self.detailTextLabel.frame.size.width,
                                            self.detailTextLabel.frame.size.height);
    
    self.mapIndexLabel.frame = CGRectMake(self.frame.size.width - kDKStreetCellDefaultWidth - kDKStreetCellDefaultRightBorderSize,
                                          self.frame.size.height - self.detailTextLabel.frame.size.height - kDKStreetCellDefaultBottomBorderSize,
                                          kDKStreetCellDefaultWidth,
                                          self.detailTextLabel.frame.size.height);
}

@end
