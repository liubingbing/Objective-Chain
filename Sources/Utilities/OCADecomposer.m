//
//  OCADecomposer.m
//  Objective-Chain
//
//  Created by Martin Kiss on 8.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCADecomposer.h"
#import <objc/runtime.h>





@interface OCADecomposer ()


@property (atomic, readonly, strong) NSMapTable *ownedTable;


@end










@implementation OCADecomposer





#pragma mark Creating Decomposer


- (instancetype)init {
    self = [super init];
    if (self) {
        self->_ownedTable = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}





#pragma mark Managing Owned Objects


- (void)addOwnedObject:(id)ownedObject cleanup:(OCADecomposerBlock)cleanupBlock {
    // Owned Table: Owned objects are Keys and an array of cleanup blocks is Value.
    NSMutableArray *cleanups = [self.ownedTable objectForKey:ownedObject];
    if ( ! cleanups) {
        cleanups = [[NSMutableArray alloc] init];
        [self.ownedTable setObject:cleanups forKey:ownedObject];
    }
    if (cleanupBlock) [cleanups addObject:cleanupBlock];
}


- (void)removeOwnedObject:(id)ownedObject {
    [self.ownedTable removeObjectForKey:ownedObject];
}





#pragma mark Decomposing


- (void)decompose {
    NSMapTable *table = self.ownedTable;
    
    for (NSMutableArray *cleanups in table.objectEnumerator) {
        for (OCADecomposerBlock cleanupBlock in cleanups) {
            cleanupBlock();
        }
    }
    
    [table removeAllObjects];
}


- (void)dealloc {
    [self decompose];
}





@end










@implementation NSObject (OCADecomposer)





static const void * OCADecomposerAssociationKey = &OCADecomposerAssociationKey;


- (OCADecomposer *)decomposer {
    @synchronized(self) {
        OCADecomposer *decomposer = objc_getAssociatedObject(self, OCADecomposerAssociationKey);
        if ( ! decomposer) {
            decomposer = [[OCADecomposer alloc] init];
            objc_setAssociatedObject(self, OCADecomposerAssociationKey, decomposer, OBJC_ASSOCIATION_RETAIN);
        }
        [self.class swizzleDeallocIfNeeded];
        return decomposer;
    }
}


+ (BOOL)swizzleDeallocIfNeeded {
    static NSMutableSet *swizzledClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    @synchronized(self) {
        if ([swizzledClasses containsObject:self]) return NO;
        
        SEL deallocSelector = NSSelectorFromString(@"dealloc");
        Method dealloc = class_getInstanceMethod(self, deallocSelector);
        
        void (*oldImplementation)(id, SEL) = (typeof(oldImplementation))method_getImplementation(dealloc);
        void(^newDeallocBlock)(id) = ^(__unsafe_unretained NSObject *self_deallocating) {
            
            // New dealloc implementation:
            NSLog(@"Decomposer: Custom dealloc <%@ %p>", self_deallocating.class, self_deallocating);
            OCADecomposer *decomposer = objc_getAssociatedObject(self_deallocating, OCADecomposerAssociationKey);
            [decomposer decompose];
            
            // Calling existing implementation.
            oldImplementation(self_deallocating, deallocSelector);
        };
        IMP newImplementation = imp_implementationWithBlock(newDeallocBlock);
        
        class_replaceMethod(self, deallocSelector, newImplementation, method_getTypeEncoding(dealloc));
        
        [swizzledClasses addObject:self];
        NSLog(@"Decomposer: Swizzled class %@", self);
        
        return YES;
    }
}





@end

