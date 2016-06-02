//
//  NewCommentCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewCommentCell.h"
#import "Utils.h"

@implementation NewCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setLayOutForSubView];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setLayOutForSubView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLayOutForSubView
{
    _commentPortrait = [UIImageView new];
    _commentPortrait.layer.cornerRadius = 16;
    _commentPortrait.clipsToBounds = YES;
    _commentPortrait.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:_commentPortrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = [UIColor colorWithHex:0x111111];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    [self.contentView addSubview:_timeLabel];
    
    _conentLabel = [UILabel new];
    _conentLabel.font = [UIFont systemFontOfSize:14];
    _conentLabel.textColor = [UIColor colorWithHex:0x111111];
    _conentLabel.numberOfLines = 0;
    _conentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_conentLabel];
    
    _nameLabel.text = @"梦想岛";
    _timeLabel.text = @"12楼  6分钟前";
    _conentLabel.text = @"@诺灬晓月 你好，想跟你请教个问题：就是你用Echart做的甘特图，那个矩形的颜色是怎么设置，能不能显示进度条啊";
    
    _commentButton = [UIButton new];
    [_commentButton setImage:[UIImage imageNamed:@"ic_comment"] forState:UIControlStateNormal];
    [self.contentView addSubview:_commentButton];
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_commentPortrait, _nameLabel, _timeLabel, _conentLabel, _commentButton);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_commentPortrait(32)]-7-[_conentLabel]-16-|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_nameLabel]-2-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]-7-[_conentLabel]-16-|"
                                                                             options:0
                                                                             metrics:nil views:views]];
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_commentButton(20)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[_commentPortrait(32)]-8-[_nameLabel]-8-[_commentButton(30)]-10-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[_conentLabel]-16-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self setLayOutForRefer];
}

#pragma mark - contentData

- (void)setComment:(OSCBlogDetailComment *)comment
{
    [_commentPortrait loadPortrait:[NSURL URLWithString:comment.authorPortrait]];
    _nameLabel.text = comment.author;
    _timeLabel.text = [[NSDate dateFromString:comment.pubDate] timeAgoSinceNow];
    _conentLabel.text = comment.content;
}

#pragma mark - refer
- (void)setLayOutForRefer
{
    CommentSuperView *commentSuperView = [CommentSuperView new];
    [self.contentView addSubview:commentSuperView];
    
    commentSuperView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_nameLabel, _timeLabel, commentSuperView, _conentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_nameLabel]-2-[_timeLabel]-7-[commentSuperView]-7-[_conentLabel]"
                                                                             options:0
                                                                             metrics:nil views:views]];
    
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[commentSuperView]-16-|"
//                                                                             options:0
//                                                                             metrics:nil
//                                                                               views:views]];
    
    commentSuperView.nameLabel.text = @"贾婷Juno：";
    commentSuperView.contentLabel.text = @"你可真能写啊";
}

@end

@implementation CommentSuperView

- (id)init{
    self = [super init];
    if (self) {
        [self layoutForSuperComment];
    }
    return self;
}

- (void)layoutForSuperComment
{
    _nameLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    [self addSubview:_nameLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_contentLabel];
    
    UIView *leftLine = [UIView new];
    leftLine.backgroundColor = [UIColor colorWithHex:0xd7d6da];
    [self addSubview:leftLine];
    
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor colorWithHex:0xd7d6da];
    [self addSubview:bottomLine];
    
    for (UIView *view in self.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_nameLabel, _contentLabel, leftLine, bottomLine);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLine]|"
                                                                             options:0
                                                                             metrics:nil
                                                                   views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_nameLabel]-2-[_contentLabel]-5-[bottomLine(1)]|"
                                                                 options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                 metrics:nil
                                                                   views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftLine(1)]-8-[_nameLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

@end
