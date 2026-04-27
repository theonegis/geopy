# 1.9 面向对象编程初识别

import math


class Rectangle(object):
    """
    Python中使用class关键字定义类，后面是类名。类名后面的括号中是继承的父类
    如果没有合适的继承类，就使用object类，这是所有类的父类（关于继承我们会在后面进行详谈）
    """

    def __init__(self, coordinates):
        """
        Python中以__开头和结尾的函数或变量是系统预定义的，具有特殊含义
        __init__()方法表示初始化该类的实例时需要执行的方法，第一个参数永远是self，表示创建的实例本身
        在__init__()方法内部，我们一般会把对象的属性绑定到self，已经进行一些其他初始化工作
        """

        width = math.sqrt((coordinates[0][0] - coordinates[1][0]) ** 2 +
                          (coordinates[0][1] - coordinates[1][1]) ** 2)
        height = math.sqrt((coordinates[1][0] - coordinates[2][0]) ** 2 +
                           (coordinates[1][1] - coordinates[2][1]) ** 2)

        self.coordinates = coordinates
        # 如果给定坐标不闭合，将矩形坐标闭合
        if self.coordinates[0] != self.coordinates[-1]:
            self.coordinates.append(self.coordinates[0])

        # 较长的边作为矩形的长，较短的作为矩形的宽
        self.width = min(width, height)
        self.height = max(width, height)

    def area(self):
        # 计算矩形面积
        return self.height * self.width

    def perimeter(self):
        # 计算矩形周长
        return 2 * (self.height + self.width)


# 定义了People类以后我们可以对类进行实例化生成对象
rect = Rectangle([(-1, 0), (0, 1), (1, 0)])
# 可以用isinstance(obj, cls)函数判断对象obj的原型是不是cls类
print(isinstance(rect, Rectangle))

# 调用对象的属性和方法
print(f'矩形长为{rect.height}，宽为{rect.width}')

print(f'矩形周长为{rect.perimeter()}，面积为{rect.area()}')
