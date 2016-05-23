//
//  QuesAnsCell.h
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCPost.h"

@interface QuesAnsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *quesImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *watchCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

- (void)setcontentForQuestionsAns:(OSCPost *)post;

@end
