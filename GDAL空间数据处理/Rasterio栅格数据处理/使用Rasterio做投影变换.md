# 使用Rasterio做投影变换

作者：阿振

邮箱：tanzhenyugis@163.com

博客：<https://blog.csdn.net/theonegis/article/details/80089375>

修改时间：2018-06-11

声明：本文为博主原创文章，转载请注明原文出处

---

## 思路分析

在之前GDAL系列文章中的《[栅格数据投影转换](https://blog.csdn.net/theonegis/article/details/80543988)》提到过，做投影转换最重要的是计算数据在目标空间参考系统中的放射变换参数（GeoTransform）和图像的尺寸（行数和列数）。而且我们使用GDAL基本库自己写代码进行了计算。

在rasterio中提供了`calculate_default_transform`，可以直接计算目标系统中的放射变换参数和图像尺寸。

这样我们直接根据计算的结果更新目标文件的元信息即可。

## 代码实现

```Python
import numpy as np
import rasterio
from rasterio.warp import calculate_default_transform, reproject, Resampling
from rasterio import crs

src_img = 'example.tif'
dst_img = 'reproject.tif'

# 转为地理坐标系WGS84
dst_crs = crs.CRS.from_epsg('4326')


with rasterio.open(src_img) as src_ds:
    profile = src_ds.profile

    # 计算在新空间参考系下的仿射变换参数，图像尺寸
    dst_transform, dst_width, dst_height = calculate_default_transform(
        src_ds.crs, dst_crs, src_ds.width, src_ds.height, *src_ds.bounds)

    # 更新数据集的元数据信息
    profile.update({
        'crs': dst_crs,
        'transform': dst_transform,
        'width': dst_width,
        'height': dst_height,
        'nodata': 0
    })

    # 重投影并写入数据
    with rasterio.open(dst_img, 'w', **profile) as dst_ds:
        for i in range(1, src_ds.count + 1):
            src_array = src_ds.read(i)
            dst_array = np.empty((dst_height, dst_width), dtype=profile['dtype'])

            reproject(
                # 源文件参数
                source=src_array,
                src_crs=src_ds.crs,
                src_transform=src_ds.transform,
                # 目标文件参数
                destination=dst_array,
                dst_transform=dst_transform,
                dst_crs=dst_crs,
                # 其它配置
                resampling=Resampling.cubic,
                num_threads=2)

            dst_ds.write(dst_array, i)
```

