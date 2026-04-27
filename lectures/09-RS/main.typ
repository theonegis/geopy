#import "theme.typ": *

#show: doc => setup-base-fonts(
  doc,
  cjk-mono-family: ("JetBrains Maple Mono", "SF Mono SC"),
)

#show: course-theme.with(
  title: [第九章：遥感影像处理与应用],
  author: [谭振宇],
  institution: [西北大学城市与环境学院],
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
  title-font-size: 1.2em,
  toc-font-size: 28pt,
  toc-spacing: 1em,
  code-font-size: 0.9em,
)

#course-title-slide(
  bg-image: "figures/西北大学.jpeg",
  logo-image: "figures/西北大学.pdf",
)

= 遥感影像处理与应用

== 学习目标

#titled-card(
  [核心学习目标],
  [
    - 了解遥感反演、地物分类和识别的基本流程
    - 了解监督学习和非监督学习的基本流程
    - 了解常见的机器学习算法的基本思想
    - 熟练使用Scikit-learn库进行遥感建模
  ],
)

== 背景介绍

遥感影像反演一般是通过分析和处理遥感观测获取的影像数据，来推断地表或大气的某些物理或化学性质的过程。遥感反演使得人们可以在不直接接触目标物体的情况下，获取大范围、长时序的关于地球表面和大气的详细信息。

#text(0.8em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    align: top,
    titled-card(
      [反演模型分类],
      [
        - *经验模型*：通过波段或比值建立与实测参数之间的回归关系。简单、区域适用性强、有一定解释性。
        - *机理模型*：模拟复杂的物理和化学机理。机制明确，但在复杂环境下参数化难，精度易受影响。
        - *机器学习模型*：自适应建立光谱与关键参数之间的定量关系，非线性拟合能力强，精度较高。
      ],
    ),
    titled-card(
      [基础处理流程],
      [
        - *数据预处理*：大气校正、几何校正。
        - *特征提取*：光谱、空间或纹理特征提取组合。
        - *模型训练与验证*：将星地匹配数据输入模型进行学习与评估。
        - *空间制图应用*：将点尺度构建的模型迁移到像元级别进行预测制图。
      ],
    ),
  )]

== 常用Python遥感处理库

#table(
  columns: (3fr, 5fr),
  align: (center, left),
  fill: (_, row) => if calc.even(row) { rgb("f4f4f4") },
  stroke: none,
  [*库名称*], [*用途说明*],
  [GDAL / Rasterio], [最常用的空间数据处理库与符合Python规范的抽象库],
  [RSGISLib / SciPy], [遥感分析和科学计算功能集合],
  [Pillow / scikit-image / OpenCV], [计算机视觉和图像分析通常依赖的增强型和专业型图像库],
  [Scikit-learn], [使用最广泛的机器学习库，涵盖常见各种聚类、回归和分类等],
  [PyTorch], [主流和前沿的深度学习架构支撑平台],
)


= 遥感影像反演之经验模型

== 经验模型简介

经验模型一般通过分析光谱特征和反演要素之间的关系，利用回归分析建立两者连接。一般可利用历史观测数据和遥感特定波段来建立预测。

以 NASA OceanColor 官方的水体叶绿素a (Chla) 浓度反演算法为例：

#titled-card(
  [CI算法 (Color Index) 与 OCx算法],
  [
    通过可见蓝绿红波段的光谱关系推演。合并策略：
    - *CI 算法控制低浓度区*：当反演结果低于 $0.25$ 时使用。
    - *OC 算法控制高浓度区*：当反演结果高于 $0.35$ 时使用。
    - 当介于两者阈值之间时，利用公式实现动态加权的参数融合。
  ],
)

== Python经验算法脚本片段

#text(0.75em)[
  ```python
  import h5py, numpy as np
  from pathlib import Path

  src_dir = Path('LoughNeagh/RRS'); dst_dir = Path('LoughNeagh/Chla')
  eps = 1e-7

  for f in src_dir.glob('*h5'):
      with h5py.File(str(f)) as fr:
          bands = fr['bands']
          lat, lon = bands['latitude'][...], bands['longitude'][...]
          blue, green, red = bands['Rrs_443'][...], bands['Rrs_555'][...], bands['Rrs_667'][...]

          # 计算CI指数与初步Chl-a
          ci = green - (blue + (555 - 443) / ((667 - 443) * (red - blue) + eps))
          ci = 10 ** (-0.4287 + 230.47 * ci)

          # OC3算法
          blue_max = np.maximum(blue, bands['Rrs_488'][...])
          ai = [-2.7423, 1.8017, 0.0015, -1.2280]
          oc3m = 10 ** (0.2424 + sum([(ai[i-1] * np.log10((blue_max/green + eps))**i) for i in range(1, 5)]))

          # 结果融合与提取后续输出...
  ```
]

== 经验模型反演结果展示

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center,
  image("figures/MODIS-RGB.png", width: 95%), image("figures/MODIS-Chla.png", width: 95%),
)
#text(0.8em, align(center)[*基于MODIS数据提取遥感反射比使用经验算法反演制图的效果*])


= 遥感影像反演之机器学习模型

== 机器学习反演简介

传统机器学习算法通过复杂结构自我提取数据隐含规律来进行分析推断，从而减轻人工干预与人为特征组合的局限性。它能有效地建立模型中的非线性映射。

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [非监督学习 (Unsupervised)],
    [
      - 不依赖于先验标注数据
      - 自动梳理分组与聚类潜在分布
      - 目的是自下而上地去发现信息
    ],
  ),
  titled-card(
    [监督学习 (Supervised)],
    [
      - 需要提供带标签目标值的参考数据以供误差比对
      - 通过前向调整权重极小的方向匹配和预测分类界限和回归拟合
      - 用于确定的连续值求职（回归）与离散区分类任务
    ],
  ),
)

== 构建监督训练数据集

进行模型建模的前提是整合星地同步观测数据。提取与经纬度空间特征对应的像素数据与真实采样标签，组成一维或二维结构。
#align(center)[
  #image("figures/Excel-Samples.png", width: 50%)]
构建整理用于模型训练和特征选择的工作表格：左侧是输出实测项，右侧扩展波段及属性被作为模型输入特征


== 随机森林回归模型示例

随机森林 (Random Forest) 属于一种基于决策树的集成学习算法，通过“投票”或“加权平均”显著减轻过拟合并强化泛化能力。

#text(0.7em)[
  ```python
  from sklearn import model_selection, ensemble, metrics
  import pandas as pd
  import numpy as np
  import joblib

  data = np.array(pd.read_excel('Chla_MODIS.xlsx'))
  inputs = data[:, 4:]  # 截取各波段光谱作为特征
  target = np.array(data[:, 0]) # 第一列：叶绿素实测浓度

  # 使用Scikit-Learn数据集拆分包将数据划分为训练与验证 (70% vs 30%)
  x_train, x_test, y_train, y_test = model_selection.train_test_split(inputs, target, test_size=0.3)

  # 随机森林回归模型实例化与训练
  rfm = ensemble.RandomForestRegressor()
  rfm.fit(x_train, y_train)
  joblib.dump(rfm, 'RFR.pkl') # 保存已拟合的模型权重

  y_pred = rfm.predict(x_test)
  print(f"RF RMSE: {np.sqrt(metrics.mean_squared_error(y_test, y_pred)):.2f}")
  print(f"RF R2: {metrics.r2_score(y_test, y_pred):.2f}")
  ```
]

== 批量面尺度计算注意事项

模型往往是基于离散“采样点”提取和构建特征映射。但到了生产层面通常要求我们计算一整幅地图各位置：

#titled-card(
  [空间重构输入与逆转换],
  [
    - *拉平像素特征*：将维度像 `(高度, 宽度, 波段数)` 的图像矩阵降维转换为 `(总像元个数, 波段数)` 的一维样本流列。
    - *并行预测*：输送给 `model.predict()` 输出预测一维阵列（长度等于总像元）。
    - *重置矩阵维度映射*：再将求出的长形列表根据原来图像 `(高度, 宽度)` 按序恢复映射重塑回单波段预测层并附带转换到 GeoTiff 成像。
  ],
)


= 遥感影像分类之非监督分类

== 非监督聚类算法

基于影像数据各像元独立特征之间的相似差异做无监督地块自适应解译，俗称图像分割，具有高度自动化优势。

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: top,
  titled-card(
    [高斯混合模型 (GMM)],
    [假设像素集合是由多变量高斯参数加权混合组合构成。通过训练自发地估计每组协方差和高斯矩阵极值，最后得到归属度。],
  ),
  titled-card(
    [K-Means 与 ISODATA],
    [在特征空间中撒网寻找 K 个核心原点以让各组向心距平方收敛的方法。使用极为普遍，但不具备自我发现合适类数的功能，且对异常值敏感。],
  ),
)

== Scikit-learn 非监督图像分割聚类

#text(0.80em)[
  ```python
  import numpy as np
  from PIL import Image
  from sklearn.cluster import KMeans
  import matplotlib.pyplot as plt

  # 读取大洲级高分影像
  image = np.asarray(Image.open("image_part_009.jpg"))

  # 将影像数据转换为二维数组以便传入各类回归参数集
  data = image.reshape((-1, 3))

  # 执行 K-Means 模型计算
  kmeans = KMeans(n_clusters=5, random_state=2024).fit(data)

  # 提取其计算归结完毕的标记数字并转换原二维影像平面
  labels = kmeans.labels_
  result = labels.reshape((image.shape[0], image.shape[1]))

  plt.imshow(result)
  ```
]

== 聚类效果校验与不充分性

通过单纯数学距离统计完成的机器自动拆分不能很好的表达和反映地学及视觉连贯性对象逻辑。

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center,
  image("figures/image_seg_gm.png", width: 90%), image("figures/image_seg_kmeans.png", width: 90%),
)
#text(0.8em, align(
  center,
)[*左：高斯混合模型图像自适应分割；右：K-Means自动分割效果。各类地物不可避免的出现交叠现象且无法反映分类本源*])


= 遥感影像分类之监督分类

== 遥感影像监督分类流程

有先验的人工框注打点获取标签后指导机器学习参数。这常常意味着更高的精确率和领域适应度。

#titled-card(
  [常用高分分类模型框架],
  [
    - *最大似然框架 (MLC)* 与 *支持向量机 (SVM)* 具有在极少正样本依然起作用的分类超平面构筑支持能力。
    - *随机森林 (RF)* 及 *梯度提升 (XGBoost)* 高度平衡与防过拟合的决策森林特征评估。
    - *深度神经网络* 依靠自适应非线性表达降低人工寻找有效植被指数或特殊增强波段的前置人工特征依赖。
  ],
)

== 图像精细监督分类训练代码片段

将 MBRSC (6 类定义体系数据样本集) 代入模型训练过程：

#text(0.75em)[
  ```python
  from sklearn.ensemble import RandomForestClassifier
  from imblearn.under_sampling import RandomUnderSampler

  # 加载原始遥感图像并做辐射维度内化
  image = np.asarray(Image.open("image_part_008.jpg")) / 255.0
  # 解析附带的掩膜色彩作为先验 Label
  label = np.asarray(Image.open("image_part_008.png"))

  # 对照颜色表创建字典转为标准多维特征类标...
  color_label = { ImageColor.getcolor('#3C1098', 'RGB'): 0, ... }
  y = np.apply_along_axis(lambda c: color_label[tuple(c)], -1, label).reshape((-1, 1))
  x = image.reshape((-1, 3))

  # 去除未标记杂鱼干扰并应用欠采样保证分类比重偏态不失衡
  sampler = RandomUnderSampler()
  x, y = sampler.fit_resample(x, y)

  rfc = RandomForestClassifier()
  rfc.fit(x, y)
  ```
]

== 预测评估与混淆矩阵机制

把隔离出的另一半数据做预测并且与未见数据标签相比照得出“误差表”。

#grid(
  columns: (3fr, 2fr),
  gutter: 1em,
  align: top,
  text(0.8em)[
    *混淆矩阵 (Confusion Matrix)* \ 能够统计预测的命中点：
    - 主对角线代表猜中
    - 其他单元格意味着被错乱交叉定义到它类的损失样本
    - 以此能计算各类的*用户精度 (Precision)* 与*制图正确率 (Recall)*、*总精度* 与 *Kappa系数* 以衡量系统一致性。
  ],
  text(0.85em)[
    ```python
    result = rfc.predict(
      image_test.reshape((-1, 3))
    )
    matrix = confusion_matrix(
      label_test, result
    )
    print(matrix)
    ```
  ],
)

== 椒盐噪声杂散与后去噪平滑

#align(center)[
  #image("figures/image_seg_009.png", width: 85%)
]

经典分类模型受限于无法关注相邻几何像元的物理关联，会使分类出“碎乱”点状假彩色。我们通常后期应用 *众数滤波窗口* 或 *连通域分割处理* 进行有效聚合去噪。

= 课后练习

== 本章小结

#bg-card()[
  本章围绕 Python Scikit-learn 环境中的各种操作范例探索了遥感信息定量和定性化的技术栈：
  - 了解遥感反演和图像分类的概念模型，加深对两者监督和非监督范式的宏观点。
  - 掌握点域算法模型的创建，并了解面域网格栅格铺设反演计算映射技巧。
  - 熟悉 Scikit-learn 模型包络及验证划分应用环境与接口。
  - 学会分析模型与误差计算方式，结合实战探讨了过拟合和采样欠缺平衡的防御策略。
]

== 牛刀小试

#titled-card(
  [综合测验作业],
  [
    `Dataset-RSI-CB256` 数据集包含云覆盖、沙漠、绿地和水体四种高度混合的遥感图像。
    请自行取用 $50\%$ 的范围进行随机预设切片作为独立集做拟合训练，剩下当作测试标校集。
    结合 Scikit-Learn 的多样化组件，选择 4 种常见经典或集成分类方法对比在该不同特征区上的识别提取准确率和泛化鲁棒性质表现差。
  ],
)
