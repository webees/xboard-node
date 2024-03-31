#!/bin/sh

if [ -z "$XRAYR_NODE_ID" ]; then
  exit 1
fi

CERT_MODE=none

if [ -n "$ACME_DOMAIN" ]; then
  while [ ! -f "/root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.cer" ]; do
      sleep 5
  done
  CERT_MODE=file
fi

XRAYR_PANEL_TYPE=${XRAYR_PANEL_TYPE:-NewV2board}
XRAYR_NODE_TYPE=${XRAYR_NODE_TYPE:-V2ray}

cat > /xrayr.yml <<EOF
Log:
  Level: none                              # 日志级别：none, error, warning, info, debug
  AccessPath:                              # 访问日志路径：/etc/XrayR/access.Log
  ErrorPath:                               # 错误日志路径：/etc/XrayR/error.log
DnsConfigPath:                             # DNS配置路径：/etc/XrayR/dns.json    # DNS配置的路径，请参考 https://xtls.github.io/config/dns.html 获取帮助
RouteConfigPath:                           # 路由配置路径：/etc/XrayR/route.json  # 路由配置的路径，请参考 https://xtls.github.io/config/routing.html 获取帮助
InboundConfigPath:                         # 自定义入站配置路径：/etc/XrayR/custom_inbound.json  # 自定义入站配置的路径，请参考 https://xtls.github.io/config/inbound.html 获取帮助
OutboundConfigPath:                        # 自定义出站配置路径：/etc/XrayR/custom_outbound.json  # 自定义出站配置的路径，请参考 https://xtls.github.io/config/outbound.html 获取帮助
ConnectionConfig:
  Handshake: 4                             # 连接建立时的握手时间限制，秒
  ConnIdle: 10                             # 连接空闲的时间限制，秒
  UplinkOnly: 2                            # 当连接下行线路关闭后的时间限制，秒
  DownlinkOnly: 4                          # 当连接上行线路关闭后的时间限制，秒
  BufferSize: 64                           # 每个连接的内部缓存大小，kB
Nodes:
  - PanelType: $XRAYR_PANEL_TYPE           # 面板类型：SSpanel, NewV2board, V2board, PMpanel, Proxypanel
    ApiConfig:
      ApiHost: $XBOARD_API_HOST
      ApiKey: $XBOARD_API_KEY
      NodeID: $XRAYR_NODE_ID
      NodeType: $XRAYR_NODE_TYPE           # 节点类型：V2ray, Trojan, Shadowsocks, Shadowsocks-Plugin
      Timeout: 8                           # API请求超时时间
      EnableVless: true                    # 是否启用Vless（仅适用于V2ray类型）
      EnableXTLS: true                     # 是否启用XTLS（适用于V2ray和Trojan类型）
      VlessFlow: "xtls-rprx-vision"        # Only support vless
      SpeedLimit: 0                        # 速度限制（Mbps），本地设置将覆盖远程设置，设置为0表示禁用
      DeviceLimit: 0                       # 设备限制，本地设置将覆盖远程设置，设置为0表示禁用
      RuleListPath:                        # 本地规则列表文件路径：/etc/XrayR/rulelist
    ControllerConfig:
      ListenIP: 0.0.0.0                    # 监听的IP地址
      SendIP: 0.0.0.0                      # 发送数据包的IP地址
      UpdatePeriodic: 8                    # 更新节点信息的时间间隔，单位：秒
      EnableDNS: false                     # 是否使用自定义DNS配置，请确保正确设置dns.json
      DNSType: AsIs                        # DNS策略：AsIs, UseIP, UseIPv4, UseIPv6
      DisableUploadTraffic: false          # 禁用上传流量到面板
      DisableGetRule: false                # 禁用从面板获取规则
      DisableIVCheck: false                # 禁用Shadowsocks的反回复保护
      DisableSniffing: false               # 禁用域名嗅探
      EnableProxyProtocol: false           # 是否启用代理协议
      AutoSpeedLimitConfig:
        Limit: 0                           # 警告速度。设置为0以禁用自动速度限制（Mbps）
        WarnTimes: 0                       # 连续多少次警告后限制用户。设置为0表示立即对超速用户进行限制。
        LimitSpeed: 0                      # 限制用户的速度（单位：Mbps）
        LimitDuration: 0                   # 限制持续时间（单位：分钟）
      GlobalDeviceLimitConfig:
        Enable: false                      # 是否启用用户的全局设备限制
        RedisAddr: 127.0.0.1:6379          # Redis服务器地址
        RedisPassword:                     # Redis密码
        RedisDB: 0                         # Redis数据库
        Timeout: 5                         # Redis请求超时时间
        Expiry: 60                         # 过期时间（秒）
      EnableFallback: false                # 仅支持Trojan和Vless类型
      FallBackConfigs:                     # 支持多个备用服务器配置
        - SNI:                             # TLS SNI（服务器名称指示），留空表示任意
          Alpn:                            # ALPN，留空表示任意
          Path:                            # HTTP路径，留空表示任意
          Dest: 80                         # 必填，备用服务器的目标，详细信息请参考 https://xtls.github.io/config/fallback/
          ProxyProtocolVer: 0              # 发送的PROXY协议版本，设置为0表示禁用
      EnableREALITY: true                  # Enable REALITY
      DisableLocalREALITYConfig: true      # disable local reality config
      REALITYConfigs:
        Show: true                         # Show REALITY debug
      CertConfig:
        CertMode: ${CERT_MODE}
        CertDomain: ${ACME_DOMAIN}
        CertFile: /root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.cer
        KeyFile: /root/.acme.sh/${ACME_DOMAIN}_ecc/${ACME_DOMAIN}.key
EOF

while true; do XrayR --config /xrayr.yml; sleep 5; done
