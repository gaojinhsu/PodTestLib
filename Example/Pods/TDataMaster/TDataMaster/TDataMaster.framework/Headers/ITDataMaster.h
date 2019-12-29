//
//  ITDataMaster.hpp
//  ITDataMaster
//
//  Created by Morris on 16/8/16.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#ifndef ITDataMaster_hpp
#define ITDataMaster_hpp

#include "TDataMasterDefines.h"
#include <stdio.h>
#include <map>
#include <string>

#define PUBLIC_API TDM_EXPORT

_TDM_Name_Space
{
    class IEventReporter
    {
    public:
        virtual PUBLIC_API void Add(const char* key, const char* value, const int valueLen = 0) = 0;
        virtual PUBLIC_API void Add(int key, const char* value, const int valueLen = 0) = 0;
        virtual PUBLIC_API void Add(int key, int64_t value) = 0;
        virtual PUBLIC_API void Report() = 0;
        virtual ~IEventReporter(){};
    };
    
    class ITDataMaster
    {
    protected:
        ITDataMaster(){}
        virtual ~ITDataMaster(){}
        
    public:
        static PUBLIC_API ITDataMaster* GetInstance();
        static PUBLIC_API void ReleaseInstance();
        
    public:
        
        virtual const char* GetTDMUID() = 0;

		virtual PUBLIC_API bool Initialize(const char* AppId, const char* AppChannel) = 0;

        virtual PUBLIC_API void EnableReport(bool enable) = 0;
        
        virtual PUBLIC_API void SetLogLevel(LogLevel level) = 0;
        
        virtual PUBLIC_API void ReportBinary(int srcID, const char * eventName, const char* data, int len) = 0;
        
        virtual PUBLIC_API void PluginReportEvent(int srcID, const char* eventName, const std::map<std::string, std::string>& customData, const std::map<int32_t, int64_t>& intData, const std::map<int32_t, std::string>& strData) = 0;
        
        virtual PUBLIC_API const char* GetSessionID() = 0;

        virtual PUBLIC_API const char* GetTDMSDKVersion() = 0;
    
    public:
        virtual PUBLIC_API IEventReporter* CreateEventReporter(int srcId, const char* eventName) = 0;
        
        virtual PUBLIC_API void DestroyEventReporter(IEventReporter*& reporter) = 0;
    };

}

#endif /* ITDataMaster_hpp */
