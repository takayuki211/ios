//
//  ViewController.h
//  ble_test
//
//  Created by Takayuki on 2015/09/27.
//  Copyright (c) 2015年 Takayuki Yamamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)scanButton:(id)sender;
- (IBAction)stopButton:(id)sender;

- (IBAction)sendHigh:(id)sender;
- (IBAction)sendLow:(id)sender;

@end

