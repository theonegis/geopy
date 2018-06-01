# 打开Shapefile文件的正确方式

作者：阿振

邮箱：tanzhenyugis@163.com

博客：<https://blog.csdn.net/theonegis/article/details/80089375>

修改时间：2018-05-25

声明：本文为博主原创文章，转载请注明原文出处

------

## Shapefile文件简介

Shapefile文件是美国ESRI公司发布的文件格式，因其ArcGIS软件的推广而得到了普遍的使用，是现在GIS领域使用最为广泛的矢量数据格式。官方称Shapefile是一种用于存储地理要素的几何位置和属性信息的非拓扑简单格式。

一般地，Shapefile文件是多个文件的集合，至少包括一个shp，shx以及dbf文件。

- shp主文件使用变长记录存储空间几何数据，支持点，线，面等多种几何类型。
- shx索引文件用于存储几何数据的索引信息，包含对主文件中每个记录长度的描述（注意不是空间索引）
- dbf表文件是使用dBase数据库表文件进行空间属性数据存储的文件

所以，我们如果要自己完全从底层写代码解析Shapefile文件的话，需要根据shx文件中的信息读取shp中的二进制数据并转化为几何对象，然后再读取dbf表格，将属性添加到几何对象上就完成了对一个Shapefile文件的解析.

英文好的同学，请转移到这里：[ESRI Shapefile Technical Desc](https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf)

## GDAL中矢量数据组织

GDAL中的栅格数据使用`OGRDataSource`表示(`OGRDataSoruce`是抽象类`GDALDataset`的子类)，一个`OGRDataSource`中包含一个或多个`OGRLayer`层，每个图层中又包含一个或者多个`OGRFeature`要素， 每个要素包含一个`OGRGeometry`及其关联的属性数据。

GDAL中的空间要素模型是按照OGC的Simple Feature规范实现的，有兴趣的童鞋可以参考官方文档：[Simple Feature Access](http://www.opengeospatial.org/standards/sfa)

## 使用GDAL打开Shapefile文件

下面的例子演示了如何打开Shapefile文件，并读取空间要素及其属性。 实现代码如下：

```Python
from osgeo import ogr
import json

data = ogr.Open('USA_adm1.shp')  # 返回一个DataSource对象
layer = data.GetLayer(0)  # 获得第一层数据（多数Shapefile只有一层）

extent = layer.GetExtent()  # 当前图层的地理范围
print(f'the extent of the layer: {extent}')

srs = layer.GetSpatialRef()
print(f'the spatial reference system of the data: {srs.ExportToPrettyWkt()}')

schema = []  # 当前图层的属性字段
ldefn = layer.GetLayerDefn()
for n in range(ldefn.GetFieldCount()):
    fdefn = ldefn.GetFieldDefn(n)
    schema.append(fdefn.name)
print(f'the fields of this layer: {schema}')

features = []  # 图层中包含的所有feature要素
for i in range(layer.GetFeatureCount()):
    feature = layer.GetFeature(i)
    features.append(json.loads(feature.ExportToJson()))

print(f'the first feature represented with JSON: {features[0]}')
```

