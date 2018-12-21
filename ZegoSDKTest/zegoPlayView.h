//
//  zegoPlayView.h
//  ZegoSDKTest
//
//  Created by hengKing on 2018/11/29.
//  Copyright © 2018年 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol zegoPlayViewDelegate <NSObject>
- (void)closeBtnClick;
@end

@interface zegoPlayView : UIView

@property (weak, nonatomic) IBOutlet UILabel *fpsLable;
@property (weak, nonatomic) IBOutlet UILabel *kbpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *akbpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rttLabel;
@property (weak, nonatomic) IBOutlet UILabel *pktLostRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (nonatomic, weak) NSObject<zegoPlayViewDelegate> *delegate;

@end

NS_ASSUME_NONNULL_END
