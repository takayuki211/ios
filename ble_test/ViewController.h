//
//  ViewController.h
//  ble_test
//
//  Created by Takayuki on 2015/09/27.
//  Copyright (c) 2015年 Takayuki Yamamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// BLE接続
- (IBAction)scanButton:(id)sender;
- (IBAction)stopButton:(id)sender;

// LED点灯(13Pin入出力)
- (IBAction)sendHigh:(id)sender;
- (IBAction)sendLow:(id)sender;

// モーター制御
- (IBAction)forward:(id)sender;
- (IBAction)Back:(id)sender;
- (IBAction)Left:(id)sender;
- (IBAction)Right:(id)sender;
- (IBAction)Stop:(id)sender;

@end

