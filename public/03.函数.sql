/*
Function 函数
    聚合函数、窗口函数、String、Numeric、Date、高级函数（IFNULL和COALESCE、IF和CASE）
    函数肯定不止这些，比如String或Date还有很多就不一一展示了，自行查阅文档。

    窗口函数：
    从MySQL8.0开始支持！
    核心特点：
        保留原始行：计算结果会作为新列添加到每一行中。
        定义窗口：通过 OVER() 子句指定计算范围（分区、排序、框架）。
        灵活分析：支持排名、累计计算、前后行比较等高级分析。
    语法：
        function_name(expression) OVER (
            [PARTITION BY partition_expression]
            [ORDER BY sort_expression [ASC|DESC]]
            [frame_clause]
        )
    关键字句含义：
        1.PARTITION BY ：将数据划分为多个分区（类似于GROUP BY），函数在每个分区内独立计算。
        2.ORDER BY：指定分区的排序规则。
        3.frame_clause：窗口框架。
    常用窗口函数分类
        1. 序号函数
            函数	说明	示例
            ROW_NUMBER()	分区内唯一序号（连续）	1,2,3,...
            RANK()	并列时跳跃排名	1,1,3,...
            DENSE_RANK()	并列时连续排名	1,1,2,...
        2. 分布函数
            函数	说明
            PERCENT_RANK()	相对百分比排名
            CUME_DIST()	累积分布
        3. 前后函数
            函数	说明
            LAG(expr, offset)	访问分区内前 N 行
            LEAD(expr, offset)	访问分区内后 N 行
        4. 首尾函数
            函数	说明
            FIRST_VALUE(expr)	分区第一行的值
            LAST_VALUE(expr)	分区最后一行的值
        5. 聚合函数（窗口模式）
            函数	说明
            SUM(), AVG(), MIN(), MAX(), COUNT()	支持窗口计算

*/

# 聚合函数：输入一系列值并聚合为一个结果的函数
#     聚合函数经常与GROUP BY一起使用
# 常用的聚合函数有哪些？
USE sql_invoicing;
# 计算行数
SELECT
    COUNT(invoice_id),
    # 使用 DISTINCT剔除重复行
    COUNT(DISTINCT payment_total),
    # 会忽略NULL
    COUNT(payment_date),
    # 计数
    COUNT(*)
FROM
    invoices;
# 平均值、最大值和最小值
SELECT
    AVG(invoice_total),
    MAX(invoice_total),
    MIN(invoice_total)
FROM
    invoices;
# 求和
SELECT
    SUM(invoice_total + 100)
FROM
    invoices
WHERE
    invoice_id = 10;
# Numeric 数值
SELECT ABS(-10); -- 返回 10。（求绝对值）
SELECT CEIL(4.2); -- 返回 5。（天花板函数，不管是4.几，结果都是5）
SELECT FLOOR(4.5); -- 返回 4.(地板函数，不管是4.几，结果都是4)
SELECT ROUND(4.567, 2); -- 返回 4.57。（四舍五入并保留2位）
SELECT TRUNCATE(4.567, 2); -- 返回 4.56 （截断并保留2位）
SELECT SQRT(144); -- 返回 12 （根号）
SELECT MOD(10, 3); -- 返回 1 （取余）
SELECT RAND(); -- 返回一个随机数 （0-1）
SELECT GREATEST(1, 5, 2, 8, 3, 111); -- 返回 111 (一组数字中的最大值)
SELECT LEAST(1, 5, 2, 8, 3);
-- 返回 1 （一组数字中的最小值）


-- String
/*统计字符个数*/
SELECT LENGTH('sky');
-- 返回 3 （求字符串长度）
/*大小写转换*/
SELECT UPPER('sky'); -- 返回'SKY' (转大写)
SELECT LOWER('Sky');
-- 'sky'(转小写)
/*去除空格*/
SELECT LTRIM('  Sky');-- 去除左边空格
SELECT RTRIM('Sky  ');-- 去除右边空格
SELECT TRIM('  Sky  ');
-- 去除左右空格
/*字符串截取*/
SELECT LEFT('Microsoft', 4); -- 返回 Micr （从左边截取4个字符）
SELECT RIGHT('Microsoft', 4); -- 返回 soft （从右边截取4个字符）
SELECT SUBSTRING('Microsoft', 5, 2);-- 返回os （从第5个开始截取，截取2个字符，SQL计数是从第一个开始，而非0）
SELECT SUBSTRING('Microsoft', 6);
-- 返回soft （从第6个开始截取，截取到末尾）
/*定位*/
SELECT LOCATE('soft', 'Microsoft');
-- 返回6 （定位'soft'在'Microsoft'中首次出现的位置）
-- 没有的话，返回0，其他编程语言返回-1
-- 这个定位/查找函数依然是不区分大小写的
/*替换*/
SELECT REPLACE('Microsoft', 'soft', 'software');
-- 返回 'Microsoftware' (将'Microsoft'中的'soft'替换为software')

/*连接*/
USE sql_store;
SELECT
    -- concatenate v. 连接
    #     把名字连接起来
    CONCAT(last_name, first_name) AS full_name
FROM
    customers;


# Date
/*当前日期*/
SELECT NOW(); --  2025-07-19 23:35:29。表示当前完整日期和时间
SELECT CURDATE(); -- 2025-07-19。表示当前日期
SELECT CURTIME();
-- 23:36:49。表示当前时间。
/*截取日期*/
SELECT YEAR('09-09-09'); -- 2009。自动截取年
SELECT YEAR(NOW()); -- 2025。当前年
SELECT DAYNAME(NOW()); -- Saturday 当前星期
SELECT MONTHNAME(NOW());-- July。当前月
SELECT EXTRACT(YEAR FROM NOW());-- 2025 当前年
SELECT EXTRACT(MONTH FROM NOW()); -- 7 表示当前月
SELECT EXTRACT(DAY FROM NOW());-- 19 当前日
SELECT EXTRACT(HOUR FROM NOW());
-- 23 当前几点

-- 查询今年的订单
-- 用时间日期函数而非手动输入年份，代码更可靠，不会随着时间的改变而失效
USE sql_store;
SELECT *
FROM
    orders
WHERE
    YEAR(order_date) = YEAR(NOW());
-- 提取两个年来比较

#  Format Date 下面是专门用来格式化日期的函数，日期的本质是数值
#   不需要刻意全部都记下来，你也记不完，会查文档，知道怎么用就行
#  日期要用引号括起来
SELECT DATE_FORMAT(NOW(), '%M %d,%Y');# 对日期进行格式化
SELECT TIME_FORMAT(NOW(), '%H:%i %p'); # 对时间进行格式化
SELECT DATE_ADD(NOW(), INTERVAL 1 DAY); # 增加一定的数量
SELECT DATE_SUB(NOW(), INTERVAL 1 YEAR); # 减少一定的数量
SELECT DATEDIFF('2019-01-01 09:00', '2019-01-05'); # 计算差异。会忽略Time部分，只计算date部分
SELECT TIME_TO_SEC('09:00'); # 计算差异。TIME_TO_SEC 会计算从 00:00 到某时间经历的秒数
SELECT TIME_TO_SEC('09:00') - TIME_TO_SEC('09:02');

# 高级函数

# IFNULL和COALESCE ：用来替换空值的函数
#     IFNULL：如果表达式为 NULL，则返回指定值，否则返回表达式。
SELECT IFNULL(NULL, 'Hello'); # 返回'Hello'
SELECT IFNULL('null', 'Hello');
# 返回'null'
#     COALESE：返回列表中的第一个非空值。（推荐）
SELECT COALESCE(NULL, NULL, NULL, 'Hello', NULL, 'Hi');
# 返回'Hello'

# 将orders表中shipper.id中的空值替换为'Not Assigned'（未分配）
USE sql_store;
SELECT
    order_id,
    COALESCE(shipper_id, 'Not Assigned') AS shipper
FROM
    orders;
# 将orders里shipper.id中的空值先替换comments，
# 若comments也为空再替换为'Not Assigned'（未分配）
SELECT
    order_id,
    COALESCE(shipper_id, comments, 'Not Assigned') AS shipper
FROM
    orders;

# 返回一个有以下两列的查询结果：
# 1. customer(顾客的全名)
# 2. phone(没有的话，显示'Unknown')
USE sql_store;
SELECT
    CONCAT(last_name, ' ', first_name),
    COALESCE(phone, 'Unknown') AS phone
FROM
    customers;
# 上面的案例COALESCE替换为IFNULL也可以。


/*
IF和CASE：流程控制的函数
  */

# 将订单表中订单按是否是今年的订单分类为 '活跃'和 '非活跃'。
# 之前讲过用UNION法，即用两次查询分别得到今年的和今年以前的订单，
# 添加上分类列再用UNION合并，这里直接在SELECT里运用IF函数可以更容易地得到相同的结果
USE sql_store;
SELECT *,
       IF(YEAR(order_date) = YEAR(NOW()), '活跃用户', '非活跃用户') AS category
FROM
    orders;

# 得到包含如下字段的表：
# 1. product_id
# 2. name
# 3. 该产品出现在订单中的次数。
# 4. 分类。根据多于一次分类为'多次下单','下单一次','从未下单'
USE sql_store;
SELECT
    product_id,
    name,
    COUNT(order_id)                                                                      AS 订单数,
    IF(COUNT(order_id) = 1, '下单一次', IF(COUNT(order_id) > 1, '下单多次', '从未下单')) AS 下单次数
FROM
    products
        LEFT JOIN order_items USING (product_id)
GROUP BY
    product_id;

# 将订单归类为：
# 今年订单，订单创建日期是今年
# 去年订单，订单创建日期是去年
# 更早的订单，订单创建日期比去年更早
USE sql_store;
SELECT
    order_id,
    CASE
        WHEN YEAR(order_date) = YEAR(NOW())
            THEN '今年订单'
        WHEN YEAR(order_date) = YEAR(NOW()) - 1
            THEN '去年订单'
        WHEN YEAR(order_date) < YEAR(NOW()) - 1
            THEN '更早的订单'
    END AS '订单日期归类'
FROM
    orders;

# 查询：得到包含如下字段的表：
# full name, points, category（根据积分<2k，2k~3k（包含两端），>3k分为青铜白银和黄金用户）
# 之前也是用过UNION法，分别查询加分类字段再合并，很麻烦。
# 使用CASE
USE sql_store;
SELECT
    CONCAT(last_name, ' ', first_name) AS 用户名,
    points,
    CASE
        WHEN points < 2000
            THEN '青铜'
        WHEN points BETWEEN 2000 AND 3000
            THEN '白银'
        WHEN points > 3000
            THEN '黄金'
        -- ELSE null

    END                                AS 用户分类
FROM
    customers
ORDER BY
    points DESC;

# 使用IF
SELECT
    CONCAT(last_name, '', first_name)       AS 用户名,
    points,
    IF(points < 2000, '青铜',
       IF(points BETWEEN 2000 AND 3000, '白银',
          IF(points > 3000, '黄金', NULL))) AS 用户分类
FROM
    customers;

# 简化CASE语句
SELECT
    CONCAT(last_name, '', first_name) AS 用户名,
    points,
    CASE
        WHEN points < 2000
            THEN '青铜'
        WHEN points <= 3000
            THEN '白银'
            ELSE '黄金'
    END                               AS 用户分类
FROM
    customers
ORDER BY
    points DESC;

# 简化IF语句

SELECT
    CONCAT(last_name, '', first_name)      AS 用户名,
    points,
    IF(points < 2000, '青铜',
       IF(points <= 3000, '白银', '黄金')) AS 用户分类
FROM
    customers
ORDER BY
    points DESC;

# 窗口函数
# TODO：窗口函数后续在完善
USE sql_store;
# 查询用户信息，按static分区，将每个区的points降序排列并显示排名
SELECT
    first_name,
    state,
    points,
    DENSE_RANK() OVER (PARTITION BY state ORDER BY points DESC ) AS 排名
FROM
    customers;