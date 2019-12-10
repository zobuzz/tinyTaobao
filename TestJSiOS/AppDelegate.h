//
//  AppDelegate.h
//  TestJSiOS
//
//  Created by Xingwei Zhu on 2019/12/4.
//  Copyright © 2019 Xingwei Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface View : UIView
{
    CADisplayLink* m_displayLink;
}

- (void)start;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) View* m_view;

@end

