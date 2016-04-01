//
//  ChatListCell.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import "ChatListCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <FrameAccessor/FrameAccessor.h>
#import <DateTools/NSDate+DateTools.h>

@implementation ChatListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChatInfo:(NSDictionary*)info {
    _info = info;
    
//    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info[@"profile_url"]] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.imageView.image = image;
//        self.imageView.layer.cornerRadius = self.imageView.width/2;
//        [self setNeedsDisplay];
//    }];
    
    self.profileImage.layer.cornerRadius = self.profileImage.width/2;
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:info[@"profile_url"]] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.imageView.image = image;
//        [self setNeedsDisplay];
        
    }];
    
    [self.topLabel setText:info[@"name"]];
    [self.bodyLabel setText:info[@"last_message"]];
    
    self.dotView.layer.cornerRadius = self.dotView.width/2;
    [self.dotView setHidden:![info[@"unread"] boolValue]];
    
    if([info[@"urgent"] boolValue]) {
        UIColor *redColor = [UIColor colorWithRed:231/255.0 green:43/255.0 blue:45/255.0 alpha:1.0];
        [self.dotView setBackgroundColor:redColor];
        [self.timeLabel setTextColor:redColor];
    } else {
        UIColor *blueColor = [UIColor colorWithRed:33/255.0 green:129/255.0 blue:246/255.0 alpha:1.0];
        [self.dotView setBackgroundColor:blueColor];
        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
    }
    
    
    if(info[@"timestamp"] != [NSNull null]) {
        NSDate *date = info[@"timestamp"];
        NSLog(@"%@", [date shortTimeAgoSinceNow]);
        [self.timeLabel setText:[date shortTimeAgoSinceNow]];
    }
}


@end
