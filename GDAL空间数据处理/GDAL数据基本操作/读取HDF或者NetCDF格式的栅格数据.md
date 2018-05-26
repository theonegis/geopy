# 读取HDF或者NetCDF格式的栅格数据

作者：阿振

邮箱：tanzhenyugis@163.com

博客：<https://blog.csdn.net/theonegis/article/details/80089375>

修改时间：2018-05-17

声明：本文为博主原创文章，转载请注明原文出处

------

## HDF和NetCDF简介

### HDF

HDF（Hierarchical Data Format）由NCSA（National Center for Supercomputing Applications）设计提出，官方对其定义是：HDF5 is a unique technology suite that makes possible the management of extremely large and complex data collections.

HDF supports n-dimensional datasets and each element in the dataset may itself be a complex object.

HDF是对HDF数据模型，数据格式以及HDF库API等一系列技术的总称. HDF的最新版本是HDF5.

HDF数据模型基于组（groups）和数据集（datasets）概念：如果把HDF数据比作磁盘，那么组相当于文件夹，数据集相当于文件。组和数据集都有用户自定义的属性（attributes）.

MODIS影像，以及我国的风云卫星数据都适用HDF格式进行存储.

### NetCDF

NetCDF（Network Common Data Format）由UCAR（University Corporation for Atmospheric Research）设计提出，其官方的定义是：NetCDF is a set of software libraries and self-describing, machine-independent data formats that support the creation, access, and sharing of array-oriented scientific data.

NetCDF是面向多维数组的数据集，一个NetCDF文件主要是Dimensions, Variables, Attributes, Data 四个部分组成的：

- Dimension主要是对维度的定义说明，例如：经度，维度，时间等；
- Variables是对数据表示的现象的说明，例如：温度，湿度，高程等；
- Attributes是一些辅助的元信息说明，例如变量的单位等；
- Data是主要对现象的观测数据集。

NetCDF有两个数据模型：经典模型（NetCDF3之前模型）和增强模型（NetCDF4）

NetCDF最新版本是NetCDF4，NetCDF4的API接口建立在HDF5之上，和HDF5是兼容的.

如果搞大气研究的同学一定对NetCDF格式不陌生，接触到的大部分数据都是这种格式.

## HDF和NetCDF栅格数据集特点

HDF和NetCDF数据都可能包含数据子集（一个文件中包含多个子文件），我们需要找出需要的子集数据，然后就可以像普通的GeoTIFF影像那样进行读写和操作了.

## GDAL读取实例

下面的例子读取MODIS地标反射率（Surface Reflectance）数据中的第一波段，然后转为GeoTIFF进行存储.

我们首先使用`gdal.Open()`函数读取HDF数据，然后使用`GetSubDatasets()`方法取出HDF数据中存储的子数据集信息，该方法返回的结果是一个`list`，`list`的每个元素是一个`tuple`，每个`tuple`中包含了对子数据集的表述信息.

对于MODIS数据，`tuple`的第一个元素是子数据集的完整路径，所以我们取出该路径，然后使用`gdal.Open()`函数读取该子数据集.

最后我们使用`CreateCopy()`方法将该子数据集存储为GeoTIFF格式的数据。

所以，总结一下，我们读取HDF或者NetCDF数据子集的时候，最主要的是取出想要处理的子数据集的完整路径。然后就像读取普通GeoTIFF影像那样对子数据集进行读取就OK了.

```Python
from osgeo import gdal

root_ds = gdal.Open('example.hdf')
# 返回结果是一个list，list中的每个元素是一个tuple，每个tuple中包含了对数据集的路径，元数据等的描述信息
# tuple中的第一个元素描述的是数据子集的全路径
ds_list = root_ds.GetSubDatasets()

band_1 = gdal.Open(ds_list[11][0])  # 取出第12个数据子集（MODIS反射率产品的第一个波段）
arr_bnd1 = band_1.ReadAsArray()  # 将数据集中的数据转为ndarray

# 创建输出数据集，转为GeoTIFF进行写入
out_file = 'sr_band1.tif'
driver = gdal.GetDriverByName('GTiff')
out_ds = driver.CreateCopy(out_file, band_1)
out_ds.GetRasterBand(1).WriteArray(arr_bnd1)
out_ds.FlushCache()

# 关闭数据集
out_ds = None
root_ds = None
```



