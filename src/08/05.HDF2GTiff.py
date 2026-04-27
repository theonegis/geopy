import os
from qgis.core import *

QgsApplication.setPrefixPath("/Applications/QGIS-LTR.app/Contents/MacOS", True)
# 新建一个QGIS应用程序的实例，第二个参数为False来禁用GUI显示
qgs = QgsApplication([], False)
# 初始化QGIS应用程序
qgs.initQgis()
project: QgsProject = QgsProject.instance()

ifile = 'HDF5:"/Users/tanzhenyu/Downloads/Chla_Valid/H5/S3B_OL_1_EFR____20210917T042325_20210917T042625_20210918T085418_0179_057_090_2160_LN1_O_NT_002_x.h5"://bands/chla'
ofile = '/Users/tanzhenyu/Downloads/20210917.tif'

layer = QgsRasterLayer(ifile, os.path.basename(ifile), 'gdal')
project.addMapLayer(layer, False)
writer = QgsRasterFileWriter(ofile)
pipe = QgsRasterPipe()
provider = layer.dataProvider()
pipe.set(provider.clone())
transform_context = project.transformContext()
writer.writeRaster(
    pipe,
    provider.xSize(),
    provider.ySize(),
    provider.extent(),
    provider.crs(),
    transform_context)
del layer
qgs.exitQgis()
