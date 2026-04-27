from sklearn import model_selection, linear_model, ensemble, metrics
import pandas as pd
import math
import numpy as np
import joblib


# 从Excel表格中加载数据
data = pd.read_excel('/Volumes/17791433453/GeoPy/09/Chla_MODIS.xlsx')
data = np.array(data)

# 数据的第5列到最后一列为MODIS波段光谱数据（遥感反射比）
# 数据的每一行代表一个样本点，每一列代表一个波段（特征）
inputs = data[:, 4:]
# 模型期望的输出实测为叶绿素a，是数据表中的第一列
target = np.array(data[:, 0])
# 将数据分割成7:3，70%用于模型训练，30%用于验证模型精度
x_train, x_test, y_train, y_test = model_selection.train_test_split(inputs, target, test_size=0.3)

# 这里实例化一个简单线性回归模型，fit()方法进行实际的模型训练
lrm = linear_model.LinearRegression()
lrm.fit(x_train, y_train)
# dump()方法用于保存模型，predict()方法用于将训练好的模型在测试数据集上做预测
joblib.dump(lrm, 'LRM.pkl')
y_pred = lrm.predict(x_test)
# 输出归回问题常用的一些评价参数
print(f"LR MAE: {metrics.mean_squared_error(y_test, y_pred):.2f}")
print(f"LR MAPE: {metrics.mean_absolute_percentage_error(y_test, y_pred):.2f}")
print(f"LR RMSE: {math.sqrt(metrics.mean_squared_error(y_test, y_pred)):.2f}")
print(f"LR R2: {metrics.r2_score(y_test, y_pred):.2f}")

# 这里使用随机森林回国模型，同样通过fit()方法进行模型训练，使用模型默认参数
print('*' * 20)
rfm = ensemble.RandomForestRegressor()
rfm.fit(x_train, y_train)
joblib.dump(rfm, 'RFR.pkl')
y_pred = rfm.predict(x_test)
print(f"LR MAE: {metrics.mean_squared_error(y_test, y_pred):.2f}")
print(f"LR MAPE: {metrics.mean_absolute_percentage_error(y_test, y_pred):.2f}")
print(f"LR RMSE: {math.sqrt(metrics.mean_squared_error(y_test, y_pred)):.2f}")
print(f"LR R2: {metrics.r2_score(y_test, y_pred):.2f}")
