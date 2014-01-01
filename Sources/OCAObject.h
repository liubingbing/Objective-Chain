//
//  OCAObject.h
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import <Foundation/Foundation.h>


#define OCA_atomic  atomic


#define OCALazyGetter(TYPE, PROPERTY) \
@synthesize PROPERTY = _##PROPERTY; \
- (TYPE)PROPERTY { \
    if ( ! self->_##PROPERTY) { \
        self->_##PROPERTY = [self oca_lazyGetter_##PROPERTY]; \
    } \
    return self->_##PROPERTY; \
} \
- (TYPE)oca_lazyGetter_##PROPERTY \



#if !defined(NS_BLOCK_ASSERTIONS)

    #define OCAAssert(CONDITION, MESSAGE, ...) \
if ( ! (CONDITION) && (( [[NSAssertionHandler currentHandler] \
                           handleFailureInFunction: [NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
                           file: [NSString stringWithUTF8String:__FILE__] \
                           lineNumber: __LINE__ \
                           description: (MESSAGE), ##__VA_ARGS__], YES)) ) // Will NOT execute appended code, if exception is thrown.

#else

#define OCAAssert(CONDITION, MESSAGE, ...)\
    if ( ! (CONDITION) && (( NSLog(@"*** Assertion failure in %s, %s:%d, Condition not satisfied: %s, reason: '" MESSAGE "'", __PRETTY_FUNCTION__, __FILE__, __LINE__, #CONDITION, ##__VA_ARGS__), YES)) ) // Will execute appended code.

#endif




@interface OCAObject : NSObject

@end