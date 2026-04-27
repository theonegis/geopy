#import "theme.typ": *

#show: doc => setup-base-fonts(
  doc,
  cjk-mono-family: ("JetBrains Maple Mono", "SF Mono SC"),
)

#show: course-theme.with(
  title: [第三章：GIS与空间数据基础],
  author: [谭振宇],
  institution: [西北大学城市与环境学院],
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
  toc-font-size: 20pt,
  toc-spacing: 0.6em,
  code-font-size: 0.85em,
)

#course-title-slide(
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
)

= 地理信息系统

== 什么是地理信息系统？

#text(0.9em)[
  我们生活在地球上，其衣食住行与所在地球的位置息息相关。用数据描述我们所在的地理空间环境，用信息技术去管理、分析和表达这些空间数据，建立数字化的地球，数字化的城市和乡村，这便是 *地理信息系统（GIS）*。

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [一般定义],
      [
        - 地理信息系统是指在计算机硬件、软件系统支持下，对关于现实世界（资源与环境）的各类空间数据及描述其空间特性的属性数据进行采集、储存、管理、运算、分析、显示和描述的技术系统。
      ],
    ),
    titled-card(
      [多学科交叉],
      [
        - 它作为集计算机科学、地理学、测绘遥感学、环境科学、城市科学、空间科学、信息科学和管理科学于一体的新兴边缘学科而迅速地兴起和发展起来的学科。
      ],
    )
  )
]

== GIS 的起源与发展

#text(0.85em)[
  GIS技术起源于计算机制图技术，经过半个多世纪的发展已经形成了从理论模型、专业软件到行业应用的普及。

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [丰富的采集方式],
      [
        从经典的大地测量到摄影测量，再到遥感技术、全球定位系统等，科技的发展带来了越来越方便和准确的空间数据采集方式。
      ],
    ),
    titled-card(
      [强大的分析能力],
      [
        GIS通过建立数据模型对数据进行存储、组织和管理，并提供大量成熟的空间分析算法，可以应用于各行各业解决相关问题。
      ],
    )
  )

  #v(0.5em)
  
  #bg-card[
    *核心与特色*：GIS的核心在于 *空间数据*（一切与空间位置相关的数据），GIS的重点在数据，特色在 *分析*，通过从空间数据中挖掘自然的，社会的规律，更好地服务于生产生活实践。
  ]
]

= 遥感技术

== 遥感技术与“3S”体系

#text(0.85em)[
  *“3S”技术* 合集：地理信息系统（GIS）、遥感技术（RS）、全球定位系统（GPS）。通过 RS 和 GPS 可以方便快捷地采集空间数据，而 GIS 则负责处理这些数据并提供决策支持。

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [广义遥感],
      [利用各种传感器从远离目标物体的任何地方，获取关于地表、海洋、气候等自然环境或人类活动相关的技术。],
    ),
    titled-card(
      [狭义遥感],
      [在远离目标和非接触条件下，通过人造卫星等飞行器收集地物目标电磁波信息，进行处理最后成像的感测技术。],
    )
  )

  #v(0.5em)
  #bg-card[
    *基本原理*：任何物体都有不同的电磁波反射或辐射特征，遥感技术通过收集这些辐射和反射的电磁波信息来识别目标。
  ]
]

== 遥感技术的分类

#text(0.9em)[
  根据工作平台、探测方式、应用领域的不同，可以对遥感技术进行多种划分：
  #align(center)[
    #image("figures/Remote-Sensing.png", width: 52%)
  ]
]

== 遥感技术的分类（补充）

#text(0.88em)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [按工作平台划分],
      [
        - 地面遥感
        - 航空遥感
        - 航天遥感
        \
        随着平台升高，探测范围越来越广。
      ]
    ),
    titled-card(
      [按探测方式划分],
      [
        - *主动式遥感*：传感器自主发射电磁波并接收反射（如普通雷达、干涉雷达、激光雷达）。
        - *被动式遥感*：直接接收目标物反射或发射的电磁波（如微波、红外、可见光）。
      ]
    ),
    titled-card(
      [按应用领域划分],
      [
        - 大气遥感
        - 资源遥感
        - 海洋遥感
        - 环境、地质、农业、林业遥感等
      ]
    )
  )
]

== 遥感影像

遥感传感器获取地物的电磁波信号，将其强弱信息放大，转化为数字信号进行存储，便成了 *遥感影像*。

#text(0.85em)[
  获取的遥感影像必然包含各种噪声误差，必须进行 *预处理*。光学遥感影像预处理的流程与产品级别定义密切相关：

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [L0 级预处理],
      [
        最原始的传感器观测得到的数字量化信号，未经任何校正。
      ]
    ),
    titled-card(
      [L1 级产品],
      [
        经过系统几何校正和初步的辐射定标，附带地理坐标与参考信息。
      ]
    )
  )
]

== 遥感影像产品级别与预处理流程

对于光学遥感影像的预处理，它通常包含几何校正、辐射校正、降噪和图像增强等。

#align(center)[
  #image("figures/Image-Preprocessing-Steps.pdf", width: 38%)
]

== 几何校正

传感器成像中，影像像素相对于真实目标可能会发生拉伸、偏移、扭曲等形变，这被称为 *几何畸变*。

#text(0.85em)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [几何粗校正],
      [
        （系统几何校正）：根据设备参数与地外辅助数据建立的空间位置关系，粗略修正传感器系统带来的畸变。
      ]
    ),
    titled-card(
      [几何精校正],
      [
        利用地面控制点建立像元坐标与目标地理坐标数学模型，实现跨坐标系的精密对准。
      ]
    ),
    titled-card(
      [正射纠正 (Ortho)],
      [
        结合地理参考数据和数字高程模型 (DEM)，消除因地形起伏和传感器侧视带来的影像变形。
      ]
    )
  )
]
经过校正与正射后，遥感影像将具有精确且符合地图投影规律的坐标信息。

== 辐射校正

辐射校正是指消除或改正由外界因素（平台、大气、地形）产生的辐射误差的过程。

#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [辐射定标],
      [
        - 建立传感器量化值（DN）与实际物理辐射亮度间的关联。
        - 目的：消除传感器本身产生的误差。
        - 输出结果：辐射亮度或大气顶层反射率 (TOA)。
      ]
    ),
    titled-card(
      [大气校正],
      [
        - 消除大气对阳光的吸收、散射引起的误差。
        - 将 TOA 反射率转换为地表真实反射率。
        - 输出产品（陆地）：地表反射率 (SR)。
        - 输出产品（水体）：遥感反射比 ($R_"rs"$)。
      ]
    )
  )
]

== 影像降噪与图像增强
除了物理校正外，提升影像表达质量往往需要后续处理方法：
#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [降噪处理],
      [
        - 去除周期系统噪声、扫描引起的条带结构或坏线等。
        - 常用技术主要包括空域滤波，或基于傅里叶变换进入频域做低通滤波，削弱周期干扰。
      ]
    ),
    titled-card(
      [图像增强],
      [
        - 通过某种变换扩大灰度差异与视觉效果。
        - *反差增强*：直方图均衡化拉伸。
        - *彩色增强*：多波段彩色合成（如真假彩色复合）。
        - *比值 / 空间滤波增强*：利用波段间运算来突显某类地物。
      ]
    )
  )
]

= 空间数据

== 两大空间数据模型

#text(0.9em)[
  在计算机和 GIS 内部，可以将空间数据划分为这两类截然不同的表达模型：
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [矢量数据（Vector）],
      [
        - 基于 *对象模型 (Object-based)*
        - 将世界抽象为无数的点、线、面
        - 记录明确的坐标边界与对象拓扑结构
        - 无极放大不失真
      ]
    ),
    titled-card(
      [栅格数据（Raster）],
      [
        - 基于 *场模型 (Field-based)*
        - 把空间事物视为连续的变量
        - 用规则的像元矩阵记录数据（本质是多维数组）
        - 细节受限于像素分辨率
      ]
    )
  )
]

== 矢量数据：概念与存储

#text(0.85em)[
  矢量数据结构通过纪录空间对象的 *地理坐标* 及空间关系来表达空间对象的位置。通过最简单的点、线、面空间实体即可应对各种复杂的现实地物。常用格式包括：

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [Shapefile、Geodatabase],
      [
        - *Shapefile*：由 ESRI 制定的行业标准规范文件（包含 `.shp`, `.shx`, `.dbf`）。
        - *Geodatabase*：基于文件目录(`.gdb`)或轻量级数据库(`.mdb`)构建的空间对象平台文件。
      ]
    ),
    titled-card(
      [GML、KML、GeoJSON],
      [
        - *GML*：由 OGC 提倡的底层 XML 标记标准。
        - *KML*：Google 用于交互与显示的开源标注格式。
        - *GeoJSON*：Web前端和后端程序广为使用的文本 JSON 格式。
      ]
    )
  )
]

== OGC简单要素规范（SFA）

#text(0.85em)[
  *OGC (Open Geospatial Consortium)* 是负责制定空间操作国际化标准的重要组织。

  *简单要素规范 (Simple Feature Access, SFA)*
  - *第一部分通用模型*：定义了基于几何与拓扑的空间几何体标准通用定义（例如点、多边形等）。
  - *第二部分 SQL 实现*：描述如何在数据库 SQL 中应用上面的几何规定。
  
  基于此，不同 GIS 厂商的系统能够使用同一套语义进行软件底层接口通讯和互联互通。
]

#align(center)[
  #image("figures/SFS.jpg", width: 68%)
]

== OGC：WKT 与 WKB 表示法

在 SFA 规范里，定义了两种标准的空间对象文本表达及二进制传输格式：

#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [WKT（Well-Known Text）],
      [
        一种容易肉眼辨识的文本标记语言，用清晰的文字（如 `POINT`, `POLYGON` 等）表达矢量坐标。例如表示个点可写作：
        ```text
        POINT (3 1)
        ```
      ]
    ),
    titled-card(
      [WKB（Well-Known Binary）],
      [
        与其对应的二进制格式描述体。WKB 因为体积小和易于机器转化，常被软件开发、数据库列级别存储系统、程序通讯接口所采用。
      ]
    )
  )
]

== 基本几何体的WKT表示

#v(0.5em)
#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: (left, center, left),
    stroke: none,
    table.hline(stroke: 1pt),
    [*要素类型*], [*几何体示例图*], [*WKT 字符串*],
    table.hline(stroke: 1pt),
    
    [点 (Point)],
    [#image("figures/SFA_Point.svg.png", height: 1.5em)],
    [`POINT (3 1)`],

    [线 (LineString)],
    [#image("figures/SFA_LineString.svg.png", height: 1.5em)],
    [`LINESTRING (3 1, 1 3, 4 4)`],

    [面 (Polygon)],
    [#image("figures/SFA_Polygon.svg.png", height: 1.5em)],
    [`POLYGON ((3 1, 4 4, 2 4, 1 2, 3 1))`],

    [带洞的面],
    [#image("figures/SFA_Polygon_with_hole.svg.png", height: 1.5em)],
    [`POLYGON ((3.5 1, 4.5 4.5, 1.5 4, 1 2, 3.5 1),`
     ` (2 3, 3.5 3.5, 3 2, 2 3))`],
     
     table.hline(stroke: 1pt),
  )
]

== Shapefile 与 GeoJSON

#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [Shapefile文件结构],
      [
        这是一个数据集（通常包含多个同名文件）：
        - `*.shp`：主文件，二进制，存储空间要素几何特征的变长度记录。
        - `*.shx`：索引文件，包含对应主文件记录距主文件头开始的偏移量。
        - `*.dbf`：属性表，包含主文件中每个空间要素的相关属性。
      ]
    ),
    titled-card(
      [GeoJSON格式规范],
      [
        基于 JavaScript Object Notation 表述。
        包含三个核心属性结构：
        - `type`：类型声明（例如 `Feature`）
        - `geometry`：具体的包含坐标与形态内容的数据树
        - `properties`：不固定的各类自定义地理属性键值对字典。
      ]
    )
  )
]

== GeoJSON 格式示例

#text(0.85em)[
  以下是一份包含点和线的 GeoJSON 特征集合：

  ```json
  {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature", "properties": {},
        "geometry": { "type": "Point", "coordinates": [ 101.84, 33.50 ] }
      },
      {
        "type": "Feature", "properties": {},
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [ 112.59, 38.68 ],
            [ 103.56, 29.13 ]
          ]
        }
      }
    ]
  }
  ```
]

== 栅格数据概览

#text(0.85em)[
  把空间现象视作连续体，对其按照细密网格阵列打散切分，赋予数值特征，本质为一个庞大的多维矩阵（`array`）。在栅格数据中，每个像元的行列号确定了地物所在的位置，像元值则表示空间对象的特征。

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [遥感波段的降维描述],
      [
        单波段图像为二维矩阵结构。多光谱为额外增加光谱深度的三维张量；包含时间维度的连续数据集则表现为四维模型。
      ]
    ),
    titled-card(
      [分辨率体系与金字塔],
      [
        除影像常见的空间精度外，还有刻画波段差异的光谱分辨率和重复周期探测的时间分辨率。软件常建立空间数据金字塔以提高海量数据渲染效率。
      ]
    )
  )
]

== 栅格影像：多维数组表示

#align(center)[
  #image("figures/RS-Image.png", width: 95%)
]

== 常见栅格数据格式速览

#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [基础栅格文件],
      [
        - *GeoTIFF* (`.tif`)：将参考信息的 Tag 附加到 TIFF 头信息结构中，也是目前遥感领域最为流行的分发文件载体。
        - *ENVI/Imagine*：老牌商业处理软件特制的专属文件或 `.hdr`/ `.img` 序列集。
      ]
    ),
    titled-card(
      [特定应用型分发],
      [
        - *压缩包形式*：由于遥感数据巨大（Jpeg 2000, MrSID, ECW, 及 SAFE 格式等）。
        - *激光点云 LAS*：符合国际摄影测量和遥感学会标准化规定的，记录着三维坐标、多次回波等各种属性的激光扫描序列点集文件格式。
      ]
    )
  )
]

== HDF 和 NetCDF 数据格式规范 

气象与综合科学数据集由于复杂度的需要而设计了更通用的文件自解析容器：
#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [HDF：组与数据集模型],
      [
        包含具有类文件夹（Groups）和实体数据集嵌套的多维模型。NASA 的 MODIS 与我国的风云卫星数据均为该体系下的定制版本分发。HDF5是最新版本。
      ]
    ),
    titled-card(
      [NetCDF：维度与变量],
      [
        通过维度（Dimension，例如经度、纬度、时间等），和与之绑定的数据变量（如速度，温度）与属性构成的一款在海洋气象中大范围使用的结构。
      ]
    )
  )
]

== HDF 数据模型与层次结构

HDF （Hierarchical Data Format）数据模型基于组（Groups）和数据集（Datasets）概念来组织数据。

#align(center)[
  #image("figures/HDF5-Structure.PNG", width: 55%)
]

== NetCDF 数据模型结构

NetCDF 是面向多维数组的科学数据集，由Dimensions, Variables, Attributes, Data 四个部分组成。

#align(center)[
  #image("figures/NetCDF-Structure.PNG", width: 90%)
]

= 空间参考与地图投影

== 地理坐标定位系统

#text(0.85em)[
  自然地球极度不规则，无法使用精确的数字建模。人们通过抽象提炼构建了参考实体（Geoid 与 Ellipsoid）将 3D 世界带入地理数据中。

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [基础抽象概念],
      [
        - *大地水准面*：静止的平均海水平面穿过大陆和岛屿形成的处处与重力方向正交的闭合曲面（高程基准面）。
        - *参考椭球*：能用严密数学公式和参数完整呈现其旋转边界特性的最简球形模型（例如 WGS 84系统）。
      ]
    ),
    titled-card(
      [大地基准 Datum],
      [
        将固定数学模型的几何球体相对于具体位置对标摆正。通过锚固不同的轴心和原点产生了参心基准（如北京 54，西安 80）与地心坐标系基准（如 WGS 84 和我国的CGCS2000）。
      ]
    )
  )
]

== 地图投影（一）

如何将三维球体上的经纬度展示到平整的电脑屏幕或是介质上，这就必须面临拉伸和压缩等导致的球面平展投影变形。

#text(0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [按照形变控制来分],
      [
        - *等角投影*：投影面上任意一点方位和形状在局部保持不变向。
        - *等积投影*：该面积经过换算依旧保持原来一致大，不失面。
        - *等距投影*：沿特定方向距离保持不变。
      ]
    ),
    titled-card(
      [按投射形式与表面分类],
      [
        假设光源通过地球透视包裹。
        - 圆锥投影（例如兰伯特圆锥投影）。
        - 圆柱投影（高斯-克吕格/墨卡托等）。
        - 方位投影（切点或弦平面投影）。
      ]
    )
  )
]

== 地图投影（二）：形式与表面

投影面包裹于基准椭球的不同部位呈现出不同的几何效果：

#align(center)[
  #image("figures/Projections.png", width: 75%)
]

== 我国标准与常用地图投影系统

我国由于地域特性的需要，选择保留精度与形变影响最小的典型模型：

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [等角横切圆柱投影],
    [
      *高斯 - 克吕格 (Gauss-Krüger)* 
      我国大中比例尺（1:50万以上）的地图使用。将中央子午线东西两侧各一定经差范围投影到圆柱面上。每隔经度 3° 或 6° 分带。
    ]
  ),
  titled-card(
    [等角正割圆锥投影],
    [
      *兰伯特投影 (Lambert)* 
      我国小比例尺（1:100万以下）的地图常使用。投影后纬线为同心圆圆弧，经线为同心圆半径。我国区域制图最主流选择。
    ]
  )
)

== 投影定义语法：PROJ4 与 WKT

各个系统或编程工具里流转这套标准投影参数常使用下面格式：

#text(0.75em)[
  *以 WGS 84 地理坐标系为例*：代码中也常常直接简写做一串 EPSG 识别代码，即 `EPSG: 4326`。

  #v(0.5em)
  ```text
  # 1. WKT 格式表示的 WGS 84 
  GEOGCS["WGS 84",
      DATUM["WGS_1984",
          SPHEROID["WGS 84",6378137,298.257223563, AUTHORITY["EPSG","7030"]],
          AUTHORITY["EPSG","6326"]],
      PRIMEM["Greenwich",0, AUTHORITY["EPSG","8901"]],
      UNIT["degree",0.017453292, AUTHORITY["EPSG","9122"]],
      AUTHORITY["EPSG","4326"]]

  # 2. PROJ4 格式表示的 WGS 84
  +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs
  ```
]

= 空间数据库管理

== 从关系模型到空间-关系模型

#text(0.85em)[
  主流商用基础系统原本构建在普通的文字型（行和列）数据表结构上，难以直接支持空间分析和查询。要想其有能力吞吐 GIS 中的矢量及庞大像素阵列，一般依赖专门针对其实施的空间数据扩展。

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    titled-card(
      [企业的企业级派系],
      [
        - *Oracle Spatial*：提供了对栅格和各类矢量数据进行存储和检索的功能。
        - *PostGIS*：在对象关系型数据库 PostgreSQL 上增加了存储管理空间数据的能力，开源免费且使用广泛。
      ]
    ),
    titled-card(
      [轻便文件级方案 (GPKG)],
      [
        *GeoPackage (GPKG)*
        直接依赖 OGC 和 SQLite 进行封装。允许不用任何服务进程单独被读写管理的小型数据库文件系统（`.gpkg`），相较于 Shapefile 更高效灵活。
      ]
    )
  )
]

== 空间对象在关系数据库表中的存储

无论是包含坐标串的复杂矢量要素对象还是空间属性，通过建立额外的属性实体引用与坐标字典可形成空间关系的绑定：

#align(center)[
  #image("figures/Database.pdf", width: 90%)
]

= 本章小结

== 核心知识梳理

#text(0.85em)[
  #titled-card(
    [知识核心要点],
    [
      - *地信理念*：GIS 和“3S”体系的核心特点及多学科应用。
      - *遥感影像*：理解主被动传感工作特性并熟悉光学科研通用辐射、几何校正和产品处理层级（L0-L3 等）。
      - *双数据表达体系*：区分离散对象模型的矢量 (点线面和拓扑)、以及二维连续场的栅格像元矩阵。
      - *常用的重点格式*：如矢量文件 WKB, GeoJSON, Shapefile，以及常见的栅格 TIFF, LAS，和复合科学数据集 HDF、NetCDF。
      - *空间参考系统*：明晰椭球体与基准面的含义（WGS84，国家 CGCS2000）；地图投影中的变形机制、圆柱与圆锥切割制图的不同选择及其 WKT 表达。
    ]
  )
]

== 思绪飞扬：课后思考

#text(0.95em)[
  建议回顾以下具有发散性场景的提问去稳固理解：

  1. *参考系统建立核心*：什么是参考椭球体？什么是大地基准面？这些概念从微观到宏观与地图投影有着怎样的直接依赖关系体系？
  2. *投影选型及适用性依据*：我国省市地图及国家级图册分别选用等角圆锥（兰伯特）还是横轴圆柱投影（高斯 - 克吕格）？这种取舍的核心原因是什么？
  3. *数据库的综合实操应用发散*：以目前的对象 - 关系系统为例，思考：栅格数据和矢量数据如何实现在同一个数据库内集成？请尝试自行设计一个用于“矢-栅一体化”的小型库表结构体系？
]

== 课程实践

#bg-card[以陕西省或西安市为研究区域，分四个小组分别研究如何下载Landsat、MODIS、Sentinel-1和Sentinel-2卫星影像数据，然后将下载方法进行分享。]