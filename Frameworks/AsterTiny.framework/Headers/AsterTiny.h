//
//  AsterTin.cpp
//  AsterTiny
//
//  Created by rotonlin on 2019/12/7.
//  Copyright © 2019 rotonlin. All rights reserved.
//
#pragma once

typedef size_t NativeHandler;

namespace AsterTiny {
    struct AsterTinyInstance {
        void* (*getPlatformWindowHandle)();
        NativeHandler registerNativePtr(void* ptr);

        void* _internal;
    };

    AsterTinyInstance* create(void* _scriptContext);
    void destroy(AsterTinyInstance* _handler);
};
