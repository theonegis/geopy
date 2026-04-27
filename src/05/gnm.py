from osgeo import gdal, ogr, gnm, osr

gdal.UseExceptions()
gnm.UseExceptions()

ds = gdal.OpenEx('./well_pipe_network')
dn = gnm.CastToGenericNetwork(ds)
print('计算两点之间的最短路径...')
result = dn.GetPath(40, 60, gnm.GATDijkstraShortestPath)
# 创建输出结果矢量文件
driver = ogr.GetDriverByName('GPKG')
output = '/Users/tanzhenyu/Dataware/GeoPy/gnm/path.gpkg'
dst = driver.CreateDataSource(output)
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)
lyr_p = dst.CreateLayer('Point', geom_type=ogr.wkbPoint, srs=srs)
lyr_l = dst.CreateLayer('Line', geom_type=ogr.wkbLineString, srs=srs)
lyr_p.CreateField(ogr.FieldDefn("ID", ogr.OFTInteger))
lyr_l.CreateField(ogr.FieldDefn("ID", ogr.OFTInteger))


for feat in result:
    geom = feat.GetGeometryRef()
    idx = feat.GetFieldAsString(0)
    print(geom.ExportToWkt())

    if geom.GetGeometryType() == ogr.wkbPoint:
        feature = ogr.Feature(lyr_p.GetLayerDefn())
        feature.SetGeometry(geom)
        feature.SetField("ID", idx)
        lyr_p.CreateFeature(feature)
    elif geom.GetGeometryType() == ogr.wkbLineString:
        feature = ogr.Feature(lyr_l.GetLayerDefn())
        feature.SetGeometry(geom)
        feature.SetField("ID", idx)
        lyr_l.CreateFeature(feature)

dst.FlushCache()
del ds, dn, dst