//
//  ChatListCell.h
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *topLabel, *bodyLabel, *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profileImage, *arrowImage;
@property (nonatomic, retain) IBOutlet UIView *dotView;

@property (nonatomic, retain) NSDictionary *info;

- (void)setChatInfo:(NSDictionary*)info;

@end
