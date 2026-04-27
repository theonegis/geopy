from pathlib import Path
import h5py
import shutil
import numpy as np


RRS_NODATA = -32767  # 标记NODATA的值
# 输入和输出文件夹
src_dir = Path('/Volumes/17791433453/GeoPy/09/QingHaiHu/L2')
dst_dir = Path('/Volumes/17791433453/GeoPy/09/QingHaiHu/L3')
# 如果输出文件夹不存在，则创建一个
if dst_dir.exists():
    shutil.rmtree(str(dst_dir))
dst_dir.mkdir()

eps = 1e-7
# 使用for循环依次变量输入文件夹中的不以点开头的H5文件
for f in src_dir.glob('*h5'):
    if not f.name.startswith("."):
        # 使用H5Py读取需要的各个波段的值
        with h5py.File(str(f)) as fr:
            bands = fr['bands']
            lat = bands['latitude'][...]
            lon = bands['longitude'][...]
            blue = bands['Rrs_443'][...]
            green = bands['Rrs_555'][...]
            red = bands['Rrs_667'][...]

            # 将CI的计算公式写成Python表达式
            ci = green - (blue + (555 - 443) / ((667 - 443) * (red - blue) + eps))
            # 将OC3的计算公式写成Python表达式
            blue = np.maximum(blue, bands['Rrs_488'][...])
            ai = [-2.7423, 1.8017, 0.0015, -1.2280]
            oc3m = 10 ** (0.2424 + sum([(ai[i - 1] * np.log10((blue / green + eps)) ** i) for i in range(1, 5)]))

            # 注意这里向量式编程的用法，使用np.logical_and()当满足条件的时候就取满足条件对应的值
            # 不满足条件时候np.logical_and()的值为0，和对应叶绿素a值相乘也为0
            chla = ci * np.logical_and(ci < 0.25, oc3m < 0.25) + oc3m * np.logical_and(ci > 0.35, oc3m > 0.35)
            # 当介于0.25和0.35之间时进行加权，此时chla计算值为0，np.logical_not(chla)为1
            weighted = ci * (0.35 - ci) / 0.1 + oc3m * (ci - 0.25) / 0.1
            chla += weighted * np.logical_not(chla)
            # 将非陆地像素副值为空
            chla[chla < 0] = np.NAN

        with h5py.File(dst_dir / f.name, 'w') as fw:
            # 创建HDF5文件组，然后将反演得到的叶绿素a和经纬度写入到创建的文件中
            group = fw.create_group('bands')
            group.create_dataset('chla', chla.shape, 'f', chla)
            group.create_dataset('latitude', lat.shape, 'f', lat)
            group.create_dataset('longitude', lon.shape, 'f', lon)
