//
//  AppDelegate.m
//  TestJSiOS
//
//  Created by Xingwei Zhu on 2019/12/4.
//  Copyright © 2019 Xingwei Zhu. All rights reserved.
//

#import "AppDelegate.h"
//#include "bgfx.h"
//#include "platform.h"
#include "ViewController.h"

#ifdef HAS_METAL_SDK
static    id<MTLDevice>  m_device = NULL;
#else
static    void* m_device = NULL;
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    CGRect rect = [ [UIScreen mainScreen] bounds];
    _window = [ [UIWindow alloc] initWithFrame: rect];
    _m_view = [ [View alloc] initWithFrame: rect];
    
    [_window addSubview: _m_view];
    
    UIViewController *viewController = [[ViewController alloc] init];
    viewController.view = _m_view;
    
    [_window setRootViewController:viewController];
    [_window makeKeyAndVisible];
    
    [viewController viewDidLoad];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [_m_view start];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end


@implementation View

+ (Class)layerClass
{
#ifdef HAS_METAL_SDK
    Class metalClass = NSClassFromString(@"CAMetalLayer");    //is metal runtime sdk available
    if ( metalClass != nil)
    {
        m_device = MTLCreateSystemDefaultDevice(); // is metal supported on this device (is there a better way to do this - without creating device ?)
        if (m_device)
        {
            [m_device retain];
            return metalClass;
        }
    }
#endif
    
    return [CAEAGLLayer class];
}


- (void) start
{
    printf("start");
    if (nil == m_displayLink)
    {
        m_displayLink = [self.window.screen displayLinkWithTarget:self selector:@selector(renderFrame)];
        [m_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void) renderFrame
{
    printf("tick render frame");
    [ViewController requestAnimationFrame];
}

- (id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect];
    
    if (nil == self)
    {
        return nil;
    }
    
    
    //remove bgfx
    /*
    bgfx::PlatformData pd;
    pd.ndt          = NULL;
    pd.nwh          = (void*)CFBridgingRetain(self.layer);
    pd.context      = m_device;
    pd.backBuffer   = NULL;
    pd.backBufferDS = NULL;
    
    bgfx::setPlatformData(pd);*/
    
    return self;
}

@end
