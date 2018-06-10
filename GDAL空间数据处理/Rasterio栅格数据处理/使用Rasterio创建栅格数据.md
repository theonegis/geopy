# 使用Rasterio创建栅格数据

作者：阿振 邮箱：tanzhenyugis@163.com

博客：<https://blog.csdn.net/theonegis/article/details/80089375>

修改时间：2018-06-09

声明：本文为博主原创文章，转载请注明原文出处

---

## 方法描述

使用Rasterio创建并写入栅格数据比GDAL还简单一些，基本使用到两个函数：

- `rasterio.open()`
- `write()`

在`open()`函数当中，我们可以像GDAL中的`Create()`方法一样，设置数据类型，数据尺寸，投影定义，仿射变换参数等一系列信息

另外，Rasterio中的数据集提供了一个`profile`属性，通过该属性可以获取这些信息的集合，这样我们读取源数据文件的时候获得该属性，然后对源数据进行处理，再创建写入文件的时候，在`open()`函数中传入`profile`即可，这样就有点像GDAL中的`CreateCopy()`函数。但是Rasterio比`CreateCopy()`更为强大的地方是：你可以修改`profile`以适配你的目标文件，而`CreateCopy()`通过提供的原型文件进行创建，无法直接对这些元信息进行修改。

## 代码示例

下面的代码通过读取一个三个波段的Landsat影像，计算NDVI指数，然后创建输出并保存的例子。

注意计算NDVI的时候对于除数为0的处理。

```Python
import rasterio
import numpy as np

# 读入的数据是绿，红，近红外波段的合成数据
with rasterio.open('LC08_122043_20161207.tif') as src:
    raster = src.read()  # 读取所有波段
    # 源数据的元信息集合（使用字典结构存储了数据格式，数据类型，数据尺寸，投影定义，仿射变换参数等信息）
    profile = src.profile
    # 计算NDVI指数（对除0做特殊处理）
    with np.errstate(divide='ignore', invalid='ignore'):
        ndvi = (raster[2] - raster[1]) / (raster[2] + raster[1])
        ndvi[ndvi == np.inf] = 0
        ndvi = np.nan_to_num(ndvi)
    # 写入数据
    profile.update(
        dtype=ndvi.dtype,
        count=1
    )
    '''也可以在rasterio.open()函数中依次列出所有的参数
    with rasterio.open('NDVI.tif', mode='w', driver='GTiff',
                       width=src.width, height=src.height, count=1,
                       crs=src.crs, transform=src.transform, dtype=ndvi.dtype) as dst:
    '''
    with rasterio.open('NDVI.tif', mode='w', **profile) as dst:
        dst.write(ndvi, 1)
```

