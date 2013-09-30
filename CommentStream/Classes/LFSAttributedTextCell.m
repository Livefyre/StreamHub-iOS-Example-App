//
//  LFAttributedTextCell.m
//  CommentStream
//
//  Created by Eugene Scherba on 8/14/13.
//  Copyright (c) 2013 Livefyre. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <StreamHub-iOS-SDK/LFSConstants.h>
#import "LFSBasicHTMLParser.h"
#import "LFSAttributedTextCell.h"
#import "UILabel+Trim.h"

// TODO: turn some of these consts into properties for easier customization
//static const CGFloat kLeftColumnWidth = 50.f;

static const UIEdgeInsets kPadding = {
    .top=7.f, .left=15.f, .bottom=18.f, .right=12.f
};

static const CGFloat kContentPaddingRight = 7.f;
static const CGFloat kContentLineSpacing = 6.5f;

static const CGFloat kHeaderAcessoryRightWidth = 68.f;
static const CGFloat kHeaderAcessoryRightHeight = 21.f;

// title font settings
static const CGFloat kHeaderSubtitleFontSize = 11.f; // not used yet
static const CGFloat kHeaderAttributeTopFontSize = 10.f; // not used yet

static const CGSize  kImageViewSize = { .width=25.f, .height=25.f };
static const CGFloat kImageCornerRadius = 4.f;
static const CGFloat kImageMarginRight = 8.0f;

static const CGFloat kMinorVerticalSeparator = 5.0f;
static const CGFloat kMajorVerticalSeparator = 7.0f;

static const CGFloat kHeaderAttributeTopHeight = 10.0f;
static const CGFloat kHeaderTitleHeight = 18.0f;
static const CGFloat kHeaderSubtitleHeight = 10.0f;

@interface LFSAttributedTextCell ()
// store hash to avoid relayout of same HTML
@property (nonatomic, assign) NSUInteger htmlHash;

@property (readonly, nonatomic) UILabel *headerAttributeTopView;
@property (readonly, nonatomic) UILabel *headerTitleView;
@property (readonly, nonatomic) UILabel *headerSubtitleView;

@property (nonatomic, readonly) LFSBasicHTMLLabel *bodyView;
@property (nonatomic, readonly) UILabel *headerAccessoryRightView;
@end

@implementation LFSAttributedTextCell

#pragma mark - UIAppearance properties
@synthesize backgroundCellColor;
-(UIColor*)backgroundCellColor
{
    return self.backgroundColor;
}
-(void)setBackgroundCellColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
}

#pragma mark -
@synthesize headerTitleFont = _headerTitleFont;
-(UIFont*)headerTitleFont {
    return self.headerTitleView.font;
}
-(void)setHeaderTitleFont:(UIFont *)headerTitleFont {
    self.headerTitleView.font = headerTitleFont;
}

#pragma mark -
@synthesize headerTitleColor = _headerTitleColor;
-(UIColor*)headerTitleColor {
    return self.headerTitleView.textColor;
}
-(void)setHeaderTitleColor:(UIColor *)headerTitlecolor {
    self.headerTitleView.textColor = headerTitlecolor;
}

#pragma mark -
@synthesize bodyFont = _bodyFont;
-(UIFont*)bodyFont {
    return self.bodyView.font;
}
-(void)setBodyFont:(UIFont *)contentBodyFont {
    self.bodyView.font = contentBodyFont;
}

#pragma mark -
@synthesize bodyColor = _bodyColor;
-(UIColor*)bodyColor {
    return self.bodyView.textColor;
}
-(void)setBodyColor:(UIColor *)contentBodyColor {
    self.bodyView.textColor = contentBodyColor;
}

#pragma mark -
@synthesize headerAccessoryRightFont = _headerAccessoryRightFont;
-(UIFont*)headerAccessoryRightFont {
    return self.headerAccessoryRightView.font;
}
-(void)setHeaderAccessoryRightFont:(UIFont *)headerAccessoryRightFont {
    self.headerAccessoryRightView.font = headerAccessoryRightFont;
}

#pragma mark -
@synthesize headerAccessoryRightColor = _headerAccessoryRightColor;
-(UIColor*)headerAccessoryRightColor {
    return self.headerAccessoryRightView.textColor;
}
-(void)setHeaderAccessoryRightColor:(UIColor *)headerAccessoryRightColor {
    self.headerAccessoryRightView.textColor = headerAccessoryRightColor;
}

#pragma mark - Other properties
@synthesize htmlHash = _htmlHash;
@synthesize headerAccessoryRightText = _headerAccessoryRightText;

#pragma mark -
@synthesize headerImage = _headerImage;
- (void)setHeaderImage:(UIImage*)image
{
    // store original-size image
    _headerImage = image;
    
    // we are on a non-Retina device
    UIScreen *screen = [UIScreen mainScreen];
    CGSize size;
    if ([screen respondsToSelector:@selector(scale)] && [screen scale] == 2.f)
    {
        // Retina: scale to 2x frame size
        size = CGSizeMake(kImageViewSize.width * 2.f,
                          kImageViewSize.height * 2.f);
    }
    else
    {
        // non-Retina
        size = kImageViewSize;
    }
    CGRect targetRect = CGRectMake(0.f, 0.f, size.width, size.height);
    dispatch_queue_t queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0.f);
    dispatch_async(queue, ^{
        
        // scale image on a background thread
        // Note: this will not preserve aspect ratio
        UIGraphicsBeginImageContext(size);
        [image drawInRect:targetRect];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // display image on the main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imageView.image = scaledImage;
            [self setNeedsLayout];
        });
    });
}

#pragma mark -
@synthesize bodyView = _bodyView;
-(LFSBasicHTMLLabel*)bodyView
{
	if (_bodyView == nil) {
        const CGFloat kHeaderHeight = kPadding.top + kImageViewSize.height + kMinorVerticalSeparator;
        CGRect frame = CGRectMake(kPadding.left,
                                  kHeaderHeight,
                                  self.bounds.size.width - kPadding.left - kContentPaddingRight,
                                  self.bounds.size.height - kHeaderHeight);
        
        // initialize
        _bodyView = [[LFSBasicHTMLLabel alloc] initWithFrame:frame];
        
        // configure
        [_bodyView setFont:[UIFont fontWithName:@"Georgia" size:13.f]];
        [_bodyView setTextColor:[UIColor blackColor]];
        [_bodyView setBackgroundColor:[UIColor clearColor]]; // for iOS6
        [_bodyView setLineSpacing:kContentLineSpacing];
        
        // add to superview
		[self.contentView addSubview:_bodyView];
	}
	return _bodyView;
}

#pragma mark -
@synthesize headerAttributeTopView = _headerAttributeTopView;
- (UILabel*)headerAttributeTopView
{
    if (_headerAttributeTopView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - kPadding.right, kHeaderAttributeTopHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kPadding.top); // size.y will be changed in layoutSubviews
        // initialize
        _headerAttributeTopView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerAttributeTopView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerAttributeTopView setFont:[UIFont systemFontOfSize:kHeaderAttributeTopFontSize]];
        [_headerAttributeTopView setTextColor:[UIColor blueColor]];
        
        // add to superview
        [self.contentView addSubview:_headerAttributeTopView];
    }
    return _headerAttributeTopView;
}

#pragma mark -
@synthesize headerTitleView = _headerTitleView;
- (UILabel *)headerTitleView
{
	if (_headerTitleView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGFloat rightColumnWidth = kHeaderAcessoryRightWidth + kPadding.right;
        
        CGRect frame;
        frame.size = CGSizeMake(self.bounds.size.width - leftColumnWidth - rightColumnWidth, kHeaderTitleHeight);
        frame.origin = CGPointMake(leftColumnWidth, kPadding.top);
        
        // initialize
        _headerTitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerTitleView setFont:[UIFont boldSystemFontOfSize:12.f]];
        [_headerTitleView setTextColor:[UIColor blackColor]];
        [_headerTitleView setBackgroundColor:[UIColor clearColor]]; // for iOS6
        
        // add to superview
		[self.contentView addSubview:_headerTitleView];
	}
	return _headerTitleView;
}

#pragma mark -
@synthesize headerSubtitleView = _headerSubtitleView;
- (UILabel*)headerSubtitleView
{
    if (_headerSubtitleView == nil) {
        CGFloat leftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
        CGSize labelSize = CGSizeMake(self.bounds.size.width - leftColumnWidth - kPadding.right, kHeaderSubtitleHeight);
        CGRect frame;
        frame.size = labelSize;
        frame.origin = CGPointMake(leftColumnWidth,
                                   kPadding.top); // size.y will be changed in layoutSubviews
        // initialize
        _headerSubtitleView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerSubtitleView
         setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
        [_headerSubtitleView setFont:[UIFont systemFontOfSize:kHeaderSubtitleFontSize]];
        [_headerSubtitleView setTextColor:[UIColor grayColor]];
        
        // add to superview
        [self.contentView addSubview:_headerSubtitleView];
    }
    return _headerSubtitleView;
}

#pragma mark -
@synthesize headerAccessoryRightView = _headerAccessoryRightView;
- (UILabel *)headerAccessoryRightView
{
	if (_headerAccessoryRightView == nil) {
        CGRect frame;
        frame.size = CGSizeMake(kHeaderAcessoryRightWidth, kHeaderAcessoryRightHeight);
        frame.origin = CGPointMake(self.bounds.size.width - kHeaderAcessoryRightWidth - kPadding.right, kPadding.top);
        
        // initialize
        _headerAccessoryRightView = [[UILabel alloc] initWithFrame:frame];
        
        // configure
        [_headerAccessoryRightView setFont:[UIFont systemFontOfSize:11.f]];
        [_headerAccessoryRightView setTextColor:[UIColor lightGrayColor]];
        [_headerAccessoryRightView setTextAlignment:NSTextAlignmentRight];
        
        // add to superview
		[self.contentView addSubview:_headerAccessoryRightView];
	}
	return _headerAccessoryRightView;
}

#pragma mark - Lifecycle
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // initialize subview references
        _bodyView = nil;
        _headerAccessoryRightView = nil;
        _headerImage = nil;
        _headerTitleView = nil;
        
        [self setAccessoryType:UITableViewCellAccessoryNone];

        if (LFS_SYSTEM_VERSION_LESS_THAN(LFSSystemVersion70))
        {
            // iOS7-like selected background color
            [self setSelectionStyle:UITableViewCellSelectionStyleGray];
            UIView *selectionColor = [[UIView alloc] init];
            selectionColor.backgroundColor = [UIColor colorWithRed:(217.f/255.f)
                                                             green:(217.f/255.f)
                                                              blue:(217.f/255.f)
                                                             alpha:1.f];
            self.selectedBackgroundView = selectionColor;
        }
        
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
        self.imageView.layer.cornerRadius = kImageCornerRadius;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

-(void)dealloc{
    _bodyView = nil;
    _headerTitleView = nil;
    _headerAccessoryRightView = nil;
    _headerImage = nil;
}

#pragma mark - Overrides

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!self.superview) {
		return;
	}
    
    // layout content view
    CGFloat width = self.bounds.size.width;
    CGRect textContentFrame = self.bodyView.frame;
    textContentFrame.size = [self.bodyView
                             sizeThatFits:
                             CGSizeMake(width - kPadding.left - kContentPaddingRight,
                                        CGFLOAT_MAX)];
    [self.bodyView setFrame:textContentFrame];
    
    const CGFloat kLeftColumnWidth = kPadding.left + kImageViewSize.width + kImageMarginRight;
    const CGFloat kRightColumnWidth = kHeaderAcessoryRightWidth + kPadding.right;
    
    // start with the header
    [self layoutHeader];
    
    // layout title view
    CGRect titleFrame = self.headerTitleView.frame;
    titleFrame.size.width = width - kLeftColumnWidth - kRightColumnWidth;
    [self.headerTitleView setFrame:titleFrame];
    
    // layout note view
    CGRect accessoryRightFrame = self.headerAccessoryRightView.frame;
    accessoryRightFrame.origin.x = width - kRightColumnWidth;
    [self.headerAccessoryRightView setFrame:accessoryRightFrame];
    [self.headerAccessoryRightView setText:_headerAccessoryRightText];
    
     // layout avatar
    CGRect imageViewFrame;
    imageViewFrame.origin = CGPointMake(kPadding.left, kPadding.top);
    imageViewFrame.size = kImageViewSize;
    self.imageView.frame = imageViewFrame;
}

#pragma mark - Private methods
-(void)layoutHeader
{
    // layout header title label
    //
    // Note: preciese layout depends on whether we have subtitle field
    // (i.e. twitter handle)
    
    LFSHeader *profileLocal = self.profileLocal;
    NSString *headerTitle = profileLocal.mainString;
    NSString *headerSubtitle = profileLocal.detailString;
    NSString *headerAccessory = profileLocal.attributeString;
    
    if (headerTitle && !headerSubtitle && !headerAccessory)
    {
        // display one string
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && headerSubtitle && !headerAccessory)
    {
        // full name + twitter handle
        
        CGRect headerTitleFrame = self.headerTitleView.frame;
        CGRect headerSubtitleFrame = self.headerSubtitleView.frame;
        
        CGFloat separator = floorf((kImageViewSize.height
                                    - headerTitleFrame.size.height
                                    - headerSubtitleFrame.size.height) / 3.f);
        
        headerTitleFrame.origin.y = kPadding.top + separator;
        headerSubtitleFrame.origin.y = (kPadding.top
                                        + separator
                                        + headerTitleFrame.size.height
                                        + separator);
        
        [self.headerTitleView setFrame:headerTitleFrame];
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
        
        [self.headerSubtitleView setFrame:headerSubtitleFrame];
        [self.headerSubtitleView setText:headerSubtitle];
        [self.headerSubtitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && !headerSubtitle && headerAccessory)
    {
        // attribute + full name
        
        CGRect headerAttributeTopFrame = self.headerAttributeTopView.frame;
        CGRect headerTitleFrame = self.headerTitleView.frame;
        
        CGFloat separator = floorf((kImageViewSize.height
                                    - headerTitleFrame.size.height
                                    - headerAttributeTopFrame.size.height) / 3.f);
        
        
        headerAttributeTopFrame.origin.y = (kPadding.top + separator);
        headerTitleFrame.origin.y = (kPadding.top
                                     + separator
                                     + headerAttributeTopFrame.size.height
                                     + separator);
        
        [self.headerAttributeTopView setFrame:headerAttributeTopFrame];
        [self.headerAttributeTopView setText:headerAccessory];
        [self.headerAttributeTopView resizeVerticalCenterRightTrim];
        
        [self.headerTitleView setFrame:headerTitleFrame];
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
    }
    else if (headerTitle && headerSubtitle && headerAccessory)
    {
        // attribute + full name + twitter handle
        
        CGRect headerAttributeTopFrame = self.headerAttributeTopView.frame;
        CGRect headerTitleFrame = self.headerTitleView.frame;
        CGRect headerSubtitleFrame = self.headerSubtitleView.frame;
        
        CGFloat separator = floorf((kImageViewSize.height
                                    - headerTitleFrame.size.height
                                    - headerAttributeTopFrame.size.height
                                    - headerSubtitleFrame.size.height) / 4.f);
        
        
        headerAttributeTopFrame.origin.y = (kPadding.top + separator);
        headerTitleFrame.origin.y = (kPadding.top
                                     + separator
                                     + headerAttributeTopFrame.size.height
                                     + separator);
        
        headerSubtitleFrame.origin.y = (kPadding.top
                                        + separator
                                        + headerAttributeTopFrame.size.height
                                        + separator
                                        + headerTitleFrame.size.height
                                        + separator);
        
        [self.headerAttributeTopView setFrame:headerAttributeTopFrame];
        [self.headerAttributeTopView setText:headerAccessory];
        [self.headerAttributeTopView resizeVerticalCenterRightTrim];
        
        [self.headerTitleView setFrame:headerTitleFrame];
        [self.headerTitleView setText:headerTitle];
        [self.headerTitleView resizeVerticalCenterRightTrim];
        
        [self.headerSubtitleView setFrame:headerSubtitleFrame];
        [self.headerSubtitleView setText:headerSubtitle];
        [self.headerSubtitleView resizeVerticalCenterRightTrim];
    }
    else {
        // no header
    }
    
    // layout avatar view
    //[self.imageView setImage:profileLocal.iconImage];
    
}

#pragma mark - Public methods
- (void)setHTMLString:(NSString *)html
{
	// store hash isntead of HTML source
	NSUInteger newHash = [html hash];
    
	if (newHash == _htmlHash) {
		return;
	}
	
	_htmlHash = newHash;
	[self.bodyView setHTMLString:html];
	[self setNeedsLayout];
}

- (CGFloat)requiredRowHeightWithFrameWidth:(CGFloat)width
{
    CGSize neededSize = [self.bodyView
                         sizeThatFits:
                         CGSizeMake(width - kPadding.left - kContentPaddingRight,
                                    CGFLOAT_MAX)];
    
    CGRect imageViewFrame = self.imageView.frame;
    const CGFloat kHeaderHeight = kPadding.top + kImageViewSize.height + kMinorVerticalSeparator;
	CGFloat result = kPadding.bottom + MAX(neededSize.height + kHeaderHeight,
                              imageViewFrame.size.height +
                              imageViewFrame.origin.y);
    return result;
}

@end
