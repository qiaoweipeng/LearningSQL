/*Function 函数
    1. 聚合函数：输入一系列值并聚合为一个结果的函数
    常见的聚合函数：
        COUNT（）计算行数
        SUM（）求和
        AVG（）求平均值
        MAX（）求最大值
        MIN（）求最小值
    2. 窗口函数：

    3. STRING 字符串
        lenght（）
        trim（）
        substring（）
        replace（）
    4. NUMERIC 数值
            floor（）
    5. DATE 日期
        FORMAT DATE

    6.

    7. IF和CASE
  */
/*
聚合函数的使用
*/

#常用的聚合函数有哪些？
USE sql_invoicing;
# 计算行数
SELECT
    COUNT(invoice_id),
    # 使用 DISTINCT剔除重复行
    COUNT(DISTINCT payment_total),
    COUNT(payment_total)
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

/*
窗口函数
*/



/*
STRING
*/



/*
NUMERIC
*/



/*
DATE
*/





/*
IFNULL和COALESCE
*/

/*
IF和CASE
*/

# 3.基本函数
/*
    SQL中的函数有：聚合函数、Numeric、String、Date
    还有其他的：IF NULL、COALESCE、IF和CASE
*/
# 3.1Numeric
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


-- 3.2 String
SELECT LENGTH('sky'); -- 返回 3 （求字符串长度）
SELECT UPPER('sky'); -- 返回'SKY' (转大写)
SELECT LOWER('Sky');-- 'sky'(转小写)

SELECT LTRIM('  Sky');-- 去除左边空格
SELECT RTRIM('Sky  ');-- 去除右边空格
SELECT TRIM('  Sky  ');-- 去除左右空格

SELECT LEFT('Microsoft', 4); -- 返回 Micr （从左边截取4个字符）
SELECT RIGHT('Microsoft', 4); -- 返回 soft （从左边截取4个字符）
SELECT SUBSTRING('Microsoft', 5, 2);-- 返回os （从第5个开始截取，截取2个字符，SQL计数是从第一个开始，而非0）
SELECT SUBSTRING('Microsoft', 6);-- 返回soft （从第6个开始截取，截取到末尾）

SELECT LOCATE('soft', 'Microsoft');
-- 返回6 （定位'soft'在'Microsoft'中首次出现的位置）
-- 没有的话，返回0，其他编程语言返回-1
-- 这个定位/查找函数依然是不区分大小写的

SELECT REPLACE('Microsoft', 'soft', 'software');
-- 返回 'Microsoftware' (将'Microdoft'中的'soft'替换为'software')
-- concatenate v. 连接
USE sql_store;
SELECT
    CONCAT(last_name, first_name) AS full_name
FROM
    customers;

# 3.3 Date
SELECT NOW(); -- 2025-07-19 23:35:29
SELECT CURDATE(); -- 2025-07-19
SELECT CURTIME(); -- 23:36:49
SELECT YEAR(NOW()); -- 2025
SELECT DAYNAME(NOW()); -- Saturday
SELECT MONTHNAME(NOW());
-- July


-- 标准SQL语句有一个类似的函数EXTRACT()，若需要在不同DBMS中录入代码，最好用EXTRACT()：
-- EXTRACT(单位 FROM 日期时间对象)
SELECT EXTRACT(YEAR FROM NOW());-- 2015
SELECT EXTRACT(MONTH FROM NOW()); -- 7
SELECT EXTRACT(DAY FROM NOW());-- 19
SELECT EXTRACT(HOUR FROM NOW());
-- 23

-- 返回今年的订单
-- 用时间日期函数而非手动输入年份，代码更可靠，不会随着时间的改变而失效
USE sql_store;
SELECT *
FROM
    orders
WHERE
    YEAR(order_date) = YEAR(NOW());
-- 两次提取'年'元素来比较

#  3.4 Format Dates and Times
-- 日期事件格式化函数应该只是转换日期时间对象的显示格式（另外始终铭记日期时间本质是数值）
-- 方法
-- 很多像这种完全不需要记也不可能记得完，重要的是知道有这么个可以实现这个功能的函数，具体的格式说明符
-- （Specifiers）可以需要的时候去查，至少有两种方法：
-- 1. 直接谷歌关键词 如 mysql date format functions, 其实是在官方文档的 12.7 Date and Time Functions 小结
-- 里，有两个函数的说明和specifiers表
-- 2. 用软件里的帮助功能，如workbench里的HELP INDEX打开官方文档查询或者右侧栏的 automatic comtext
-- help (其是也是查官方文档，不过是自动的)
SELECT DATE_FORMAT(NOW(), '%M %d,%Y');
SELECT TIME_FORMAT(NOW(), '%H:%i %p');
# 格式说明符里，大小写代表不同的格式，这是目前SQL里第一次出现大小写不同的情况
# 3.5 计算 Dates and Times
#     有时需要对日期事件对象进行运算，如增加一天或算两个时间的差值之类，介绍一些最有用的日期时间计算函数：
# 增加或减少一定的天数、月数、年数、小时数等等
SELECT DATE_ADD(NOW(), INTERVAL -1 DAY);
SELECT DATE_SUB(NOW(), INTERVAL 1 YEAR);
# 计算日期差异
SELECT DATEDIFF('2019-01-01 09:00', '2019-01-05');
-- -4
-- 会忽略时间部分，只算日期差异
-- 再次注意手写日期要加引号
#     借助 TIME_TO_SEC 函数计算时间差异，TIME_TO_SEC 会计算从 00:00 到某时间经历的秒数
SELECT TIME_TO_SEC('09:00');
SELECT TIME_TO_SEC('09:00') - TIME_TO_SEC('09:02');
-- 120


#  3.6 IFNULL和COALESCE
# 两个用来替换空值的函数：IFNULL, COALESCE.
# 前者用来返回两个值中的首个非空值，用来替换空值
# 后者用来返回一系列值中的首个非空值，用法更灵活

#     将orders里shipper.id中的空值替换为'Not Assigned'（未分配）
USE sql_store;
SELECT
    order_id,
    IFNULL(shipper_id, 'Not Assigned') AS shipper
FROM
    orders;
# 将orders里shipper.id中的空值先替换comments，若comments也为空再替换为'Not Assigned'（未分配）
SELECT
    order_id,
    COALESCE(shipper_id, comments, 'Not Assigned') AS shipper
FROM
    orders;
# COALESCE 函数是返回一系列值中的首个非空值，更灵活
#     coalesce vi. 合并；结合；联合

#     返回一个有如下两列的查询结果：
# 1. customer(顾客的全名)
# 2. phone(没有的话，显示'Unknown')
USE sql_store;
SELECT
    CONCAT(last_name, ' ', first_name),
    COALESCE(phone, 'Unknown') AS phone
FROM
    customers;
-- 上面的案例COALESCE替换为IFNULL也可以。


# 3.7 IF和CASE
# 将订单表中订单按是否是今年的订单分类为 active（活跃）和 archived（存档），之前讲过用UNION法，即用
# 两次查询分别得到今年的和今年以前的订单，添加上分类列再用UNION合并，这里直接在SELECT里运用IF函数可
# 以更容易地得到相同的结果
USE sql_store;
SELECT *,
       IF(YEAR(order_date) = YEAR(NOW()), '活跃用户', '非活跃用户') AS category
FROM
    orders;

# 得到包含如下字段的表：
# 1. product_id
# 2. name(产品名称)
# 3. orders(该产品出现在订单中的次数)
# 4. frequency(根据是否多于一次而分类为'Once'或'Many times')
USE sql_store;
SELECT
    product_id,
    name,
    COUNT(*)                               AS orders,
    IF(COUNT(*) = 1, 'Once', 'Many times') AS frequency
FROM
    products
        JOIN order_items USING (product_id)
GROUP BY
    product_id;

# 不是将订单分两类，而是分为三类：今年的是'Active', 去年的是'Last Year', 比去年更早的是'Achived'：
USE sql_store;

SELECT
    order_id,
    CASE
        WHEN YEAR(order_date) = YEAR(NOW())
            THEN '活跃用户'
        WHEN YEAR(order_date) = YEAR(NOW()) - 1
            THEN '去年活跃用户'
        WHEN YEAR(order_date) < YEAR(NOW()) - 1
            THEN '非活跃用户'
            ELSE '未来'
    END AS '是否为活跃用户'
FROM
    orders;
# ELSE 'Future' 是可选的，实验发现若分类不完整，比如只写了今年和去年的两个分类条件，则不在这两个分类的
# 记录的category字段会得到是null（当然）.

# 得到包含如下字段的表：customer, points, category（根据积分<2k，2k~3k（包含两端），>3k分为青铜白银
# 和黄金用户）
# 之前也是用过UNION法，分别查询加分类字段再合并，很麻烦。
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

# 其实也可以用IF嵌套，但感觉没有CASE语句结构清晰、可读性好
SELECT
    CONCAT(last_name, '' first_name)        AS 用户名,
    points,
    IF(points < 2000, '青铜',
       IF(points BETWEEN 2000 AND 3000, '白银',
          IF(points > 3000, '黄金', NULL))) AS 用户分类
FROM
    customers;

# 其实分类条件可以进一步简化如下：
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

-- 或

SELECT
    CONCAT(last_name, '', first_name)      AS 用户名,
    points,
    IF(points < 2000, '青铜',
       IF(points <= 3000, '白银', '黄金')) AS 用户分类
FROM
    customers
ORDER BY
    points DESC;
-- 结果是一样的，更简洁。
-- 但有时候像前面那样写的虽然冗余但详细一点，可以提高可读性。

-- 想统计2019年下半年的结果

# 	目标								total_sales					total_payments    what_we_expect(the difference)
# 	date_range
# 	1st_half_of_2019
# 	2nd_half_of_2019
# 	Total
# 	思路：分类子查询 + 聚合函数 + UNION

USE invoicing;
SELECT
    '上半年'                           AS 统计日期,
    SUM(invoice_total)                 AS total_sales,
    SUM(payment_total)                 AS total_payments,
    SUM(invoice_total - payment_total) AS what_we_expect
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-01-01' AND '2019-06-30'

UNION
SELECT
    '下半年'                           AS 统计日期,
    SUM(invoice_total)                 AS total_sales,
    SUM(payment_total)                 AS total_payments,
    SUM(invoice_total - payment_total) AS what_we_expect
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-07-01' AND '2020-01-01'

UNION
SELECT
    'Total'                            AS 统计日期,
    SUM(invoice_total)                 AS total_sales,
    SUM(payment_total)                 AS total_payments,
    SUM(invoice_total - payment_total) AS what_we_expect
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-01-01' AND '2019-12-31';
