from qgis.core import *
import processing
from processing.core.Processing import Processing


# 提供QGIS的安装路径
# 可以在QGIS的Python命令窗口使用QgsApplication.prefixPath()函数查看QGIS安装路径
QgsApplication.setPrefixPath(r"C:\Program Files\QGIS 3.26.3\apps\qgis", True)
# 新建一个QGIS应用程序的实例，第二个参数为False来禁用GUI显示
qgs = QgsApplication([], False)
# 初始化QGIS应用程序
qgs.initQgis()
# 要在初始化完QGIS应用程序之后再初始化Processing处理算法
Processing.initialize()

# 这里写我们的逻辑代码，加载图层，进行处理
fn = "/Users/tanzhenyu/Dataware/QGIS-Training-Data-release_3.22/exercise_data/processing/hydro/dem25.tif"
name = "SRTM"
# 新建一个栅格图层，然后将其添加到QGIS的当前工程中
layer = QgsRasterLayer(fn, name)
QgsProject.instance().addMapLayer(layer, False)
# 使用processing.run()方法进行算法运行，第一个参数是算法名称，第二个参数是算法参数
# 算法的使用和参数可以通过processing.algorithmHelp("native:slope")函数进行查看
processing.run("native:slope", {
    "INPUT": name,
    "Z_FACTOR": 1,
    'OUTPUT': '/Users/tanzhenyu/Desktop/slope25.tif'
})

# 删除图层，释放内存，退出QGIS应用程序
QgsProject.instance().removeMapLayer(layer.id())
qgs.exitQgis()
