//
//  HYColor.h
//  HYOpenCVDemo
//
//  Created by 胡杨 on 2017/5/29.
//  Copyright © 2017年 Hoo. All rights reserved.
//

#ifndef HYColor_h
#define HYColor_h

#define Mask8(x) ((x) & 0xFF)

#define R(x)    ( Mask8(x) )
#define G(x)    ( Mask8(x >> 8) )
#define B(x)    ( Mask8(x >> 16) )
#define A(x)    ( Mask8(x >> 24) )

#define RGBAMake(r, g, b, a)    (Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

#endif /* HYColor_h */
