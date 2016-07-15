//
//  NewMultipleTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/7/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewMultipleTweetCell.h"
#import <AsyncDisplayKit.h>
#import <Masonry.h>

@interface NewMultipleTweetCell (){
    NSMutableArray* _imageViewsArray;   //二维数组
}
@end

@implementation NewMultipleTweetCell{
    __weak ASImageNode* _userPortrait;
    __weak ASTextNode* _nameLabel;
    __weak ASTextNode* _descTextView;
    
    __weak ASDisplayNode* _imagesView;
    
    __weak ASTextNode* _timeLabel;
    __weak ASTextNode* _likeCountLabel;
    __weak ASImageNode* _commentImage;
    __weak ASTextNode* _commentCountLabel;
    
    __weak ASDisplayNode* _colorLine;
}

+(instancetype)returnReuseMultipeTweetCellWithTableView:(UITableView *)tableView
                                             identifier:(NSString *)reuseIdentifier
                                              indexPath:(NSIndexPath *)indexPath
{
    NewMultipleTweetCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NewMultipleTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSubViews];
        [self setLayout];
    }
    return self;
}


#pragma mark - 
#pragma mark --- set SubViews
-(void)setSubViews{
    ASImageNode* userPortrait = [[ASImageNode alloc]init];
    _userPortrait = userPortrait;
    [self.contentView addSubview:_userPortrait.view];
    
    ASTextNode* nameLabel = [[ASTextNode alloc]init];
    _nameLabel = nameLabel;
    [self.contentView addSubview:_nameLabel.view];
    
    ASTextNode* descTextView = [[ASTextNode alloc]init];
    _descTextView = descTextView;
    [self.contentView addSubview:_descTextView.view];

    ASDisplayNode* imagesView = [[ASDisplayNode alloc]init];
    _imagesView = imagesView;
    [self.contentView addSubview:_imagesView.view];
    
    ASTextNode* timeLabel = [[ASTextNode alloc]init];
    _timeLabel = timeLabel;
    [self.contentView addSubview:_timeLabel.view];
    
    UIButton* likeCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeCountButton setImageEdgeInsets:UIEdgeInsetsMake(0, 25, 2, 0)];
    _likeCountButton = likeCountButton;
    [self.contentView addSubview:_likeCountButton];
    
    ASTextNode* likeCountLabel = [[ASTextNode alloc]init];
    _likeCountLabel = likeCountLabel;
    [self.contentView addSubview:_likeCountLabel.view];
    
    ASImageNode* commentImage = [[ASImageNode alloc]init];
    commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    _commentImage = commentImage;
    [self.contentView addSubview:_commentImage.view];
    
    ASTextNode* commentCountLabel = [[ASTextNode alloc]init];
    _commentCountLabel = commentCountLabel;
    [self.contentView addSubview:_commentCountLabel.view];
    
    ASDisplayNode* colorLine = [[ASDisplayNode alloc]init];
    colorLine.backgroundColor = [UIColor grayColor];
    _colorLine = colorLine;
    [self.contentView addSubview:_colorLine.view];
    
    [self addMultiples];
}



#pragma mark --- set Layout （ Masnory ）
-(void)setLayout{
    [_userPortrait.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@45);
    }];
    
    [_nameLabel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(16);
        make.left.equalTo(_userPortrait.view.mas_right).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_descTextView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_nameLabel.view.mas_bottom).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-8);
    }];
    
    [_imagesView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_descTextView.view.mas_bottom).with.offset(8);
        make.width.equalTo(@212);
        make.height.equalTo(@212);
    }];
    
    [_timeLabel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(69);
        make.top.equalTo(_imagesView.view.mas_bottom).with.offset(3);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentCountLabel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentImage.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(_commentCountLabel.view.mas_left).with.offset(-5);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_likeCountLabel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentImage.view.mas_left).with.offset(-16);
    }];
    
    [_likeCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_likeCountLabel.view.mas_left).with.offset(-5);
    }];
    
    [_colorLine.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.bottom.and.right.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
}



#pragma mark --- Using a for loop
-(void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0 ; i < 3; i++) {//line
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            ASImageNode* imageView = [[ASImageNode alloc]init];
            [_imagesView addSubnode:imageView];
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
}
@end
