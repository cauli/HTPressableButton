//
//  HTPressableButton.m
//  HTPressableButton
//
//  Created by He Rin Kim on 4/14/14.
//  Copyright (c) 2014 He Rin Kim & Thanakron Tandavas. All rights reserved.
//

#import "HTPressableButton.h"
#import "UIImage+HTButton.h"
#import "UIColor+HTColor.h"
#import "HTPressableButtonPrefs.h"



@implementation HTPressableButton

#pragma mark - Init

- (instancetype) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame buttonStyle:HTPressableButtonStyleRounded];
}

- (instancetype) initWithFrame:(CGRect)frame buttonStyle:(HTPressableButtonStyle)style
{
    
    if (self = [super initWithFrame:frame])
    {
        [self setDefaultShadowHeightForStyle:style];
        [self setStyle:style];
    }
    return self;
}

#pragma mark - Set Button Style

- (void) setColorPalette:(NSString*)colorPalette
{
    _colorPalette = colorPalette;
    [self createButton];
}


- (void) setGlow:(BOOL)glow
{
    _glow = glow;
    [self createButton];
}

- (void) setInverted:(BOOL)inverted
{
    _inverted = inverted;
    [self createButton];
}

- (void) setButtonColor:(UIColor *)buttonColor
{
    _buttonColor = buttonColor;
    [self createButton];
}

- (void) setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    [self createButton];
}

- (void) setShadowHeight:(CGFloat)shadowHeight
{
    _shadowHeight = shadowHeight;
    [self createButton];
}

- (void) setStyle:(HTPressableButtonStyle) style
{
    _style = style;
    
    switch (style) {
        case HTPressableButtonStyleRect:
            _cornerRadius = 0.0;
            break;
        case HTPressableButtonStyleRounded:
            _cornerRadius = 10.0;
            break;
        case HTPressableButtonStyleCircular:
            _cornerRadius = self.frame.size.height/2;
            self.clipsToBounds = YES;
            break;
        default:
            _cornerRadius = 0.0;
            break;
    }
    [self createButton];
}

- (void) setDisabledButtonColor:(UIColor *)disabledButtonColor
{
    _disabledButtonColor = disabledButtonColor;
    [self createButton];
}

- (void) setDisabledShadowColor:(UIColor *)disabledShadowColor
{
    _disabledShadowColor = disabledShadowColor;
    [self createButton];
}

#pragma mark - Set Button Default Style

- (UIColor *) buttonColorOrDefault
{
    if(_colorPalette == nil || [_colorPalette isEqual: @""])
    {
       return _buttonColor ?: [UIColor ht_jayColor];
    }
    else
    {
        SEL s = NSSelectorFromString([NSString stringWithFormat:@"%@%@", _colorPalette, @"Color"]);
        _buttonColor = [UIColor performSelector:s];
        return _buttonColor;
    }
}

- (UIColor *) shadowColorOrDefault
{
    UIColor *shadowColorToReturn;
    if(_colorPalette == nil || [_colorPalette isEqual: @""])
    {
        shadowColorToReturn = _shadowColor ?: [UIColor ht_jayDarkColor];
       
        if(SET_TEXT_SHADOW_COLOR_TO_SHADOW_COLOR == YES)
        {
            [self setTitleShadowColor:shadowColorToReturn forState:UIControlStateNormal];
        }

        return shadowColorToReturn;
 
    }
    else
    {
        SEL s = NSSelectorFromString([NSString stringWithFormat:@"%@%@", _colorPalette, @"DarkColor"]);
        shadowColorToReturn = [UIColor performSelector:s];
        
        if(SET_TEXT_SHADOW_COLOR_TO_SHADOW_COLOR == YES)
        {
            [self setTitleShadowColor:shadowColorToReturn forState:UIControlStateNormal];
        }
        
        return shadowColorToReturn;
    }
}

- (UIColor *) disabledButtonColorOrDefault
{
    return _disabledButtonColor ?: [UIColor ht_mediumColor];
}

- (UIColor *) disabledShadowColorOrDefault
{
    return _disabledShadowColor ?: [UIColor ht_mediumDarkColor];
}

- (void) setDefaultShadowHeightForStyle:(HTPressableButtonStyle)style
{
    if (style == HTPressableButtonStyleCircular)
    {
        _shadowHeight = self.frame.size.height * HTShadowCircularDefaultHeightPercentage;
    }
    else
    {
        _shadowHeight = self.frame.size.height * HTShadowDefaultHeightPercentage;
    }
}

- (BOOL) glowOrDefault
{
    return _glow;
}

#pragma mark - Set according to button state

- (void) setHighlighted:(BOOL)highlighted
{

    if (highlighted)
    {
        if (self.style == HTPressableButtonStyleCircular)
        {
            [super setTitleEdgeInsets:UIEdgeInsetsMake(_myTitleInsets.top, _myTitleInsets.left, -((_shadowHeight/4) * HTShadowOffsetWhenPressed), _myTitleInsets.right)];
            [super setImageEdgeInsets:UIEdgeInsetsMake(_myImageInsets.top, _myImageInsets.left, -((_shadowHeight/4) * HTImageOffsetWhenPressed), _myImageInsets.right)];
        }
        else
        {
            [super setTitleEdgeInsets:UIEdgeInsetsMake(_myTitleInsets.top, _myTitleInsets.left, -(_shadowHeight * HTShadowOffsetWhenPressed), _myTitleInsets.right)];
            [super setImageEdgeInsets:UIEdgeInsetsMake(_myImageInsets.top, _myImageInsets.left, -(_shadowHeight * HTImageOffsetWhenPressed), _myImageInsets.right)];
        }
    }
    else
    {
        [super setTitleEdgeInsets:UIEdgeInsetsMake(_myTitleInsets.top, _myTitleInsets.left, _shadowHeight, _myTitleInsets.right)];
        
        // Retorna para os paddings iniciais do Storyboard para a imagem
        // Returns to the initial EdgeInsets (for the image) from the Storyboard
        [super setImageEdgeInsets:UIEdgeInsetsMake(_myImageInsets.top, _myImageInsets.left, _myImageInsets.bottom, _myImageInsets.right)];
    }
    [super setHighlighted:highlighted];
    
   
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    //The button image when disabled is only created when user disables the button it, this is to avoid wasting space.
    if (!enabled) {
        UIImage *buttonDisabled;
        if (self.style == HTPressableButtonStyleCircular)
        {
            buttonDisabled = [UIImage ht_circularButtonWithColor:[self disabledButtonColorOrDefault]
                                                            size:self.frame.size
                                                    shadowHeight:_shadowHeight
                                                     shadowColor:[self disabledShadowColorOrDefault]
                                                    cornerRadius:_cornerRadius];
        }
        else
        {
            buttonDisabled = [UIImage ht_buttonWithColor:[self disabledButtonColorOrDefault]
                                                    size:self.frame.size
                                            shadowHeight:_shadowHeight
                                             shadowColor:[self disabledShadowColorOrDefault]
                                            cornerRadius:_cornerRadius
                                                    glow:[self glowOrDefault]
                                                inverted:_inverted];
        }

        [self setBackgroundImage:buttonDisabled forState:UIControlStateDisabled];

    }
}


#pragma mark - Create Button

- (void) createButton
{
    UIImage *buttonNormal;
    UIImage *buttonHighlighted;
    
    _myImageInsets = self.imageEdgeInsets;
    _myTitleInsets = self.titleEdgeInsets;
    
    [super setTitleEdgeInsets:UIEdgeInsetsMake(_myTitleInsets.top, _myTitleInsets.left, _shadowHeight, _myTitleInsets.right)];
    
    if (self.style == HTPressableButtonStyleCircular)
    {
        buttonNormal = [UIImage ht_circularButtonWithColor:[self buttonColorOrDefault]
                                                      size:self.frame.size
                                              shadowHeight:_shadowHeight
                                               shadowColor:[self shadowColorOrDefault]
                                              cornerRadius:_cornerRadius];
        
        buttonHighlighted = [UIImage ht_circularButtonWithHighlightedColor:[self buttonColorOrDefault]
                                                                      size:self.frame.size
                                                              shadowHeight:_shadowHeight
                                                               shadowColor:[self shadowColorOrDefault]
                                                              cornerRadius:_cornerRadius];
    }
    else
    {
        // Rectangular or rounded-corner buttons
        buttonNormal = [UIImage ht_buttonWithColor:[self buttonColorOrDefault]
                                              size:self.frame.size
                                      shadowHeight:_shadowHeight
                                       shadowColor:[self shadowColorOrDefault]
                                      cornerRadius:_cornerRadius
                                              glow:[self glowOrDefault]
                                          inverted:_inverted];
        
        buttonHighlighted = [UIImage ht_buttonWithHighlightedColor:[self buttonColorOrDefault]
                                                              size:self.frame.size
                                                      shadowHeight:_shadowHeight
                                                       shadowColor:[self shadowColorOrDefault]
                                                      cornerRadius:_cornerRadius
                                                               glow:[self glowOrDefault]
                                                            inverted:_inverted];
    }
      
    [self setBackgroundImage:buttonNormal forState:UIControlStateNormal];
    [self setBackgroundImage:buttonHighlighted forState:UIControlStateHighlighted];
    
    _originalButtonColor = self.backgroundColor;
    
    [self setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Deprecated Methods

- (void)setDefaultButtonColor
{
    [self setButtonColor:nil];
}

- (void)setDefaultShadowColor
{
    [self setShadowColor:nil];
}

- (void)setDefaultShadowHeight
{
    [self setDefaultShadowHeightForStyle:self.style];
}

@end
