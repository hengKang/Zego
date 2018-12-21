//
//  zegoPlayView.m
//  ZegoSDKTest
//
//  Created by hengKing on 2018/11/29.
//  Copyright © 2018年 zego. All rights reserved.
//

#import "zegoPlayView.h"

@interface zegoPlayView ()

/*
 @property (weak, nonatomic) IBOutlet UILabel *fpsLable;
 @property (weak, nonatomic) IBOutlet UILabel *kbpsLabel;
 @property (weak, nonatomic) IBOutlet UILabel *akbpsLabel;
 @property (weak, nonatomic) IBOutlet UILabel *rttLabel;
 @property (weak, nonatomic) IBOutlet UILabel *pktLostRateLabel;
 @property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
 @property (weak, nonatomic) IBOutlet UIButton *requestJoinBtn;
 */
@end

@implementation zegoPlayView

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (IBAction)closePlayView:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeBtnClick)]) {
        [self.delegate closeBtnClick];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
