#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/AVLockBundle.bundle"


@interface SBOrientationLockManager
+(SBOrientationLockManager *)sharedInstance;
-(bool)isUserLocked;
-(void)lock;
-(void)unlock;
@end

@interface AVTransportControlsView
-(void)addSubview:(id)arg1;
@property CGRect frame;
@end

static bool firstrun = true;

%hook AVTransportControlsView
-(void)layoutSubviews{
%orig;
if(firstrun){
 UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
 [button addTarget:self action:@selector(orientationButtonPressed)
 forControlEvents:UIControlEventTouchUpInside];
 
       NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
       NSString *imagePath = [bundle pathForResource:@"Test" ofType:@"png"];
       UIImage *img = [UIImage imageWithContentsOfFile:imagePath];

 [button setImage:img forState:UIControlStateNormal];
 [button setImage:img forState:UIControlStateHighlighted];
 [button setImage:img forState:UIControlStateSelected];
 button.contentMode = UIViewContentModeScaleToFill;
 button.frame = CGRectMake(0, 0, img.size.width, img.size.height);
 [self addSubview:button];
 firstrun = false;
}
}

-(void)dealloc{
%orig;
firstrun = true;
}

%new
-(void)orientationButtonPressed{
  if([[%c(SBOrientationLockManager) sharedInstance] isUserLocked]){
[[%c(SBOrientationLockManager) sharedInstance] unlock];
}else{
[[%c(SBOrientationLockManager) sharedInstance] lock];
}
}

%end