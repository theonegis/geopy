# 1.11 函数式编程

# 函数式编程更加强调程序执行的结果而非执行的过程
def merge(a, b):
    """
    归并排序中的归并操作
    :param a: list 一组给定数字
    :param b: list 另外一组给定数字
    :return: list 返回对于a和b进行归并排序的结果
    """
    if len(a) == 0:
        return b
    elif len(b) == 0:
        return a
    elif a[0] < b[0]:
        return [a[0]] + merge(a[1:], b)
    else:
        return [b[0]] + merge(a, b[1:])


def sort(x):
    """
    对于给定的一组数字，从中间分开，对前半部分进行归并排序，对后半部分进行归并排序
    然后对两部分排好序的结果进行归并
    :param x: list 一组给定数字
    :return: list 返回使用归并排序好以后的结果
    """
    if len(x) < 2:
        return x
    else:
        h = len(x) // 2
        return merge(sort(x[:h]), sort(x[h:]))


import random
nums = random.sample(range(100), 10)  # 生成100以内的10个随机数
print(nums)
sorted_nums = sort(nums)  # 使用归并排序对随机数进行排序
print(sorted_nums)


# map(func, iterable)函数
map(lambda x: x * 2, nums)


