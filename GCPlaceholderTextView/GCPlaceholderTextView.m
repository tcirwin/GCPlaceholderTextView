//
//  GCPlaceholderTextView.m
//  GCLibrary
//
//  Created by Guillaume Campagna on 10-11-16.
//  Copyright 2010 LittleKiwi. All rights reserved.
//

#import "GCPlaceholderTextView.h"

@interface GCPlaceholderTextView () 

@property (nonatomic, strong) UIColor* realTextColor;
@property (unsafe_unretained, nonatomic, readonly) NSString* realText;
@property (nonatomic, strong) id<UITextViewDelegate> annexDelegate;


- (void) beginEditing:(NSNotification*) notification;
- (void) endEditing:(NSNotification*) notification;

@end

@implementation GCPlaceholderTextView

@synthesize realTextColor;
@synthesize placeholder;
@synthesize placeholderColor;

#pragma mark -
#pragma mark Initialisation

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changed:) name:UITextViewTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    
    [super setDelegate:self];
    self.realTextColor = self.textColor;
    self.placeholderColor = [UIColor lightGrayColor];
}

- (void)setDelegate:(id<UITextViewDelegate>)anotherDelegate {
    _annexDelegate = anotherDelegate;
}

#pragma mark -
#pragma mark Setter/Getters

- (void) setPlaceholder:(NSString *)aPlaceholder {
    if ([self.realText isEqualToString:placeholder] && ![self isFirstResponder]) {
        self.text = aPlaceholder;
    }
    if (aPlaceholder != placeholder) {
        placeholder = aPlaceholder;
    }
    
    [self endEditing:nil];
}

- (void)setPlaceholderColor:(UIColor *)aPlaceholderColor {
    placeholderColor = aPlaceholderColor;
    
    if ([super.text isEqualToString:self.placeholder]) {
        self.textColor = self.placeholderColor;
    }
}

- (NSString *) text {
    NSString* text = [super text];
    if ([text isEqualToString:self.placeholder]) return @"";
    return text;
}

- (void) setText:(NSString *)text {
    if (([text isEqualToString:@""] || text == nil) && ![self isFirstResponder]) {
        super.text = self.placeholder;
    }
    else {
        super.text = text;
    }
    
    if ([text isEqualToString:self.placeholder]) {
        self.textColor = self.placeholderColor;
    }
    else {
        self.textColor = self.realTextColor;
    }
}

- (NSString *) realText {
    return [super text];
}

- (void) changed:(NSNotification*) notification {
    if ([self.realText isEqualToString:@""]) {
        self.text = self.placeholder;
        self.textColor = self.placeholderColor;
        
        // Delay selecting first character until after beginEditing sets the selected range
        [self performSelector:@selector(selectFirstChar) withObject:self afterDelay:0.0];
    }
    else if ([self.realText isEqualToString:self.placeholder]) {
        // Delay selecting first character until after beginEditing sets the selected range
        [self performSelector:@selector(selectFirstChar) withObject:self afterDelay:0.0];
    }
    else if ([self.realText hasSuffix:self.placeholder]) {
        self.text = [self.text substringWithRange:NSMakeRange(0, self.realText.length - self.placeholder.length)];
    }
}

- (void)selectFirstChar {
    self.selectedRange = NSMakeRange(0, 0);
}

- (void) beginEditing:(NSNotification*) notification {
    if ([self.realText isEqualToString:self.placeholder]) {
        self.textColor = self.realTextColor;
        
        // Delay selecting first character until after beginEditing sets the selected range
        [self performSelector:@selector(selectFirstChar) withObject:self afterDelay:0.0];
    }
}

- (void) endEditing:(NSNotification*) notification {
    if ([self.realText isEqualToString:@""] || self.realText == nil) {
        super.text = self.placeholder;
        self.textColor = self.placeholderColor;
    }
}

- (void) setTextColor:(UIColor *)textColor {
    if ([self.realText isEqualToString:self.placeholder]) {
        if ([textColor isEqual:self.placeholderColor]){
             [super setTextColor:textColor];
        } else {
            self.realTextColor = textColor;
        }
    }
    else {
        self.realTextColor = textColor;
        [super setTextColor:textColor];
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return (_annexDelegate) ? [_annexDelegate textViewShouldBeginEditing:textView] : YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return (_annexDelegate) ? [_annexDelegate textViewShouldEndEditing:textView] : YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [_annexDelegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [_annexDelegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    return (_annexDelegate) ? [_annexDelegate textView:textView
                               shouldChangeTextInRange:range replacementText:text] : YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [_annexDelegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([self.realText isEqualToString:self.placeholder]) {
        [self selectFirstChar];
    }
    
    [_annexDelegate textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL
         inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0) {
    return (_annexDelegate) ? [_annexDelegate textView:textView
                                 shouldInteractWithURL:URL inRange:characterRange] : YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment
         inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0){
    return (_annexDelegate) ? [_annexDelegate textView:textView
                      shouldInteractWithTextAttachment:textAttachment inRange:characterRange] : YES;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
