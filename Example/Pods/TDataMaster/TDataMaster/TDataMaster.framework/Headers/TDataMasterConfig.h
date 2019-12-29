//
//  TDataMasterConfig.h
//  TDataMaster
//
//  Created by Morris on 17/1/5.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef TDataMasterConfig_h
#define TDataMasterConfig_h

#include <string>
#include <vector>

#include "TDataMasterDefines.h"
#include "TDataMasterCommon.h"
#include "TMutex.h"

_TDM_Name_Space
{
#define Default_Block_Bytes     (1 << 15)       // 32KB
#define Default_MAX_Speed       (1 << 16)       // 64KB/s

    enum DataBaseLevel
    {
        kDBLevelAll,
        kDBLevelVIP,
        kDBLevelNone,
    };
    
    struct AddrInfo
    {
        std::string Url;
        int Port;
    };
    
    class TDataMasterConfig
    {
    public:
        static TDataMasterConfig * GetInstance();
        static void ReleaseInstance();

        bool SetConfiguration(const void* data, int size);

        ReportType GetReportType(EventID id, bool vip);

        int32_t GetBlockSize();
        int32_t GetMAXSpeed();

        const char * GetSessionID();
        bool GetEnableReportDebug();

        void GetHost(NetProtocol type, std::vector<AddrInfo>& vecHost);

    private:
        TDataMasterConfig();
        TDataMasterConfig(const TDataMasterConfig& t){}
        TDataMasterConfig& operator=(const TDataMasterConfig& t){return *this;}
        ~TDataMasterConfig();

        void OnSetConfiguration();
        
    private:
        static TDataMasterConfig* m_pInstance;
        static CMutex m_Mutex;
        
        std::string m_SessinID;
        std::vector<AddrInfo> m_HostTCP;
        std::vector<AddrInfo> m_HostUDP;
        std::vector<int32_t> m_EventBlacklist;
        
        bool m_EnableReport;
        bool m_SWUserData;
        bool m_SWSDKData;
        bool m_SWSysData;
        bool m_SWStartData;
        bool m_SWApolloData;
        bool m_EnableReportDebug;

        DataBaseLevel m_DBLevel;
        int32_t m_BlockSize;
        int32_t m_MAXSpeed;
    };
}



#endif /* TDataMasterConfig_h */
