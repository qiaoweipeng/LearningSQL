# 1.汇总数据
# 	汇总统计型查询非常有用，甚至可能常常是你的主要工作内容
# 	1.1 聚合函数
# 	聚合函数也是函数的一类，但是为了课程的连贯性需要结合后面的GROUP BY，所以在这里单独讲
# 	聚合函数：输入一系列值并聚合为一个结果的函数
USE sql_invoicing;
-- SELECT选择的不仅可以是列，也可以是数字、列间表达式、列的聚合函数
SELECT
    MAX(invoice_date),
    MAX(invoice_total),
    MIN(invoice_total),
    AVG(invoice_total),
    SUM(invoice_total * 1.1),
    COUNT(invoice_total),
    -- 和上一个结果一样
    COUNT(payment_date),
    -- 聚合函数会忽略空值，支付数少于发票数
    COUNT(DISTINCT client_id)
-- DISTINCT client_id筛掉了该列的重复值，再COUNT计数，不同顾客数
FROM
    invoices
WHERE
    invoice_date > '2019-07-01';
SELECT *
FROM
    invoices
WHERE
    invoice_date > '2019-07-01';
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
# 1.2 GROUP BY子句
# 按一列或多列分组，注意语句的位置。

# 按照一个字段分组
# 在发票记录表中按不同顾客分组统计各个顾客下半年总销售额并降序排列
USE invoicing;
SELECT
    client_id,
    SUM(invoice_total) AS total_sales
FROM
    invoices
WHERE
    invoice_date >= '2019-07-01'
GROUP BY
    client_id;
# 按照多个字段分组
# 汇总每个城市的总销售额
SELECT
    state,
    city,
    SUM(invoice_total) AS total_sales
FROM
    invoices
        JOIN clients
             USING (client_id)
GROUP BY
    state, city
ORDER BY
    state;

# 在 payments 表中，按日期和支付方式分组统计总付款额
USE sql_invoicing;
SELECT
    date,
    pm.name     AS payment_method,
    SUM(amount) AS total_payments
FROM
    payments p
        JOIN payment_methods pm
             ON p.payment_method = pm.payment_method_id
GROUP BY
    date, pm.name
ORDER BY
    date;
# 1.3 HAVING子句
USE sql_invoicing;
SELECT
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*)           AS number_of_invoices
FROM
    invoices
GROUP BY
    client_id
HAVING
      total_sales > 500
  AND number_of_invoices > 5;

USE sql_store;
SELECT
    c.customer_id,
    CONCAT(last_name, ' ', first_name) AS 用户名,
    SUM(oi.quantity * oi.unit_price)   AS total_sales
FROM
    customers c
        JOIN orders o USING (customer_id)
        JOIN order_items oi USING (order_id)
WHERE
    state = '陕西'
GROUP BY
    c.customer_id, last_name, first_name
HAVING
    total_sales > 100;
TODO;
# 1.4 ROLLUP

# 2.编写复杂查询
/*
主要是子查询，有的前面已经讲过了
*/

# 2.1 子查询
#     在products中，找到所有比Iphone16（id = 1）价格高的
# 关键：要找比Iphone16价格高的，得先用子查询找到IPhone16的价格
USE sql_store;
SELECT *
FROM
    products
WHERE
    unit_price > (
                 SELECT
                     unit_price
                 FROM
                     products
                 WHERE
                     product_id = 1);

# 在sql_hr.employees表里，选择所有工资超过平均工资的雇员
# 关键：先由子查询得到平均工资
USE sql_hr;
SELECT *
FROM
    employees
WHERE
    salary > (
             SELECT
                 AVG(salary)
             FROM
                 employees);

# 2.2 IN运算符
#     在sql_store.products找出那些从未被订购过的产品
#     思路：
# 1. orders.items表里有所有产品被订购的记录，从中可得到 所有被订购过的产品 的列表（注意用 DISTINCT 关键
# 字进行去重）
# 2. 不在这列表里（NOT IN 的使用）的产品即为从未被订购过的产品
USE sql_store;
SELECT *
FROM
    products
WHERE
    product_id NOT IN (
                      SELECT DISTINCT
                          product_id
                      FROM
                          order_items);
# 在 sql_invoicing.clients 中找到那些没有过发票记录的客户
# 思路：和上一个例子完全一致，在invoices里用DISTINCT找到所有有过发票记录的客户的列表，再用NOT IN来筛
# 选
USE sql_invoicing;
SELECT *
FROM
    clients
WHERE
    client_id NOT IN (
                     SELECT DISTINCT
                         client_id
                     FROM
                         payments);
# 2.3 子查询 VSJOIN
TODO
# 2.4 ALL关键字
# 2.5 ANY关键字
# 2.6 相关子查询
# 2.7 EXISTS运算符
# 2.8 SELECT子句的子查询
# 2.9 FROM子句的子查询


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