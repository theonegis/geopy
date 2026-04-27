import numpy as np
from PIL import Image, ImageColor
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix
from imblearn.under_sampling import RandomUnderSampler

import matplotlib as mpl
import matplotlib.pyplot as plt

mpl.rc("font",family='OPPO Sans')


# 在MBRSC数据集中有6类，分别为建筑物，裸地，道路，植被，水体和其它
# Building: #3C1098
# Land (unpaved area): #8429F6
# Road: #6EC1E4
# Vegetation: #FEDD3A
# Water: #E2A929
# Unlabeled: #9B9B9B
# 我们这里用不同的颜色表示不同的类别
color_label = {
    ImageColor.getcolor('#3C1098', 'RGB'): 0,
    ImageColor.getcolor('#8429F6', 'RGB'): 1,
    ImageColor.getcolor('#6EC1E4', 'RGB'): 2,
    ImageColor.getcolor('#FEDD3A', 'RGB'): 3,
    ImageColor.getcolor('#E2A929', 'RGB'): 4,
    ImageColor.getcolor('#9B9B9B', 'RGB'): 5
}

# 选择一张图像进行模型训练，在另外一张图像上进行模型验证
# **模型训练部分** #
# 记载数据
image = np.asarray(Image.open(r"D:\GeoPy\09\MBRSC\Tile 1\images\image_part_008.jpg"))
label = np.asarray(Image.open(r"D:\GeoPy\09\MBRSC\Tile 1\masks\image_part_008.png"))
# 对输入数据进行归一化处理
image = image / 255.0
# 将标签中的颜色值转化为0-5的标签
label = np.apply_along_axis(lambda c: color_label[tuple(c)], -1, label)
x, y = image.reshape((-1, 3)), label.reshape((-1, 1))
# 我们只关注前五类的分类精度，这里可以删除掉未标记的样本元素
# 当然你也可以不删除
index = np.where(y == 5)[0]
x, y = np.delete(x, index, axis=0), np.delete(y, index, axis=0)
# 对训练数据进行样本Undersampling，使得各类样本数量均衡
# RandomUnderSampler对于类别不均衡的数据集中，通过减少多数类的样本数量来平衡类别分布
sampler = RandomUnderSampler()
x, y = sampler.fit_resample(x, y)
# 初始化随机森林模型，保持默认参数，使用fit()方法进行模型训练
rfc = RandomForestClassifier()
rfc.fit(x, y)

# **模型验证部分** #
# 可以发现模型验证部分和模型训练部分的数据预处理是类似的
image = np.asarray(Image.open(r"D:\GeoPy\09\MBRSC\Tile 1\images\image_part_009.jpg"))
image = image / 255.0
label = np.asarray(Image.open(r"D:\GeoPy\09\MBRSC\Tile 1\masks\image_part_009.png"))
label = np.apply_along_axis(lambda c: color_label[tuple(c)], -1, label).reshape(-1)
# 这里直接使用之前训练好的模型调用predict()方法进行预测
result = rfc.predict(image.reshape((-1, 3)))
index = np.where(label == 5)[0]
# 使用scikit-learn内置函数计算混淆矩阵
# 混淆矩阵用于表示每种类别中正确分类和错误分类的数量
matrix = confusion_matrix(np.delete(label, index, axis=0), np.delete(result, index, axis=0))
print(matrix)

# 这里我们将分类结果渲染成和原来的标签一直的颜色进行输出
label_color = {value: key for key, value in color_label.items()}
result = np.vectorize(lambda c: label_color[c])(result)
result = np.array(result).reshape((3, *image.shape[:2])).transpose((1, 2, 0)).astype(np.uint8)
Image.fromarray(result).save('image_seg_009.png')

# 最后我们将原始图像，模型输出结果和标签真值进行统一展示
# 显示分类结果
image = np.asarray(Image.open(r"D:\GeoPy\09\MBRSC\Tile 1\images\image_part_009.jpg"))
label = np.asarray(Image.open(r"D:\GeoPy\09\MBRSC\Tile 1\masks\image_part_009.png"))
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for ax, im, name in zip(axes.ravel(), (image, result, label), ('原始图像', '分类结果', '标签真值')):
    ax.set_title(name)
    # 显示图像
    ax.imshow(im)
    # 设置坐标轴不显示
    ax.set_xticks([])
    ax.set_yticks([])
    ax.axis('off')

fig.tight_layout()
plt.savefig('image_seg_009_3.png', dpi=300)
plt.show()
