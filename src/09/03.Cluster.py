import numpy as np
from PIL import Image
from sklearn.mixture import GaussianMixture
import matplotlib.pyplot as plt

# 通过Image库读取图像然后转为ndarray
image = np.asarray(Image.open('/Volumes/17791433453/GeoPy/09/image_part_2.jpg'))
# 将图像尺寸调整为像素数X波段数
data = image.reshape((-1, 3))

# 基于高斯混合模型进行图像分割
gmm = GaussianMixture(n_components=5)
gmm.fit(data)
labels = gmm.predict(data)
# 注意结果必须恢复到原来的图像尺寸
result = labels.reshape(image.shape[:2])

fig, axes = plt.subplots(1, 2, figsize=(12, 6))
for ax, im in zip(axes.ravel(), (image, result)):
    # 显示图像
    ax.imshow(im)
    # 设置坐标轴不显示
    ax.set_xticks([])
    ax.set_yticks([])
    ax.axis('off')

fig.tight_layout()
plt.savefig('image_seg_2.png', dpi=300)
plt.show()
