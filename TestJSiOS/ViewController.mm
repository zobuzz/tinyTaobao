//
//  ViewController.m
//  TaoBaoEnv
//
//  Created by 孙志鹏 on 2019/12/3.
//  Copyright © 2019 孙志鹏. All rights reserved.
//

#import "ViewController.h"
#include <JavaScriptCore/JavaScriptCore.h>
#include <fstream>
#include <sys/stat.h>
#include <mach/mach_time.h>
#include <iostream>
#include <sstream>

//#include "bgfx.h"

JSGlobalContextRef globalContext;
JSObjectRef tickCallbackRef;

CGFloat screenWidth;
CGFloat screenHeight;
namespace UnityTB{
    using namespace std;
    
    std::string JSStringToStdString(JSStringRef jsString) {
        size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
        char* utf8Buffer = new char[maxBufferSize];
        size_t bytesWritten = JSStringGetUTF8CString(jsString, utf8Buffer, maxBufferSize);
        std::string utf_string = std::string (utf8Buffer, bytesWritten -1); // the last byte is a null \0 which std::string doesn't need.
        delete [] utf8Buffer;
        return utf_string;
    }
    void freeData(void* bytes, void* deallocatorContext) {
        free(bytes);
    }
    static void postException(JSGlobalContextRef context, JSValueRef exception)
    {
        if(exception)
        {
            JSObjectRef ex = JSValueToObject(context, exception, 0);
            JSValueRef lineNumber = JSObjectGetProperty(context, ex, JSStringCreateWithUTF8CString("line"), 0);
            JSStringRef line_str = JSValueToStringCopy(context, lineNumber, 0);
            std::string str = JSStringToStdString(line_str);
            printf("%s\n", str.c_str());
            JSValueRef stack = JSObjectGetProperty(context, ex, JSStringCreateWithUTF8CString("stack"), 0);
            JSStringRef stack_str = JSValueToStringCopy(context, stack, 0);
            str = JSStringToStdString(stack_str);
            printf("%s\n", str.c_str());
            JSStringRef exception_str = JSValueToStringCopy(context, exception, 0);
            str = JSStringToStdString(exception_str);
            printf("%s\n", str.c_str());
        }
    }
    
    
    /*
    void bgfx_internal_log_error() {
        printf("bgfx error");
    }
    
    JSValueRef bgfx_set_platform_data(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        //only one parameter
        if (argumentCount != 2) {
            bgfx_internal_log_error();
        }
        
        printf("native bgfxSetPlatformData called !");
        return JSValueMakeNull(ctx);
    }
    
    JSValueRef bgfx_get_renderer_type(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, (double)bgfx::getRendererType());
    }
    
    JSValueRef getTbNwh(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, (double)bgfx::getRendererType());
    }
    
    JSValueRef bgfx_init(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        //only one parameter
        if (argumentCount != 2) {
            bgfx_internal_log_error();
        }
        
        bgfx::Init init;
        init.type = bgfx::RendererType::Metal;
        init.vendorId = BGFX_PCI_ID_NONE;
        init.resolution.width = screenWidth;
        init.resolution.height = screenHeight;
        init.resolution.reset = BGFX_RESET_VSYNC;
        bgfx::init(init);
        printf("native bgfxInit called !");

        return JSValueMakeBoolean(ctx, true);
    }
    
    JSValueRef bgfx_vertex_layout_begin(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        //only one parameter
        JSObjectRef objectRef = JSValueToObject(ctx, arguments[0], nullptr);
        uint8_t *_this = (uint8_t *)JSObjectGetArrayBufferBytesPtr(ctx, objectRef, nullptr);
        size_t offset = (size_t) JSValueToNumber(ctx, arguments[1], nullptr);
        _this += offset;
        
        bgfx::RendererType::Enum type = (bgfx::RendererType::Enum) JSValueToNumber(ctx, arguments[2], nullptr);
        bgfx::VertexLayout* This = (bgfx::VertexLayout*)_this;
        This->begin(type);
        
        return JSValueMakeNumber(ctx, offset);
    }*/
    
    JSValueRef ReadFile_func(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        
        JSStringRef pathString = JSValueToStringCopy(ctx, arguments[0], nullptr);
        std::string pathStdString = JSStringToStdString(pathString);
        
        
        //pathStdString = "/Users/xingweizhu/WorkSpace/Explore/TestNewTiny/dots/TinySamples/Builds/AsmJsMoleTiny3D/" + pathStdString;
        NSString* realPath = [NSString stringWithCString:pathStdString.c_str()
                                                encoding:[NSString defaultCStringEncoding]];
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:realPath ofType:@""];
        std::string* path = new std::string([filePath UTF8String]);
        
        FILE *pFile = fopen(path->c_str(), "rb");
        fseek (pFile , 0 , SEEK_END);
        long lSize = ftell (pFile);
        rewind (pFile);
        char* buffer = (char*)malloc(lSize);
        fread (buffer,1,lSize,pFile);
        fclose(pFile);
        JSObjectRef memObj = JSObjectMakeTypedArrayWithBytesNoCopy(globalContext, kJSTypedArrayTypeUint8Array, (void*) buffer, lSize, freeData, nullptr, nullptr);
        return memObj;
    }
    
    JSValueRef TellSize_func(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        
        JSStringRef pathString = JSValueToStringCopy(ctx, arguments[0], nullptr);
        std::string pathStdString = JSStringToStdString(pathString);
        
        //pathStdString = "/Users/xingweizhu/WorkSpace/Explore/TestNewTiny/dots/TinySamples/Builds/AsmJsMoleTiny3D/" + pathStdString;
        NSString* realPath = [NSString stringWithCString:pathStdString.c_str()
                           encoding:[NSString defaultCStringEncoding]];
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:realPath ofType:@""];
        std::string* path = new std::string([filePath UTF8String]);

        FILE *pFile = fopen(path->c_str(), "rb");
        fseek (pFile , 0 , SEEK_END);
        long lSize = ftell (pFile);
        rewind (pFile);
        fclose(pFile);
        return JSValueMakeNumber(ctx, (double)lSize);
    }
    
    JSValueRef Console_log(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        for (size_t i=0; i<argumentCount; i++) {
            JSStringRef pathString = JSValueToStringCopy(ctx, arguments[i], nullptr);
            cout << JSStringToStdString(pathString);
        }
        cout << endl ;
        return JSValueMakeUndefined(ctx);
    }
    
    //cannot be used if the callback function is defined in a lambda func, since
    //it will be collected as garbage when the current frame ends
    JSValueRef RequestAnimationFrameFunc(JSContextRef ctx,
                                         JSObjectRef function,
                                         JSObjectRef thisObject,
                                         size_t argumentCount,
                                         const JSValueRef arguments[],
                                         JSValueRef* exception)
    {
        //only one argument, i.e., the tick function
        if(argumentCount == 1 && tickCallbackRef == nullptr)
        {
            JSObjectRef callback = JSValueToObject(ctx, arguments[0], nullptr);
            JSValueProtect(globalContext, callback);
            tickCallbackRef = callback;
        }
        
        return JSValueMakeNull(ctx);
    }
    
    JSValueRef setCanvasWidth(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        screenWidth = JSValueToNumber(ctx, arguments[0], nullptr);
        
        return JSValueMakeNull(ctx);
    }
    
    JSValueRef setCanvasHeight(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        screenHeight = JSValueToNumber(ctx, arguments[0], nullptr);
        
        return JSValueMakeNull(ctx);
    }
    
    JSValueRef getFrameWidth(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, screenWidth);
    }
    JSValueRef getFrameHeight(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, screenHeight);
    }
    JSValueRef getCanvasWidth(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, screenWidth);
    }
    JSValueRef getCanvasHeight(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, screenHeight);
    }
    JSValueRef getScreenWidth(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, screenWidth);
    }
    JSValueRef getScreenHeight(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        return JSValueMakeNumber(ctx, screenHeight);
    }
    
    struct PerformancePrivate {
        mach_timebase_info_data_t timebase;
        uint64_t startup_seconds;
    };
    JSObjectRef Performance_CallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception){
        PerformancePrivate *performance = new PerformancePrivate();
        uint64_t now = mach_absolute_time();
        mach_timebase_info(&performance->timebase);
        performance->timebase.denom *= 1000000000;
        performance->startup_seconds = now * performance->timebase.numer / performance->timebase.denom;
        JSObjectSetPrivate(constructor, static_cast<void*>(performance));
        
        return constructor;
    }
    void Performance_Finalize(JSObjectRef object){
        PerformancePrivate *performance = static_cast<PerformancePrivate*>(JSObjectGetPrivate(object));
        delete performance;
    }
    JSValueRef Performance_now(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        PerformancePrivate *performance = static_cast<PerformancePrivate*>(JSObjectGetPrivate(thisObject));
        uint64_t now = mach_absolute_time();
        uint64_t now_seconds = ((now - performance->startup_seconds) * performance->timebase.numer) / performance->timebase.denom;
        return JSValueMakeNumber(ctx, (double)now_seconds);
    }
    
    JSClassRef PerformanceClass() {
        static JSClassRef console_class;
        if (!console_class) {
            JSClassDefinition classDefinition = kJSClassDefinitionEmpty;
            
            static JSStaticFunction staticFunctions[] = {
                { "now", Console_log, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { 0, 0, 0 }
            };
            
            classDefinition.className = "performance";
            classDefinition.attributes = kJSClassAttributeNone;
            classDefinition.staticFunctions = staticFunctions;
            classDefinition.finalize = Performance_Finalize;
            classDefinition.callAsConstructor = Performance_CallAsConstructor;
            console_class = JSClassCreate(&classDefinition);
        }
        return console_class;
    }
    
    JSClassRef ConsoleClass() {
        static JSClassRef console_class;
        if (!console_class) {
            JSClassDefinition classDefinition = kJSClassDefinitionEmpty;
            
            static JSStaticFunction staticFunctions[] = {
                { "log", Console_log, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { "warn", Console_log, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { "error", Console_log, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { 0, 0, 0 }
            };
            
            classDefinition.className = "console";
            classDefinition.attributes = kJSClassAttributeNone;
            classDefinition.staticFunctions = staticFunctions;
            console_class = JSClassCreate(&classDefinition);
        }
        return console_class;
    }
    
    struct FilesystemPrivate {
        string path;
        bool is_directory;
        bool is_file;
        bool is_symlink;
        size_t size;
        bool exists;
    };
    
    void setAttributes(FilesystemPrivate *fs, std::string path) {
        fs->path = path;
        
        struct stat statbuf;
        
        if (lstat(path.c_str(), &statbuf) != -1) {
            switch (statbuf.st_mode & S_IFMT){
                case S_IFREG:
                    fs->is_file = true;
                    break;
                case S_IFLNK:
                    fs->is_symlink = true;
                    break;
                case S_IFDIR:
                    fs->is_directory = true;
                    break;
            }
            fs->size = statbuf.st_size;
            fs->exists = true;
        }else{
            fs->exists = false;
            fs->is_file = false;
            fs->is_directory = false;
            fs->is_symlink = false;
            fs->size = 0;
        }
    }
    
    /* callbacks */
    
    void Filesystem_Finalize(JSObjectRef object){
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        delete fs;
    }
    
    JSObjectRef Filesystem_CallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception){
        FilesystemPrivate *fs = new FilesystemPrivate();
        
        JSStringRef pathString = JSValueToStringCopy(ctx, arguments[0], nullptr);
        setAttributes(fs, JSStringToStdString(pathString));
        JSObjectSetPrivate(constructor, static_cast<void*>(fs));
        
        return constructor;
    }
    
    /* static values */
    
    JSValueRef Filesystem_getPath(JSContextRef ctx, JSObjectRef object,JSStringRef propertyName, JSValueRef* exception) {
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        JSStringRef pathString = JSStringCreateWithUTF8CString(fs->path.c_str());
        
        return JSValueMakeString(ctx, pathString);
    }
    
    bool Filesystem_setPath(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        JSStringRef pathString = JSValueToStringCopy(ctx, value, nullptr);
        
        setAttributes(fs, JSStringToStdString(pathString));
        
        return true;
    }
    
    JSValueRef Filesystem_getType(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        JSStringRef pathType;
        
        if (fs->is_file) {
            pathType = JSStringCreateWithUTF8CString("File");
        }else if (fs->is_directory) {
            pathType = JSStringCreateWithUTF8CString("Directory");
        }else if (fs->is_symlink) {
            pathType = JSStringCreateWithUTF8CString("Symlink");
        }else{
            pathType = JSStringCreateWithUTF8CString("Unknown");
        }
        
        return JSValueMakeString(ctx, pathType);
    }
    
    JSValueRef Filesystem_getExist(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        
        return JSValueMakeBoolean(ctx, fs->exists);
    }
    
    JSValueRef Filesystem_getSize(JSContextRef ctx, JSObjectRef object,JSStringRef propertyName, JSValueRef* exception) {
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        
        return JSValueMakeNumber(ctx, static_cast<double>(fs->size));
    }
    
    JSValueRef Filesystem_remove(JSContextRef ctx, JSObjectRef function, JSObjectRef object, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception){
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        remove(fs->path.c_str());
        
        return JSValueMakeUndefined(ctx);
    }
    
    JSValueRef Filesystem_fread(JSContextRef ctx, JSObjectRef function, JSObjectRef object, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
        FilesystemPrivate *fs = static_cast<FilesystemPrivate*>(JSObjectGetPrivate(object));
        FILE *pFile = fopen(fs->path.c_str(), "rb");
        fseek (pFile , 0 , SEEK_END);
        long lSize = ftell (pFile);
        rewind (pFile);
        char* buffer = new char[lSize];
        fread (buffer,1, lSize, pFile);
        JSStringRef s = JSStringCreateWithUTF8CString(buffer);
        return JSValueMakeString(ctx, s);
    }
    
    JSClassRef FilesystemClass() {
        static JSClassRef filesystem_class;
        if (!filesystem_class) {
            JSClassDefinition classDefinition = kJSClassDefinitionEmpty;
            
            static JSStaticFunction staticFunctions[] = {
                { "remove", Filesystem_remove, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { "read", Filesystem_fread, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { 0, 0, 0 }
            };
            
            static JSStaticValue staticValues[] = {
                { "path", Filesystem_getPath, Filesystem_setPath, kJSPropertyAttributeDontDelete },
                { "type", Filesystem_getType, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { "exists", Filesystem_getExist, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { "size", Filesystem_getSize, 0, kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontDelete },
                { 0, 0, 0, 0 }
            };
            
            classDefinition.className = "Filesystem";
            classDefinition.attributes = kJSClassAttributeNone;
            classDefinition.staticFunctions = staticFunctions;
            classDefinition.staticValues = staticValues;
            classDefinition.finalize = Filesystem_Finalize;
            classDefinition.callAsConstructor = Filesystem_CallAsConstructor;
            
            filesystem_class = JSClassCreate(&classDefinition);
        }
        return filesystem_class;
    }
}

@implementation ViewController

+ (void)requestAnimationFrame {
    if (tickCallbackRef != nullptr) {
        JSValueRef newExp = nullptr;
        JSObjectCallAsFunction(globalContext, tickCallbackRef, nullptr, 0, nullptr, &newExp);
        UnityTB::postException(globalContext, newExp);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    printf("view Did Loaded >>>>");
    
    // Do any additional setup after loading the view.
    JSContextGroupRef contextGroup = JSContextGroupCreate();
    globalContext = JSGlobalContextCreateInGroup(contextGroup, nullptr);
    JSObjectRef globalObject = JSContextGetGlobalObject(globalContext);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    //XMLHttpRequest *xmlHttpRequest = [XMLHttpRequest new];
    //id jsContext = [JSContext contextWithJSGlobalContextRef:globalContext];
    
    //[xmlHttpRequest extend:jsContext];
    /*
     functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("readbuffer"), UnityTB::Read_func);
     JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("readbuffer"), functionObject, kJSPropertyAttributeNone, nullptr);
     
     JSObjectRef filesystemObject = JSObjectMake(globalContext, UnityTB::FilesystemClass(), nullptr);
     JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("Filesystem"), filesystemObject, kJSPropertyAttributeNone, nullptr);
     */
    
    JSObjectRef functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("setCanvasWidth"), UnityTB::setCanvasWidth);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("setCanvasWidth"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("setCanvasHeight"), UnityTB::setCanvasHeight);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("setCanvasHeight"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getFrameWidth"), UnityTB::getFrameWidth);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getFrameWidth"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getFrameHeight"), UnityTB::getFrameHeight);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getFrameHeight"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getCanvasWidth"), UnityTB::getCanvasWidth);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getCanvasWidth"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getCanvasHeight"), UnityTB::getCanvasHeight);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getCanvasHeight"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getScreenWidth"), UnityTB::getScreenWidth);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getScreenWidth"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getScreenHeight"), UnityTB::getScreenHeight);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getScreenHeight"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("requestAnimationFrame"), UnityTB::RequestAnimationFrameFunc);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("requestAnimationFrame"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("ReadFile_func"), UnityTB::ReadFile_func);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("ReadFile_func"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("TellSize_func"), UnityTB::TellSize_func);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("TellSize_func"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    JSObjectRef consoleObject = JSObjectMake(globalContext, UnityTB::ConsoleClass(), nullptr);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("console"), consoleObject, kJSPropertyAttributeNone, nullptr);
    
    JSObjectRef performanceObject = JSObjectMake(globalContext, UnityTB::PerformanceClass(), nullptr);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("Performance"), performanceObject, kJSPropertyAttributeNone, nullptr);
    
    
    
    //bgfx hook
    /*
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("bgfx_get_renderer_type"), UnityTB::bgfx_get_renderer_type);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("bgfx_get_renderer_type"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("bgfx_set_platform_data"), UnityTB::bgfx_set_platform_data);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("bgfx_set_platform_data"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("bgfx_init"), UnityTB::bgfx_init);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("bgfx_init"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("bgfx_vertex_layout_begin"), UnityTB::bgfx_vertex_layout_begin);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("bgfx_vertex_layout_begin"), functionObject, kJSPropertyAttributeNone, nullptr);
    
    functionObject = JSObjectMakeFunctionWithCallback(globalContext, JSStringCreateWithUTF8CString("getTbNwh"),
                                                      UnityTB::getTbNwh);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("getTbNwh"), functionObject, kJSPropertyAttributeNone, nullptr);
    */
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MoleTiny3D" ofType:@"js"];
    std::string *path = new std::string([filePath UTF8String]);
    std::ifstream inFile;
    //inFile.open("/Users/xingweizhu/WorkSpace/Explore/TestNewTiny/dots/TinySamples/Builds/AsmJsMoleTiny3D/MoleTiny3D.js"); //open the input file
    inFile.open(*path); //open the input file
    std::stringstream strStream;
    strStream << inFile.rdbuf(); //read the file
    std::string str = strStream.str(); //str holds the content of the file
    
    
    filePath = [[NSBundle mainBundle] pathForResource:@"MoleTiny3D.asm" ofType:@"js"];
    path = new std::string([filePath UTF8String]);
    
    std::ifstream inFile2;
    //inFile2.open("/Users/xingweizhu/WorkSpace/Explore/TestNewTiny/dots/TinySamples/Builds/AsmJsMoleTiny3D/MoleTiny3D.asm.js"); //open the input file
    inFile2.open(*path);
    std::stringstream strStream2;
    strStream2 << inFile2.rdbuf(); //read the file
    std::string str2 = strStream2.str(); //str holds the content of the file
    
    filePath = [[NSBundle mainBundle] pathForResource:@"MoleTiny3D" ofType:@"mem"];
    path = new std::string([filePath UTF8String]);
    std::ifstream inFile3;
    //inFile3.open("/Users/xingweizhu/WorkSpace/Explore/TestNewTiny/dots/TinySamples/Builds/AsmJsMoleTiny3D/MoleTiny3D.mem"); //open the input file
    inFile3.open(*path);
    std::stringstream strStream3;
    strStream3 << inFile3.rdbuf(); //read the file
    std::string str3 = strStream3.str(); //str holds the content of the file
    
    JSValueRef exception = NULL;
    
    std::string asm_prefix ("asm=Module;");
    str2 = str2 + asm_prefix;
    const char *asm_content = str2.c_str();
    
    std::string content_prefix ("js=Module;");
    str = str + content_prefix;
    const char *content = str.c_str();

    long mem_length = str3.length();
    unsigned char *mem = (unsigned char*)malloc(mem_length);
    memcpy(mem, str3.c_str(), mem_length);
    
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("document={};var performance = new Performance();"), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString(asm_content), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    JSObjectRef memObj = JSObjectMakeArrayBufferWithBytesNoCopy(globalContext, (void*) mem, mem_length, UnityTB::freeData, nullptr, nullptr);
    JSObjectSetProperty(globalContext, globalObject, JSStringCreateWithUTF8CString("memdata"), memObj, kJSPropertyAttributeNone, nullptr);
    
    //JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("Module.mem = memdata;"), nullptr, nullptr, 1, &exception);
    //if (exception) UnityTB::postException(globalContext, exception);
    
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString(content), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("js({asm: asm, mem: memdata});"), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    /*
    //fake window
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("window={get innerWidth() {return getFrameWidth();}, get innerHeight() {return getFrameHeight();}, addEventListener : function(ev, handler){}};"), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    //fake canvas
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("ut={};ut._HTML={};ut._HTML.canvasElement={get width() {return getCanvasWidth();}, set width(value) {setCanvasWidth(value);}, set height(value) {setCanvasHeight(value);}, get height() {return getCanvasHeight();}, focus : function(){}};"), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    //fake screen
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("screen={get width() {return getScreenWidth();}, get height() {return getScreenHeight();}};"), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);
    
    //fake inputSystem
    JSEvaluateScript(globalContext, JSStringCreateWithUTF8CString("ut._HTML.canvasElement.addEventListener = function(ev, handler){};"), nullptr, nullptr, 1, &exception);
    if (exception) UnityTB::postException(globalContext, exception);*/
}

@end
