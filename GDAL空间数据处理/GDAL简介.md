# GDAL简介

作者：阿振

邮箱：tanzhenyugis@163.com

博客：<https://blog.csdn.net/theonegis/article/details/80089375>

修改时间：2018-05-13

声明：本文为博主原创文章，转载请注明原文出处

---

Geospatial Data Abstraction Library （[GDAL](http://www.gdal.org/)）是使用C/C++语言编写的用于读写空间数据的一套跨平台开源库。现有的大部分GIS或者遥感平台，不论是商业软件ArcGIS，ENVI还是开源软件GRASS，QGIS，都使用了GDAL作为底层构建库。

GDAL库由OGR和GDAL项目合并而来，OGR主要用于空间要素矢量矢量数据的解析，GDAL主要用于空间栅格数据的读写。此外，空间参考及其投影转换使用开源库 [PROJ.4](https://proj4.org)进行。

目前，GDAL主要提供了三大类数据的支持：栅格数据，矢量数据以及空间网络数据（Geographic Network Model）。

GDAL提供了C/C++借口，并且通过[SWIG](http://www.swig.org/)提供了Python，Java，C#等的调用借口。当我们在Python中调用GDAL的API函数时，其实底层执行的是C/C++编译的二进制文件。

GDAL不但提供了API借口方便开发人员自定义自己的功能，而且还提供了一系列实用工具（Command Line Tools）可以实现方便快速的空间数据处理。我们可以使用这些实用工具，结合Linux Shell脚本或者Windows批处理脚本进行大批量空间数据的批量处理。

GDAL 1.x版本以前，对于栅格和矢量数据的读写API借口设计是相对分离的，从2.x版本开始，栅格和矢量数据的API进行了集成，对开发者更加友好。我们这里的示例都是以2.x版本为例。



## 栅格数据组织

GDAL中使用dataset表示一个栅格数据（使用抽象类[GDALDataset](http://www.gdal.org/classGDALDataset.html)表示），一个dataset包含了对于栅格数据的波段，空间参考以及元数据等信息。一张GeoTIFF遥感影像，一张DEM影像，或者一张土地利用图，在GDAL中都是一个GDALDataset。

- 坐标系统（使用OGC WKT格式表示的空间坐标系统或者投影系统）

- 地理放射变换（使用放射变换表示图上坐标和地理坐标的关系）

- GCPs（大地控制点记录了图上点及其大地坐标的关系，通过多个大地控制点可以重建图上坐标和地理坐标的关系）

- 元数据（键值对的集合，用于记录和影像相关的元数据信息）

- 栅格波段（使用[GDALRasterBand](http://www.gdal.org/classGDALRasterBand.html)类表示，真正用于存储影像栅格值，一个栅格数据可以有多个波段）

- 颜色表（Color Table用于图像显示）

### 地理放射变换

放射变换使用如下的公式表示栅格图上坐标和地理坐标的关系：

$$
    \begin{matrix}
    X_{geo} = GT(0) + X_{pixel} * GT(1) + Y_{line} * GT(2) \\
    Y_{geo} = GT(3) + X_{pixel} * GT(4) + Y_{line} * GT(5) \\
    \end{matrix}
$$

（$X_{ge0}$, $Y_{ge0}$）表示对应于图上坐标（$X_{pixel}$, $Y_{line}$）的实际地理坐标。对一个上北下南的图像，GT(2)和GT(4)等于0， GT(1)是像元的宽度, GT(5)是像元的高度。（GT(0),GT(3)）坐标对表示左上角像元的左上角坐标。

 通过这个放射变换，我们可以得到图上所有像元对应的地理坐标。

参考资料：[GDAL Data Model](http://www.gdal.org/gdal_datamodel.html)

## 矢量数据组织

GDAL的矢量数据模型是建立在[OGC Simple Features](http://www.opengeospatial.org/standards/sfa)规范的基础之上的，OGC Simple Features规范规定了常用的点线面几何体类型，及其作用在这些空间要素上的操作。

OGR矢量数据模型中比较重要的几个概念：

- Geometry（[OGRGeometry](http://www.gdal.org/classOGRGeometry.html)类表示了一个空间几何体，包含几何体定义，空间参考，以及作用在几何体之上的空间操作，几何体和OGC WKB，WKT格式直接的导入导出）
- Spatial Reference（[OGRSpatialReference](http://www.gdal.org/classOGRSpatialReference.html)类表示了空间参考信息，各种格式的空间参考的导入导出）
- Feature（OGRFeature类表示空间要素，一个空间要素是一个空间几何体及其属性的集合）
- Layer（OGRLayer表示一个图层，一个图层中可以包含很多个空间要素）
- Dataset（GDALDataset抽象类表示一个矢量数据，一个Dataset可以包含多个图层）

总结一下：一个数据集（Dataset）可以包含多个图层（Layer），一个图层中可以包含多个空间要素（Feature），一个Feature由一个空间几何体（Geometry）及其属性构成

参考资料：[OGR Architecture](http://www.gdal.org/ogr_arch.html)