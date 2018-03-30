#define kBundlePath @"/Library/Application Support/AVLockBundle.bundle"


@interface SBOrientationLockManager
+(SBOrientationLockManager *)sharedInstance;
-(bool)isUserLocked;
-(void)lock;
-(void)unlock;
-(void)myIsUserLocked;
@end



@interface AVTransportControlsView : UIView
-(void)deviceOrientationDidChange;
//@property (assign, nonatomic) AVButton *skipBackButton;
@end

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

static UIButton *button = nil;
static NSString *myObserver=@"anObserver";
static void toggle(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){

    if([[%c(SBOrientationLockManager) sharedInstance] isUserLocked]){
        [[%c(SBOrientationLockManager) sharedInstance] unlock];
    }else{
        [[%c(SBOrientationLockManager) sharedInstance] lock];
    }
}
static void lockButton(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];
    NSString *imagePath = [bundle pathForResource:@"Locked@3x" ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateHighlighted];
    [button setImage:img forState:UIControlStateSelected];

}
static void unlockButton(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];
    NSString *imagePath = [bundle pathForResource:@"Unlocked@3x" ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateHighlighted];
    [button setImage:img forState:UIControlStateSelected];

}
static void firstUpdate(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    [[%c(SBOrientationLockManager) sharedInstance] myIsUserLocked];

}


%hook SBOrientationLockManager
-(SBOrientationLockManager*)init{
	self = %orig;
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (void*)myObserver,
                                    toggle,
                                    CFSTR("avlock.toggle"),
                                    NULL,  
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (void*)myObserver,
                                    firstUpdate,
                                    CFSTR("avlock.firstUpdate"),
                                    NULL,  
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

  return self;
}
%new
-(void)myIsUserLocked{
    bool locked = [self isUserLocked];
    if(locked){
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("avlock.lockButton"), (void*)myObserver, NULL, true);
    }else{
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("avlock.unlockButton"), (void*)myObserver, NULL, true);
    }
}
-(void)unlock{
    %orig;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("avlock.unlockButton"), (void*)myObserver, NULL, true);
}
-(void)lock{
    %orig;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("avlock.lockButton"), (void*)myObserver, NULL, true);
}

%end




%hook AVTransportControlsView
-(AVTransportControlsView *)initWithFrame:(CGRect)frame{
    AVTransportControlsView *origself = %orig(frame);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									(void*)myObserver,
									lockButton,
									CFSTR("avlock.lockButton"),
									NULL,  
									CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									(void*)myObserver,
									unlockButton,
									CFSTR("avlock.unlockButton"),
									NULL,  
									CFNotificationSuspensionBehaviorDeliverImmediately);
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button addTarget:self action:@selector(orientationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("avlock.firstUpdate"), (void*)myObserver, NULL, true);
	button.contentMode = UIViewContentModeScaleAspectFit;

	UIInterfaceOrientation orientation =[UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
		button.frame = CGRectMake(6.5, -40, 46, 46);
	}
	else if(orientation == UIInterfaceOrientationPortrait){
		button.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width / 2) - 142.5, 43, 46, 46);
	}
	button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);

	[self addSubview:button];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	
	return origself;
}



-(void)dealloc{
    %orig;
    CFNotificationCenterRemoveObserver ( CFNotificationCenterGetDarwinNotifyCenter(), (void*)myObserver, NULL, NULL); 
}

%new
-(void)deviceOrientationDidChange{
	UIInterfaceOrientation orientation =[UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
		button.frame = CGRectMake(6.5, -40, 46, 46);
	}
	else if(orientation == UIInterfaceOrientationPortrait){
		button.frame = CGRectMake((self.frame.size.width / 2) - 115.5, 43, 46, 46);
	}
}

%new
-(void)orientationButtonPressed{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("avlock.toggle"), (void*)myObserver, NULL, true);

}

%end
