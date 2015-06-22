//
//  DDChildCell.m
//  Yelp
//
//  Created by Carter Chang on 6/22/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "DDChildCell.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation DDChildCell


-(IBAction) addMark {
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    //[factory setColors:@[ UIColorFromRGB(0xd4d4d4)]];
    [factory setColors:@[ UIColorFromRGB(0x007aff)]];
    UIImage *markIcon = [factory createImageForIcon:NIKFontAwesomeIconCheckCircleO];
    self.markIcon.image = markIcon;
    
}
- (void)awakeFromNib {
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    
    [factory setColors:@[ UIColorFromRGB(0xd4d4d4)]];

    UIImage *markIcon = [factory createImageForIcon:NIKFontAwesomeIconCheckCircleO];
    self.markIcon.image = markIcon;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
