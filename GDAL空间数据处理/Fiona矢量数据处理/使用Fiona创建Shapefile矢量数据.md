# 使用Fiona创建Shapefile矢量数据

作者：阿振 邮箱：tanzhenyugis@163.com

博客：<https://blog.csdn.net/theonegis/article/details/80089375>

修改时间：2018-06-10

声明：本文为博主原创文章，转载请注明原文出处

---

## 基本思路

使用Fiona写入Shapefile数据，主要是构建一个Schema，然后将空间对象转为GeoJSON的形式进行写入。

这个Schema是一个字典结构，定义了Geometry的类型，属性字段的名称及其类型。

## 代码实现

这里我们举两个例子进行说明：第一是将GeoJSON数据转为Shapefile，第二个是新建一个Shapefile，然后再里面写入自定义的空间几何数据。

因为从GeoJSON中读入的数据本身就是JSON格式，所以我们可以直接写入。GeoJSON的格式定义，参见：[创建Shapefile文件并写入数据](https://blog.csdn.net/theonegis/article/details/80554993)。

```Python
import fiona
import json

with open('China.json') as f:
    data = json.load(f)

# schema是一个字典结构，指定了geometry及其它属性结构
schema = {'geometry': 'Polygon',
          'properties': {'id': 'int', 'name': 'str'}}

# 使用fiona.open方法打开文件，写入数据
with fiona.open('Provinces.shp', mode='w', driver='ESRI Shapefile',
                schema=schema, crs='EPSG:4326', encoding='utf-8') as layer:
    # 依次遍历GeoJSON中的空间对象
    for feature in data['features']:
        # 从GeoJSON中读取JSON格式的geometry和properties的记录
        element = {'geometry': feature['geometry'],
                   'properties': {'id': feature['properties']['id'],
                                  'name': feature['properties']['name']}}
        # 写入文件
        layer.write(element)
```

第二种方法使用shapely包创建Geometry对象，然后利用`mapping`方法将创建的对象转为GeoJSON格式进行写入。

Shapely包提供了对空间几何体的定义，操作等功能。

```Python
import fiona
from shapely.geometry import Polygon, mapping

# schema是一个字典结构，指定了geometry及其它属性结构
schema = {'geometry': 'Polygon',
          'properties': {'id': 'int', 'name': 'str'}}

# 使用fiona.open方法打开文件，写入数据
with fiona.open('Beijing.shp', mode='w', driver='ESRI Shapefile',
                schema=schema, crs='EPSG:4326', encoding='utf-8') as layer:
    # 使用shapely创建空间几何对象
    coordinates = [[117.4219, 40.21], [117.334, 40.1221], [117.2461, 40.0781], [116.8066, 39.9902], [116.8945, 39.8145],
                   [116.8945, 39.6826], [116.8066, 39.5947], [116.543, 39.5947], [116.3672, 39.4629],
                   [116.1914, 39.5947], [115.752, 39.5068], [115.4883, 39.6387], [115.4004, 39.9463],
                   [115.9277, 40.2539], [115.752, 40.5615], [116.1035, 40.6055], [116.1914, 40.7813],
                   [116.4551, 40.7813], [116.3672, 40.9131], [116.6309, 41.0449], [116.9824, 40.6934],
                   [117.4219, 40.6494], [117.2461, 40.5176], [117.4219, 40.21]]
    polygon = Polygon(coordinates)  # 使用地理坐标定义Polygon对象
    polygon = mapping(polygon)  # 将Polygon对象转为GeoJSON格式
    feature = {'geometry': polygon,
               'properties': {'id': 1, 'name': '北京市'}}
    # 写入文件
    layer.write(feature)
```

