以下是一份 **覆盖全链路、多场景的 Prometheus 详细架构图**，包含核心组件、数据流向、扩展模块及典型适配场景（如 Kubernetes 云原生环境、传统 IT 架构、自定义业务监控），并附带组件功能详解与 Mermaid 可视化代码，可直接生成图表用于文档或汇报。


### 一、Prometheus 详细架构图（Mermaid 可视化代码）
复制下方代码到 [Mermaid 在线编辑器](https://mermaid.live/)，可生成高清可视化图表，支持自定义配色和布局：
```mermaid
flowchart TD
    %% 样式定义（区分组件类型）
    classDef target fill:#e6f7ff,stroke:#1890ff,stroke-width:1px;  % 被监控目标
    classDef core fill:#f0fff4,stroke:#52c41a,stroke-width:1px;   % 核心组件
    classDef extend fill:#fff7e6,stroke:#fa8c16,stroke-width:1px;  % 扩展组件
    classDef alert fill:#fff1f0,stroke:#f5222d,stroke-width:1px;   % 告警组件
    classDef visualize fill:#fff0f6,stroke:#eb2f96,stroke-width:1px;% 可视化组件
    classDef storage fill:#f5f5f5,stroke:#717171,stroke-width:1px;  % 存储组件

    %% 1. 被监控目标层（按场景拆分）
    subgraph 被监控目标层 [1. 被监控目标层：指标产生源头]
        direction TB
        subgraph 云原生环境 [1.1 云原生环境]
            K8s_API[K8s API Server<br/>原生/metrics接口]:::target
            K8s_ETCD[ETCD集群<br/>ETCD Exporter]:::target
            K8s_Pod[业务Pod<br/>Prom Client SDK<br/>(Go/Java/Python)]:::target
            K8s_Node[K8s Node节点<br/>Node Exporter]:::target
            Container[容器运行时<br/>cAdvisor(采集容器CPU/内存)]:::target
        end
        subgraph 传统IT环境 [1.2 传统IT环境]
            Phys_Server[物理服务器<br/>Node Exporter]:::target
            VM[虚拟机(VMware/KVM)<br/>Node Exporter]:::target
            Middleware[中间件<br/>MySQL/Redis/Elasticsearch Exporter]:::target
            HTTP_Svc[HTTP服务<br/>Blackbox Exporter(可用性监控)]:::target
            DB[关系型数据库<br/>PostgreSQL Exporter]:::target
        end
        subgraph 自定义场景 [1.3 自定义监控场景]
            IoT[IoT设备<br/>自定义Exporter(传感器指标)]:::target
            Business[业务系统<br/>埋点指标(订单转化率/支付成功率)]:::target
            Job[定时任务<br/>Pushgateway(接收瞬时任务指标)]:::extend
        end
    end

    %% 2. 服务发现与配置层（动态定位目标）
    subgraph 服务发现与配置层 [2. 服务发现与配置层]
        direction TB
        SD_K8s[K8s Service Discovery<br/>(基于K8s API自动发现Pod/Node)]:::extend
        SD_Consul[Consul Service Discovery<br/>(传统微服务注册中心)]:::extend
        SD_File[File-based SD<br/>(静态配置文件，固定目标)]:::extend
        SD_DNS[DNS Service Discovery<br/>(通过DNS解析目标列表)]:::extend
        Config[Prometheus配置文件<br/>(scrape_configs: 采集间隔/标签过滤)]:::extend
    end

    %% 3. 核心采集与处理层（Prometheus Server核心）
    subgraph 核心采集与处理层 [3. 核心采集与处理层：Prometheus Server]
        direction TB
        Prom_Server[Prometheus Server]:::core
        subgraph Server_Modules [Server 内置模块]
            Scraper[数据采集器(Scraper)<br/>HTTP Pull 拉取/metrics接口]:::core
            TSDB[时序数据库(TSDB)<br/>本地存储：默认15天<br/>支持数据分片]:::storage
            Rule_Engine[规则引擎<br/>- 记录规则(预聚合指标)<br/>- 告警规则(触发告警条件)]:::core
            Query_Engine[查询引擎<br/>解析PromQL，查询时序数据]:::core
            Native_UI[原生Web UI<br/>(调试用：查询/告警状态)]:::core
        end
        Prom_Server --> Scraper & TSDB & Rule_Engine & Query_Engine & Native_UI
    end

    %% 4. 扩展存储层（长期存储/高可用）
    subgraph 扩展存储层 [4. 扩展存储层：解决本地TSDB局限]
        direction TB
        Remote_Write[Remote Write<br/>(指标写入远程存储)]:::extend
        Remote_Read[Remote Read<br/>(从远程存储读取历史数据)]:::extend
        subgraph LongTerm_Storage [长期存储方案]
            Thanos[Thanos<br/>多集群指标联邦+对象存储]:::storage
            Cortex[Cortex<br/>分布式存储，水平扩展]:::storage
            M3DB[M3DB<br/>高吞吐时序数据库]:::storage
        end
        Remote_Write --> LongTerm_Storage
        LongTerm_Storage --> Remote_Read
    end

    %% 5. 告警处理层（独立告警生命周期管理）
    subgraph 告警处理层 [5. 告警处理层：Alertmanager]
        direction TB
        Alertmanager[Alertmanager]:::alert
        subgraph Alert_Modules [Alertmanager 功能模块]
            Deduplication[去重<br/>合并重复告警]:::alert
            Grouping[分组<br/>按业务归类告警]:::alert
            Routing[路由<br/>按规则转发到接收器]:::alert
            Inhibition[抑制<br/>父告警触发时抑制子告警]:::alert
            Silencing[静默<br/>手动屏蔽指定告警]:::alert
        end
        Alertmanager --> Deduplication & Grouping & Routing & Inhibition & Silencing
        
        %% 告警接收器
        Receivers[告警接收器]:::alert
        Email[邮件(SMTP)]:::alert
        SMS[短信(第三方API)]:::alert
        IM[即时通讯(钉钉/企业微信/Slack)]:::alert
        Alert_Platform[企业告警平台(PagerDuty/自研)]:::alert
        Routing --> Receivers
        Receivers --> Email & SMS & IM & Alert_Platform
    end

    %% 6. 可视化与查询层（用户交互入口）
    subgraph 可视化与查询层 [6. 可视化与查询层]
        direction TB
        Grafana[Grafana 可视化平台]:::visualize
        subgraph Grafana_Features [Grafana 核心能力]
            Dashboard[自定义仪表盘<br/>(服务器/APM/业务监控)]:::visualize
            Multi_DS[多数据源集成<br/>Prometheus/Thanos/Elasticsearch/Loki]:::visualize
            Alert_Viz[告警可视化<br/>告警历史/触发状态]:::visualize
            Annotations[事件标注<br/>关联运维变更/版本发布]:::visualize
        end
        Grafana --> Dashboard & Multi_DS & Alert_Viz & Annotations
        
        %% 其他查询方式
        API[Prometheus HTTP API<br/>(供自研系统调用)]:::visualize
        CLI[promtool 命令行工具<br/>(调试PromQL/配置)]:::visualize
    end

    %% 7. 用户交互层（最终使用场景）
    subgraph 用户交互层 [7. 用户交互层：监控价值落地]
        SRE[运维/SRE<br/>- 监控SLA<br/>- 排查故障<br/>- 配置告警/存储]:::visualize
        Dev[开发工程师<br/>- 查看应用性能<br/>- 调试业务指标]:::visualize
        Product[产品/运营<br/>- 查看业务数据<br/>- 关联产品效果]:::visualize
    end

    %% 核心数据流向（按链路连接）
    %% 1. 目标→服务发现→Prometheus Server
    K8s_API & K8s_ETCD & K8s_Pod & K8s_Node & Container --> SD_K8s
    Phys_Server & VM & Middleware & HTTP_Svc & DB --> SD_Consul
    IoT & Business --> SD_File
    Job --> SD_DNS
    SD_K8s & SD_Consul & SD_File & SD_DNS --> Config --> Prom_Server
    
    %% 2. Prometheus Server→扩展存储
    Prom_Server --> Remote_Write
    
    %% 3. Prometheus Server→告警处理
    Rule_Engine --> Alertmanager
    
    %% 4. Prometheus Server→可视化查询
    Query_Engine & Remote_Read --> Grafana
    Query_Engine --> API & CLI
    
    %% 5. 可视化/告警→用户交互
    Grafana & API & CLI --> SRE & Dev & Product
    Email & SMS & IM & Alert_Platform --> SRE
```


### 二、架构图核心组件详解（按链路拆解）
#### 1. 被监控目标层：指标的“产生源头”
所有需监控的对象，核心是通过 **“Exporter 插件”或“原生 Metrics 接口”** 暴露可被 Prometheus 拉取的指标（格式为文本，包含“指标名+标签+数值+时间戳”），具体场景如下：

| 场景类型       | 典型目标                | 指标采集方式                          | 核心指标示例                          |
|----------------|-------------------------|---------------------------------------|---------------------------------------|
| 云原生环境     | K8s API Server/ETCD     | 原生暴露 `/metrics` 接口              | `apiserver_request_total`（API 请求数） |
| 云原生环境     | 业务 Pod                | Prom Client SDK（如 Go 的 `client_golang`） | `http_requests_total`（接口请求数）    |
| 传统 IT 环境   | 物理服务器/虚拟机       | Node Exporter                          | `node_cpu_usage`（CPU 使用率）         |
| 传统 IT 环境   | MySQL/Redis             | 专用 Exporter（如 MySQL Exporter）    | `mysql_connections`（数据库连接数）    |
| 自定义场景     | IoT 设备/定时任务       | 自定义 Exporter/Pushgateway           | `sensor_temperature`（传感器温度）     |

**特殊说明**：`Pushgateway` 用于解决“瞬时任务指标无法被拉取”的问题（如定时脚本执行完后进程退出），任务可主动将指标推送到 Pushgateway，再由 Prometheus 从 Pushgateway 拉取。


#### 2. 服务发现与配置层：解决“动态目标定位”
Prometheus 采用 **“Pull 模式”（主动拉取指标）**，但在云原生环境（如 K8s Pod 重启后 IP 变更）或动态扩缩容场景下，手动配置目标不现实，因此需要“服务发现”自动识别目标：

| 服务发现方式       | 适用场景                  | 核心逻辑                                  |
|--------------------|---------------------------|-------------------------------------------|
| K8s Service Discovery | K8s 集群内目标（Pod/Node） | 调用 K8s API，按标签筛选目标（如 `app=order-service`） |
| Consul Service Discovery | 传统微服务                | 从 Consul 注册中心获取服务列表              |
| File-based SD       | 固定 IP 目标（如物理机）  | 静态 JSON/YAML 文件配置目标 IP 和端口       |
| DNS Service Discovery | 基于 DNS 解析的目标       | 通过 DNS 域名解析获取目标 IP 列表           |

**配置文件核心作用**：通过 `scrape_configs` 定义采集规则，如：
- `scrape_interval: 15s`：每 15 秒拉取一次指标；
- `scrape_timeout: 10s`：拉取超时时间；
- `match_labels: {env: prod}`：只采集生产环境的目标。


#### 3. 核心采集与处理层：Prometheus 的“大脑”
Prometheus Server 是架构核心，负责 **“拉取指标→处理指标→存储指标→执行规则”**，内置 5 大模块：

1. **数据采集器（Scraper）**  
   按配置间隔，通过 HTTP 协议访问目标的 `/metrics` 接口，拉取指标并添加“采集时间戳”，支持自动重试和连接池管理。

2. **时序数据库（TSDB）**  
   本地存储时序数据，默认保留 15 天，核心特点：
  - 按“指标名+标签组合”作为唯一键（如 `http_requests_total{method="GET",path="/api/pay"}`）；
  - 支持高写入（每秒数十万条）和低延迟查询，数据按时间分片存储（默认 2 小时/片）；
  - 支持数据压缩（节省磁盘空间）和自动清理过期数据。

3. **规则引擎（Rule Engine）**  
   分为“记录规则”和“告警规则”：
  - **记录规则（Record Rule）**：预计算聚合指标（如 `sum(http_requests_total) by (service)`），减少查询时的计算压力，结果存储到 TSDB；
  - **告警规则（Alert Rule）**：定义告警触发条件（如 `node_cpu_usage > 90% 持续 5 分钟`），触发后生成告警事件，发送到 Alertmanager。

4. **查询引擎（Query Engine）**  
   解析 PromQL（Prometheus 专用查询语言），支持：
  - 聚合操作：`sum()`（求和）、`avg()`（平均值）、`max()`（最大值）；
  - 过滤操作：`==`（等于）、`!=`（不等于）、`=~`（正则匹配）；
  - 时间范围查询：`[5m]`（最近 5 分钟）、`[1h:1m]`（最近 1 小时，步长 1 分钟）；
  - 数学运算：`+`、`-`、`*`、`/`（如 `http_requests_total / 60` 计算每分钟请求数）。

5. **原生 Web UI**  
   基础调试界面（访问 `http://prometheus-server-ip:9090`），支持：
  - 输入 PromQL 查询指标，查看原始数据或简单图表；
  - 查看告警规则状态（Pending/Firing/Inactive）；
  - 查看采集目标健康状态（Up/Down）。


#### 4. 扩展存储层：解决“本地 TSDB 局限”
本地 TSDB 存在 **“存储容量有限”“数据无法跨实例共享”“高可用不足”** 等问题，需通过扩展存储方案解决：

| 扩展存储方案 | 核心优势                  | 适用场景                          |
|--------------|---------------------------|-----------------------------------|
| Thanos       | 1. 多 Prometheus 实例联邦；<br>2. 历史数据存对象存储（S3/GCS）；<br>3. 兼容 PromQL | 多集群监控、需长期存储（如 1 年） |
| Cortex       | 1. 分布式存储，水平扩展；<br>2. 支持多租户隔离；<br>3. 高可用设计 | 大规模集群（上万台服务器）、多租户场景 |
| M3DB         | 1. 高吞吐、低延迟；<br>2. 支持数据分片和副本；<br>3. 适合高频指标（如每秒采集） | 高频指标采集、高并发查询场景       |

**远程读写流程**：
- `Remote Write`：Prometheus 将采集的指标实时写入远程存储；
- `Remote Read`：用户查询历史数据时，Prometheus 从远程存储读取数据，与本地 TSDB 数据合并返回。


#### 5. 告警处理层：告警的“全生命周期管理”
Alertmanager 是独立于 Prometheus Server 的告警组件，避免 Server 因处理告警逻辑过载，核心功能是 **“让告警更精准、更易管理”**：

1. **去重（Deduplication）**  
   合并同一指标的重复告警（如同一 Pod 因网络波动导致多次触发“存活探针失败”告警，合并为一条），避免运维被重复通知轰炸。

2. **分组（Grouping）**  
   按“业务模块”或“层级”归类告警（如“订单服务的 3 个 Pod 下线”“订单服务数据库连接数满”合并为“订单服务异常组”），帮助运维快速定位根因。

3. **路由（Routing）**  
   按规则将告警转发到指定接收器，示例规则：
  - 生产环境核心服务（如支付服务）告警：发送“邮件+短信+企业微信”；
  - 测试环境告警：仅发送“钉钉”；
  - 非核心服务告警：仅发送“邮件”。

4. **抑制（Inhibition）**  
   父告警触发时，抑制依赖它的子告警（如“节点宕机”触发后，抑制该节点上所有 Pod 的“存活探针失败”告警），避免冗余告警干扰判断。

5. **静默（Silencing）**  
   手动设置“静默规则”（如“2024-10-01 10:00-12:00 屏蔽 `env=test` 的所有告警”）
