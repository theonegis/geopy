#import "theme.typ": *

#show: doc => setup-base-fonts(
  doc,
  cjk-mono-family: ("JetBrains Maple Mono", "SF Mono SC"),
)

#show: course-theme.with(
  title: [第六章：栅格数据处理进阶],
  author: [谭振宇],
  institution: [西北大学城市与环境学院],
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
  title-font-size: 1.3em,
  toc-font-size: 18pt,
  toc-spacing: 0.2em,
  code-font-size: 0.9em,
)

#course-title-slide(
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
)

= 遥感数据处理

== 学习目标

#titled-card(
  [核心学习目标],
  [
    - 遥感影像多波段叠加和波段运算
    - 遥感图像拼接和裁剪
    - 栅格数据投影变换和格式转化
    - 栅格数据和NumPy数组之间的转化
    - 基于NumPy的栅格波段运算
    - 基于GDAL命令行工具和相应API进行栅格数据处理
  ]
)

== 遥感影像分级处理

当卫星数据中心接收到观测数据以后，会对数据进行不同程度的处理：

#text(0.9em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [Level-1 级别],
      [大多经过了辐射定标和几何校正，具有基本的空间参考信息。原始 DN (Digital Number) 值需要用户自行进行大气校正。]
    ),
    titled-card(
      [Level-2 级别],
      [大部分经过了大气校正。例如常用的地表反射率数据（Surface Reflectance）就属于二级以上产品。]
    )
  )

  #bg-card[
    不论下载哪个级别的数据，*波段叠加*、*影像裁剪* 和 *影像拼接* 等常规预处理通常都是必不可少的。结合 GDAL 命令行工具与 Python 可以实现高效批处理。
  ]
]

== Landsat 8 影像处理背景

以下案例使用从 EarthExplorer 下载的 Landsat 8 影像，以*西安市土地利用监测*为例：

- Landsat 8 影像存档通常按照 *WRS-2* (Worldwide Reference System) 坐标系分瓦片 (Tile) 存储。
- 每个瓦片使用 *Path* 和 *Row* 的组合编号。
- 叠加西安市矢量边界与 WRS-2 网格可以发现，西安市跨越了三张瓦片区域：`P127R036`，`P127R037` 以及 `P126R036`。

因此，处理整幅西安市影像通常分为几个关键步骤：*波段叠加 -> 拼接 -> 裁剪*。

== 西安市在由于WRS2坐标系下的位置

#align(center)[
  #image("figures/西安市.png", width: 60%)
]

#text(0.8em)[
  *图示：*西安市边界与涉及的 P127R036、P127R037、P126R036。瓦片之间有重叠区域。
]


= 波段叠加

== 为什么要进行波段叠加 (Band Stacking)？

Landsat 8 Level-1 数据在分发时，包含各个独立波段的文件。

#titled-card(
  [波段叠加的目的],
  [
    为了图像可视化或后续处理的便利，我们往往需要把单个波段的图像进行叠加（Band Stacking），使之合并为一个包含多波段（如蓝、绿、红、近红外等）的单一文件。
  ]
)

#titled-card(
  [使用工具],
  [
    GDAL 库自带了大量高级处理脚本，其中 `gdal_merge.py` 就可以用来进行波段叠加和影像拼接操作。
  ]
)

== 执行环境准备与路径获取

通常 `gdal_merge.py` 并不是系统直接可运行的 `.exe`，而是一个 Python 脚本：

#text(0.95em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [寻找脚本路径 (PowerShell)],
      [```powershell
      # 激活对应的环境
      conda activate osgeo

      # 获取 gdal_merge.py 的完整路径
      (Get-Command gdal_merge.py).Path
      ```]
    ),
    titled-card(
      [Python 执行语法],
      [
        找到全路径后，应当通过指定 `python` 来运行它：

        ```bash
        python [gdal_merge.py全路径] [参数]
        ```
      ]
    )
  )

  #bg-card[
    注意：在 Windows 中如果直接输入 `gdal_merge.py` 执行，可能会导致使用 PyCharm 等编辑器打开，而不是直接运行脚本。而在 Mac/Linux 则可以直接运行。
  ]
]

== gdal_merge.py 核心参数

```bash
gdal_merge.py [-o out_filename] [-of out_format] [-co NAME=VALUE]*
    [-ps pixelsize_x pixelsize_y] [-tap] [-separate] [-q] [-v] [-pct]
    [-ul_lr ulx uly lrx lry] [-init "value [value...]"]
    [-n nodata_value] [-a_nodata output_nodata_value]
    [-ot datatype] [-createonly] input_files
```

这里要实现波段叠加功能，主要关注以下参数：

- `-separate`：*核心参数！*指示多个输入文件作为多波段依次存储在一个文件里。
- `-o out_filename`：输出文件名称。
- `input_files`：需要叠加的单个波段文件列表（按顺序排列）。

== 波段叠加操作演示

下面演示将 `P127R037` 瓦片的第2、3、4、5波段叠加：

```bash
conda activate osgeo

# 执行波段叠加
python C:/Users/TheOne/Applications/miniconda3/envs/osgeo/Scripts/gdal_merge.py \
    -separate \
    -o 127037.tif \
    LC08..._B2.TIF \
    LC08..._B3.TIF \
    LC08..._B4.TIF \
    LC08..._B5.TIF
```

#align(center)[
  #image("figures/波段叠加.png", width: 75%)
]


= 影像拼接

== 影像拼接 (Mosaic) 简介

拼接是指对具有部分重叠区域的多景影像进行处理，合并为覆盖整个研究区的全景影像。

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [注意事项],
    [基于 GDAL 的脚本不会对重叠区域进行复杂的“匀色”处理，通常是按输入顺序产生层叠效应（后输入的覆盖前面的）。可以通过改变输入文件的先后顺序来优化缝合处的表现。]
  ),
  titled-card(
    [可用工具],
    [
      - `gdal_merge.py` 脚本
      - `gdalwarp` 命令行二进制程序
    ]
  )
)

== 使用 gdal_merge.py 拼接

与波段叠加不同，拼接时*不要使用* `-separate` 参数。这样会让多幅影像并在同一个二维平面和对应波段中。

```bash
python gdal_merge.py -o XiAn-202108-Mosaic.tif \
    -n 0 -a_nodata 0 \
    .\LC08...126036_..._T1\126036.tif \
    .\LC08...127037_..._T1\127037.tif \
    .\LC08...127036_..._T1\127036.tif
```

*关键参数解析：*
- `-n 0`：输入影像中作为无效值（NoData）忽略的值。
- `-a_nodata 0`：输出影像结果中的 NoData 值。
- 接着列举所有需要被拼接的输入文件。

== 使用 gdalwarp 拼接

`gdalwarp` 是一个用 C++ 写的重采样和扭曲工具。不仅支持影像拼接，还具有更丰富的功能。

```bash
gdalwarp.exe \
    -srcnodata 0 \
    -dstnodata 0 \
    .\LC08...126036_..._T1\126036.tif \
    .\LC08...127037_..._T1\127037.tif \
    .\LC08...127036_..._T1\127036.tif \
    XiAn-202108-Mosaic.tif
```

*关键参数：*
- `-srcnodata 0` 和 `-dstnodata 0`：分别设置输入与输出的 NoData 值。
- 输入文件列表接着写，*最后一个参数是输出文件路径*。注意这个语法与 `gdal_merge.py` 有轻微不同，并不使用 `-o`。

== GDAL 命令行二进制 VS. Python 脚本

#text(0.9em)[
  在使用 GDAL 时，理清工具种类避免命令报错：

  #titled-card(
    [命令行程序（二进制）],
    [如 `gdalwarp`, `gdalinfo`, `gdal_translate`。在 PATH 中可直接调用。Windows 下加不加 `.exe` 都可以。Mac/Linux 原生无扩展名。]
  )

  #titled-card(
    [Python 脚本],
    [如 `gdal_merge.py`, `gdal_calc.py`。
    - Mac/Linux 且加了运行权限并在 PATH 中：可直接执行。
    - Windows：建议带上 `python` 解释器前缀以及完整路径以确保不出错：\ `python C:\...\gdal_merge.py args`。]
  )
]

== 拼接效果展示

最终将这三个被波段叠加过的影像进行接边操作：

#align(center)[
  #image("figures/影像拼接.png", width: 55%)
]

#text(0.8em)[
  注：图中右上方块（P126R036）拍摄于 8 月 27 日，其它拍摄于 8 月 2 日，导致拼接后能看到边缘颜色有一点差异。
]

= 影像裁剪

== 影像裁剪场景

剪裁（Clipping 或 Cropping）可以极大减小不必要的数据量。常用于只分析特定研究区的场合。通常有两种情形：

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [基于矢量边界],
    [
      已有研究区域的 Shapefile 数据，想沿着边界进行掩膜并裁剪影像矩阵。
    ]
  ),
  titled-card(
    [基于经纬度包围框],
    [
      只是想截取研究区域的四角坐标（Bounding Box，又称 MBR）。这更简单直接。
    ]
  )
)

裁剪的主要工具依然推荐极为高效的 *`gdalwarp`*。


== 场景1：基于矢量数据裁剪

```bash
gdalwarp -cutline .\XiAn.shp \
          -crop_to_cutline \
          -srcnodata 0 -dstnodata 0 \
          .\XiAn-202108-Mosaic.tif .\XiAn-202108-AOI.tif
```

*核心参数：*
- `-cutline`：后接矢量边界文件路径。
- `-crop_to_cutline`：强制输出结果图像的范围（BBox）缩小到能恰好包围这个矢量的长方形区域并用这个矢量形状进行掩膜裁剪。

#align(center)[
  #image("figures/影像裁剪-1.png", width: 75%)
]

== 场景2：基于经纬度范围裁剪


```bash
gdalwarp -te_srs EPSG:4326 \
          -te 107.61 33.67 109.80 34.78 \
          -srcnodata 0 -dstnodata 0 \
          .\XiAn-202108-Mosaic.tif .\XiAn-202108-MBR.tif
```

*核心参数：*
- `-te xmin ymin xmax ymax`：确定输出范围框。
- `-te_srs EPSG:4326`：指明 `-te` 中的坐标参考系是 WGS 84（经纬度）。如果本身就是同坐标系则不需要。


#align(center)[
  #image("figures/影像裁剪-2.png", width: 75%)
]


= 波段运算

== 栅格地图代数

像计算各种植被指数之类的操作是非常普遍的栅格计算。

#text(0.85em)[
  以归一化植被指数 (NDVI) 为例：
  $
  "NDVI" = ("NIR" - "Red") / ("NIR" + "Red")
  $

  #titled-card(
    [gdal_calc.py 计算工具],
    [
      它是基于 NumPy 进行底层支持的一个轻便表达式计算脚本，可以进行任意自定义的像素级算术运算：
      ```bash
      gdal_calc.py --calc="表达式" --outfile="输出" \
                   [-A filename] [--A_band=n] ...
      ```
    ]
  )
]

== gdal_calc.py 计算 NDVI 示范

假设之前提取了 `XiAn-202108-AOI.tif`（包含4个波段），并得知第四波段是近红外，第三波段是红波段：

```bash
python gdal_calc.py \
    -A .\XiAn-202108-AOI.tif --A_band=4 \
    -B .\XiAn-202108-AOI.tif --B_band=3 \
    --outfile=XiAn-NDVI.tif \
    --calc="(A-B)/(A+B+1e-8)" \
    --NoDataValue=0 --hideNoData --type=Float32 --quiet
```

*注意点：*
- `-A` 和 `-B` 可以是同一个文件。
- `--calc` 里的字母必须对应大写的变量标识。分母加入了极其微小的 `1e-8` 有效避免分母出现纯 `0` 报错。

== NDVI 计算结果展示

得到新的 NDVI 单波段浮点数栅格，其中植被旺盛的区域 NDVI 值较高：

#align(center)[
  #image("figures/波段运算.png", width: 70%)
]



= 投影变换 (Reprojection)

== 重投影的原因


源影像与矢量分析数据或其它数据集的空间参考往往不一致：

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [常见参考系],
    [
      - WGS 84 (EPSG:4326) —— 全球通用的经纬度
      - Web Mercator (EPSG:3857) —— 网页底图常用
      - CGCS 2000 (EPSG:4490) —— 中国常用的地理坐标
    ]
  ),
  titled-card(
    [投影目的],
    [基于平面坐标计算面积、长度或为了保持其他图层重合，必须统一所有的空间参考。]
  )
)


== 使用 gdalwarp 进行投影变换


`gdalwarp` 命令也天然支持强大的投影重采样。

```bash
# 将 XiAn-202108-AOI 重投影至中国国家 2000 大地坐标系
gdalwarp -t_srs EPSG:4490 \
          -dstnodata 0 \
          .\XiAn-202108-AOI.tif \
          .\XiAn-202108-AOI-2000.tif
```

*核心参数：*
- `-t_srs EPSG:4490`：强制指定目标的 Target Spatial Reference System（坐标参考系）。

== 查看影像变换后的元数据

#text(0.75em)[
  对重投影前后的 TIF 分别执行 `gdalinfo` 就可以看到栅格行列号（分辨率像素大小）和顶点坐标已经发生了巨大变化：

  ```bash
  gdalinfo XiAn-202108-AOI-2000.tif
  ```
]

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  image("figures/影像投影信息-1.png"),
  image("figures/影像投影信息-2.png")
)
#text(0.8em, align(center)[*图示：原影像与 CGCS2000 投影影像的几何差异*])


= 格式转换

== 栅格格式转换工具

某个特定的行业软件只接受他们内置或者专有格式进行处理；而最常见的通用分发格式一般是 GeoTIFF。

#titled-card(
  [`gdal_translate` 工具],
  [
    它是专门用于数据格式转换的 GDAL 二进制命令。不仅支持极为广泛的几十种目标格式转写，还能够执行诸如灰度转换、像素值标度缩放（Scaling）等内部调整：
    ```bash
    gdal_translate -of ENVI \
                    .\XiAn-202108-AOI.tif \
                    .\XiAn-202108-AOI-ENVI.dat
    ```
  ]
)


== 格式转换参数与结果

```bash
gdal_translate -of ENVI \
                .\XiAn-202108-AOI.tif \
                .\XiAn-202108-AOI-ENVI.dat
```

*核心参数解析：*
- `-of ENVI`：指示输出为 ENVI 软件专属格式。

*执行结果：*
当前目录下会生成 `XiAn-202108-AOI-ENVI.dat`（存储像素二进制值）和 `XiAn-202108-AOI-ENVI.hdr`（相关的 ASCII 编码元数据，描述头文件信息）两个文件体。


= 栅格数据插值

== 从离散数据到栅格表面


栅格数据插值旨在通过已知的离散数据点（如气象站观测温度）推算出未知区域的像元值，生成连续的“表面”。

#titled-card(
  [常见 GIS 栅格插值类型],
  [
    - 最近邻插值 (Nearest Neighbor)
    - 反距离加权插值 (IDW)
    - 克里金插值 (Kriging)
  ]
)
GDAL 提供了专用的 `gdal_grid` 命令行。


== 使用 gdal_grid 的反距离加权插值

```bash
gdal_grid -a invdist:power=2.0:smoothing=1.0 \
          -oo X_POSSIBLE_NAMES=LONG \
          -oo Y_POSSIBLE_NAMES=LAT \
          -zfield TEMPERATURE \
          StationTemperature.csv GridedTemperature.tif	
```

*核心参数：*
- `-a invdist:power=2.0`：设置插值算法与幂参数（反距离权重）。
- `-oo`：打开输入的 CSV 文件时，通过列名推测哪些字段当做经纬度坐标（LONG / LAT）。
- `-zfield`：指定输入文件中应当被估算插值的数值列（如温度 TEMPERATURE）。


= 栅格数据与多维数组

== 多维数组与 Dataset 的联系

#text(0.9em)[
  遥感影像的数据结构在本质上和 NumPy 的 $n$-维数组十分相似。

  #titled-card(
    [维度的对应],
    [
      - 长和宽各占据一个空间维度（行数、列数）。
      - 多波段就是第三个叠加层次（通道深度）。
      - 如果是时序卫星数据序列，甚至包含时间维度（四维）。
    ]
  )

  #bg-card[
    GDAL 库使用底层的 C++ 对象 `gdal.Dataset` 管理数据元信息。我们时常需要利用它的 API 将特定像元获取并转换为 Python 中 `np.ndarray` 的等效多维数组，进而利用 SciPy 或 sklearn 快速分析。
  ]
]

== Python API：读取 TIF 为 NumPy 数组

#text(0.8em)[
  ```python
  import numpy as np
  from osgeo import gdal, gdal_array

  fn = r"C:\...\XiAn-202108-AOI.tif"

  # 方法一：先打开 Dataset，后读取单个波段或全量波段的 Array
  ds = gdal.Open(fn)
  im = ds.ReadAsArray()               # -> numpy.ndarray 形状 (4, 3938, 6677)
  
  # 也可只读取指定序号为 1 的单独波段
  im1 = ds.GetRasterBand(1).ReadAsArray() 
  print(im1.shape)                    # -> numpy.ndarray 形状 (3938, 6677)

  # 方法二：如果只是简单的纯 NumPy 获取，可跳过 Dataset 实例化过程
  im2 = gdal_array.LoadFile(fn)
  ```
  *注意点：*
  读取到 `ndarray` 后，空间投影（Transform 和 Projection）元信息并没随数组保留在内存中，它只是纯数字。
]

== Python API：NumPy 数组转存至 GeoTiff

#text(0.8em)[
  将处理好的数组放回成含有地理信息的 GeoTiff，步骤较为严格：

  ```python
  def save2img(fname, array, driver='GTiff', prototype=None,
               transform=None, projection=None, nodata=None):
      # 创建对应的写入器扩展引擎
      driver = gdal.GetDriverByName(driver)

      if prototype:
          ds = driver.CreateCopy(fname, prototype)
      else:
          # 如无原型参照，需重建其行列数范围以及传入所需的 Transform 六参数与 Projection
          ds = driver.Create(fname, array.shape[1], array.shape[0], 
                             1, gdal.GDT_Float32)
          ds.SetGeoTransform(transform)
          ds.SetProjection(projection)

      ds.GetRasterBand(1).WriteArray(array)
      if nodata is not None: ds.GetRasterBand(1).SetNoDataValue(nodata)
      ds.FlushCache()
  ```
]

= 基于 NumPy 的栅格算术分析

== 手动撰写 NDVI 阵列操作

#text(0.8em)[
  除了用 `gdal_calc.py` 自动化，使用 Python 脚本能进行任何高级定制处理：
  ```python
  import numpy as np
  from numpy import ma
  from osgeo import gdal
  gdal.UseExceptions()

  ds = gdal.Open('XiAn-202108-AOI.tif')
  nodata = ds.GetRasterBand(1).GetNoDataValue()

  # 将红光波段与近红外波段载入为浮点数
  red = ds.GetRasterBand(3).ReadAsArray().astype(float)
  nir = ds.GetRasterBand(4).ReadAsArray().astype(float)

  # 合成一个排除所有 NoData 的掩膜布尔数组
  mask = np.logical_or(red == nodata, nir == nodata)

  # 利用 NumPy 掩膜广播求植被指数，并收束阈值夹点
  ndvi = (nir - red) / (nir + red + 1e-8)
  ndvi = np.clip(ndvi, -1, 1)
  ndvi[mask] = -9999
  ```
]

== 基于矢量边界的多波段批处理结合

#text(0.8em)[
  前述拼接、裁剪在 Python 环境下同样可以使用极为优雅的 API `gdal.Warp()`，从而将命令行动作封箱进循环批处理中：

  ```python
  inputs = [
      '126036.tif',
      '127036.tif',
      '127037.tif'
  ]
  boundary = 'XiAn.shp'
  output = 'XiAn-202108-WGS84.tif'

  # 第一个参数是输出名，后接输入列表文件序列；
  # Python 包装将许多零碎参数打包为命名赋值（kwargs）
  gdal.Warp(output, inputs, 
            cutlineDSName=boundary, cropToCutline=True,
            srcNodata=0, dstNodata=0, 
            dstSRS='EPSG:4326') 
  ```

  使用 `Warp()` 不仅避免被终端阻塞，还能捕捉并打印异常方便排查。
]


= 课后练习

== 本章小结

#titled-card(
  [命令行基石],
  [
    - `gdal_merge.py` 和 `gdalwarp` 涵盖了数据格式大一统的操作。
    - `gdalinfo` 掌握空间数据的基本视图诊断。
    - `gdal_translate` 自由驰骋在多样化商用软件格式要求中。
  ]
)

#titled-card(
  [Python 生态结合],
  [
    借力 GDAL 和 NumPy 打通遥感应用的全链路开发，实现灵活的深度自定义栅格计算范式。
  ]
)


== 牛刀小试

#titled-card(
  [作业 1：基于多条件组合栅格评价模型],
  [
    提取 `slope.tif` （高程坡度模型）和 `landuse.tif` （土地利用）。开发一个利用 NumPy 计算两者不同阈值计分累进的农田适宜度栅格得分（5级赋分）。
  ]
)

#titled-card(
  [作业 2：自主数字高程基础表面开发],
  [
    对于某个数字高程模型 DEM 栅格数组，不借助外部专业库的情况下，通过读取周边窗口 $3 * 3$ 像元，手写实现其对应区域的 *坡度 (Slope)* 与 *坡向 (Aspect)* 提取函数，并使用 `driver.Create` 生成新文件以便导入 QGIS 等软件内验证准确度。
  ]
)
