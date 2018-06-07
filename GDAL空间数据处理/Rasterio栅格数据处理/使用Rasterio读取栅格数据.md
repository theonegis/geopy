# 使用Rasterio读取栅格数据 

作者：阿振 邮箱：tanzhenyugis@163.com 

博客：<https://blog.csdn.net/theonegis/article/details/80089375> 

修改时间：2018-06-06 

声明：本文为博主原创文章，转载请注明原文出处

---

## Rasterio简介

有没有觉得用GDAL的Python绑定书写的代码很不Pythonic，强迫症的你可能有些忍受不了。不过，没关系，MapBox旗下的开源库Rasterio帮我们解决了这个痛点。

Rasterio是基于GDAL库二次封装的更加符合Python风格的主要用于空间栅格数据处理的Python库。

Rasterio中栅格数据模型基本和GDAL类似，需要注意的是：

在Rasterio 1.0以后，对于GeoTransform的表示弃用了GDAL风格的放射变换，而使用了Python放射变换的第三方库[affine](https://github.com/sgillies/affine)库的风格。

对于放射变换

```
affine.Affine(a, b, c,
              d, e, f)
```

GDAL中对应的参数顺序是：`(c, a, b, f, d, e)`

采用新的放射变换模型的好处是，如果你需要计算某个行列号的地理坐标，直接使用行列号跟给放射变换对象相乘即可，完全符合数学上矩阵乘法的操作，更加直观和方便。

# 栅格数据读取代码示例

下面的示例程序中演示了如何读取一个GeoTIFF文件并获取相关信息，需要注意的是：

1. rasterio使用`rasterio.open()`函数打开一个栅格文件
2. rasterio使用`read()`函数可以将数据集转为`numpy.ndarray`，该函数如果不带参数，将把数据的所有波段做转换（第一维是波段数），如果指定波段，则只取得指定波段对应的数据（波段索引从1开始）
3. 数据的很多元信息都是以数据集的属性进行表示的

```Python
import rasterio

with rasterio.open('example.tif') as ds:
    print('该栅格数据的基本数据集信息（这些信息都是以数据集属性的形式表示的）：')
    print(f'数据格式：{ds.driver}')
    print(f'波段数目：{ds.count}')
    print(f'影像宽度：{ds.width}')
    print(f'影像高度：{ds.height}')
    print(f'地理范围：{ds.bounds}')
    print(f'反射变换参数（六参数模型）：\n {ds.transform}')
    print(f'投影定义：{ds.crs}')
    # 获取第一个波段数据，跟GDAL一样索引从1开始
    # 直接获得numpy.ndarray类型的二维数组表示，如果read()函数不加参数，则得到所有波段（第一个维度是波段）
    band1 = ds.read(1)
    print(f'第一波段的最大值：{band1.max()}')
    print(f'第一波段的最小值：{band1.min()}')
    print(f'第一波段的平均值：{band1.mean()}')
    # 根据地理坐标得到行列号
    x, y = (ds.bounds.left + 300, ds.bounds.top - 300)  # 距离左上角东300米，南300米的投影坐标
    row, col = ds.index(x, y)  # 对应的行列号
    print(f'(投影坐标{x}, {y})对应的行列号是({row}, {col})')
    # 根据行列号得到地理坐标
    x, y = ds.xy(row, col)  # 中心点的坐标
    print(f'行列号({row}, {col})对应的中心投影坐标是({x}, {y})')
    # 那么如何得到对应点左上角的信息
    x, y = (row, col) * ds.transform
    print(f'行列号({row}, {col})对应的左上角投影坐标是({x}, {y})')
```

输出如下：

```
该栅格数据的基本数据集信息（这些信息都是以数据集属性的形式表示的）：
数据格式：GTiff
波段数目：3
影像宽度：4800
影像高度：4800
地理范围：BoundingBox(left=725385.0, bottom=2648415.0, right=869385.0, top=2792415.0)
反射变换参数（六参数模型）：
 | 30.00, 0.00, 725385.00|
| 0.00,-30.00, 2792415.00|
| 0.00, 0.00, 1.00|
投影定义：CRS({'init': 'epsg:32649'})
第一波段的最大值：5459
第一波段的最小值：-313
第一波段的平均值：489.80300625
(投影坐标725685.0, 2792115.0)对应的行列号是(10, 10)
行列号(10, 10)对应的中心投影坐标是(725700.0, 2792100.0)
行列号(10, 10)对应的左上角投影坐标是(725685.0, 2792115.0)
```

