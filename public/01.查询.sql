/*
  查询中关键字的含义：
    SELECT：检索表格数据
    FROM：选择表
    WHERE：根据条件过滤记录/行
    ORDER BY：对结果排序
    GROUP BY：聚合函数的分组
    HAVING：分组过滤
    LIMIT：限制结果数量

    INNER JOIN / JOIN：内连接。返回两张表匹配的记录
    LEFT JOIN：左连接（外）。左表返回所有记录，右表匹配左表
    RIGHT JOIN：右连接（外）。右表返回所有记录，左表匹配右表

    ON：连接条件
    USING：连接条件
    ROLLUP：
    UNION：

  SQL语法注意事项
    1. SQL语句以分号表示结束。
    2. SQL无视所有大小写和空格，换行和空格只是为了美观，关键字建议使用大写。
    3. 注释
      --       表示单行注释
    斜杠**斜杠   表示多行注释
*/
/*
SELECT 语句
    - 注意： * 表示查询所有的字段，这里只是为了演示，如果数据量特别大，不要使用*，会造成服务器或者网络负担。
    - SELECT选择的不仅可以是列，也可以是数字、列间表达式、列的聚合函数
    - 列字段中可以使用算数运算 + - * / %
    - AS 表示起别名，也可以使用空格代替AS。
    - DISTINCT 表示去重。Distinct必须跟在Select之后
  FROM：表示来自哪个表（要查哪个表的数据）*/

# 检索用户id小于10的信息，并根据first_name排序。
USE sql_store; # 使用当前数据库
SELECT *
FROM
    customers
WHERE
    customer_id < 10
ORDER BY
    first_name;
# 单价涨价10%作为新单价
SELECT
    name,
    unit_price,
    unit_price * 1.1 'new price'
FROM
    products;

/*
WHERE子句：行筛选条件，实际是一行一行或一条条记录依次验证是否符合条件，进行筛选
    - 比较运算符： >、 < 、= 、>=、 <= 、!=  或 <>
    - 逻辑运算符：AND、OR、NOT
            AND：需要满足所有条件
            OR：只需要满足一个
            NOT：取反
    - 特殊比较运算：IN、BETWEEN、LIKE、REGEXP、IS NULL
            IN（a,b）：表示包含a或者b
            BETWEEN a AND b:表示在a和b之间 或 NOT BETWEEN 10 AND 20:表示不在10~20之间
            LIKE：模糊匹配
            REGEXP：正则匹配
            IS NULL：判断是否 IS NULL（为空）或 IS NOT NULL（不为空）
ORDER BY子句：对结果排序
    - ASC 升序（默认内省）
    - DESC 降序

LIMIT：限制返回结果的记录数量

*/


/*
INNER JOIN
*/

/*
LEFT JOIN
*/

/*
USING
*/

/*
UNION
*/

/*
GROUP BY
*/

/*
HAVING
*/


/*
多表联查
    目标：
        1. 会 inner join 和left join 的使用就能满足几乎所有的情景
        2. 了解 USING
        3. 了解 UNION

    1. inner join 内连接
        1.1 跨数据库连接
        1.2 self join （自连接）
        1.3 多表连接
        1.4 复合连接条件
        1.5 隐含连接语法

    2. outer join 外连接
        2.1 left join
        2.2 right join
        2.3 多表外连接
        2.4 自我外连接

    3. USING子句
        相当于ON，不过ON的写法是
                ...FROM table_a a JOIN table_b b on a.uid = b.uid;
                替换为USING写法是
                ...FROM table_a a JOIN table_b b USING (uid);

    4. UNION 联合

    5. 其他不常用的连接
        自然连接
        交叉连接

*/

-- 1. 内连接
USE sql_store;
SELECT
    o.order_id    商品编号,
    o.customer_id 用户编号,
    first_name    名字,
    last_name     姓氏
FROM
    orders o
        INNER JOIN customers c
                   ON o.customer_id = c.customer_id;

--  通过product_id结合orders_items和products
USE sql_store;
SELECT
    order_id      订单编号,
    oi.product_id 商品编号,
    name          商品名,
    quantity      购买数量,
    oi.unit_price 单价
FROM
    order_items oi
        JOIN products p
             ON oi.product_id = p.product_id;

-- 1.2 跨数据库连接
USE sql_store;
SELECT
    name          商品名,
    p.product_id  商品编号,
    oi.unit_price 单价
FROM
    order_items oi
        JOIN sql_inventory.products p
             ON oi.product_id = p.product_id
ORDER BY
    oi.unit_price DESC;
-- 效果同上
USE sql_inventory;
SELECT
    name          商品名,
    p.product_id  商品编号,
    oi.unit_price 单价
FROM
    products p
        JOIN sql_store.order_items oi
             ON p.product_id = oi.product_id
ORDER BY
    oi.unit_price DESC;

-- 1.3 自连接
-- 通过employees表中的reports_to字段与employee_id字段关联
-- e.reports_to 对应的就是员工id，因为他要对应他的上级 m.employee_id 则为员工的上级员工的id
USE sql_hr;
SELECT
    e.first_name 员工姓名,
    m.first_name 管理者姓名
FROM
    employees e
        JOIN employees m
             ON e.reports_to = m.employee_id;

-- 1.4 多表连接（两张表以上）
-- 订单表同时连接顾客表和订单状态表，合并为有顾客信息和状态详情信息的详细订单表
USE sql_store;
SELECT
    o.order_id   订单编号,
    o.order_date 订单日期,
    c.first_name 名字,
    c.last_name  姓氏,
    os.name      订单状态,
    os.comment   订单状态中文
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id
        JOIN order_statuses os
             ON o.status = os.order_status_id;
-- 同理，支付记录表连接顾客表和支付方式表形成顾客支付记录详情表
USE sql_invoicing;
SELECT
    p.invoice_id 发票编号,
    p.date       日期,
    p.amount     金额,
    c.name       客户名,
    pm.name      付款方式
FROM
    payments p
        JOIN clients c
             ON p.client_id = c.client_id
        JOIN payment_methods pm
             ON p.payment_method = pm.payment_method_id;
-- 1.5 复合连接
--     就是某张表依赖其他多张表的信息

-- 将订单项目表和订单项目备注表合并
USE sql_store;
SELECT
    oi.order_id   订单编号,
    oi.product_id 商品编号,
    oi.unit_price 单价,
    oi.quantity   数量,
    oin.note      备注
FROM
    order_items oi
        JOIN order_item_notes oin
             ON oi.order_id = oin.order_Id AND oi.product_id = oin.product_id;

-- 1.6 （尽量别用）隐含连接

-- 合并顾客表和订单表
USE sql_store;
SELECT *
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id;

-- 隐式合并语法
SELECT *
FROM
    orders o,
    customers c
WHERE
    o.customer_id = c.customer_id;

-- 2.外连接
-- 合并顾客表和订单表
USE sql_store;
SELECT *
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id;
-- 以上使用的是inner join，下面我们使用 outer join
USE sql_store;
SELECT *
FROM
    orders o
        RIGHT JOIN customers c
                   ON o.customer_id = c.customer_id;

-- 展示各产品在订单项目中出现的记录和销量，也要包括没有订单的产品
USE sql_store;
SELECT
    p.product_id 产品编号,
    oi.order_id  订单编号,
    p.name       产品名称,
    oi.quantity  购买数量
FROM
    products p
        LEFT JOIN order_items oi
                  ON p.product_id = oi.product_id;

-- 2.1 多表外连接
-- 查询顾客、订单和发货商记录，要包括所有顾客（包括无订单的顾客），也要包括所有订单（包括未发出的）
USE sql_store;
SELECT
    c.customer_id 用户编号,
    first_name    名字,
    o.order_id    订单编号,
    s.name        物流公司
FROM
    customers c
        LEFT JOIN orders o
                  ON c.customer_id = o.customer_id
        LEFT JOIN shippers s
                  ON o.shipper_id = s.shipper_id
ORDER BY
    c.customer_id;
-- 查询 订单 + 顾客信息 + 物流信息 + 订单状态信息，所有的订单（包括未发货的）
-- 其实就只是前两个优先级变了一下，是要看全部订单而非全部顾客了
USE sql_store;
SELECT
    o.order_id    订单编号,
    os.comment    订单状态,
    s.name        物流公司,
    c.customer_id 用户编号,
    first_name    名字
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id
        LEFT JOIN shippers s
                  ON o.shipper_id = s.shipper_id
        JOIN order_statuses os
             ON o.status = os.order_status_id;

-- 2.2 外部（自连接）

-- 就用前面那个员工表的例子来说，就是用LEF JOIN让得到的 员工-上级 合并表也包括老板本人（上级为空）
USE sql_hr;
SELECT
    e.employee_id 员工编号,
    e.first_name  员工名字,
    m.first_name  主管名字
FROM
    employees e
        LEFT JOIN employees m
                  ON e.reports_to = m.employee_id;

-- 3. USING子句
USE sql_store;
SELECT
    o.order_id   订单编号,
    c.first_name 用户名字,
    sp.name      快递公司
FROM
    orders o
        JOIN customers c
             USING (customer_id)
        LEFT JOIN shippers sp
                  USING (shipper_id)
ORDER BY
    order_id;

-- 复合主键表的复合连接条件的合并也可用USING
USE sql_store;
SELECT *
FROM
    order_items oi
        JOIN order_item_notes oin
             ON oi.order_id = oin.order_Id AND oi.product_id = oin.product_id;

-- 使用USING
-- 注意：一定注意USING后接的是括号，特容易搞忘
SELECT *
FROM
    order_items oi
        JOIN order_item_notes oin
             USING (order_id, product_id);
-- USING对复合主键的简化效果更加明显

-- sql_invoicing库里，将payments、clients、payment_methods三张表合并起来，以知道什么日期谁用什么方式
-- 付了多少钱
USE sql_invoicing;
SELECT
    p.date   付款日期,
    c.name   客户,
    pm.name  付款方式,
    p.amount 金额
FROM
    payments p
        JOIN clients c
             USING (client_id)
        JOIN payment_methods pm
             ON p.payment_method = pm.payment_method_id;
-- 注意
-- 列名不同就必须用 ON …… 了
-- 实际中同一个字段在不同表列名不同的情况也很常见，不能想当然的用 USING，要先确认一下

-- 3. （最好别用）自然连接 Natural Joins
USE sql_store;
SELECT
    o.order_id   用户编号,
    c.first_name 用户名
FROM
    orders o
        NATURAL JOIN customers c;

-- 4. 交叉连接

-- 得到用户和商品的所有组合，所以不需要合并条件
USE sql_store;
SELECT
    c.first_name 用户,
    p.name       商品
FROM
    customers c
        CROSS JOIN products p
ORDER BY
    c.first_name;

-- 上面是显性语法还有隐式语法
USE sql_store;
SELECT
    c.first_name 用户,
    p.name       商品
FROM
    customers c,
    products p
ORDER BY
    c.first_name;

-- 交叉合并shippers和products，分别用显式和隐式语法
USE sql_store;
SELECT
    p.name 商品,
    s.name 快递
FROM
    products p,
    shippers s
ORDER BY
    s.name;

-- 同上
USE sql_store;
SELECT
    p.name 商品,
    s.name 快递
FROM
    shippers s
        CROSS JOIN products p
ORDER BY
    s.name;

-- 5.联合 UNION
-- 给订单表增加一个新字段——status，用以区分今年的和以前的订单
USE sql_store;

SELECT
    order_id,
    order_date,
    '19年后' AS 年份区分
FROM
    orders
WHERE
    order_date >= '2019-01-01'

UNION

SELECT
    order_id,
    order_date,
    '19年前' AS 年份区分
FROM
    orders
WHERE
    order_date < '2019-01-01';

-- 合并不同表的例子：同一列表里显示所有顾客以及商品名
USE sql_store;
SELECT
    first_name AS name_of_all
-- 新列名由排UNION前面的决定
FROM
    customers
UNION
SELECT
    name
FROM
    products;

-- 给顾客按积分大小分类，添加新字段type，并按顾客id排序，分类标准如下
-- points			  	 type
-- <2000				 青铜用户
-- 2000~3000		 白银用户
-- >3000 			   黄金用户
USE sql_store;
SELECT
    customer_id   用户编号,
    first_name    用户名,
    points,
    '青铜用户' AS type
FROM
    customers
WHERE
    points < 2000
UNION
SELECT
    customer_id,
    first_name,
    points,
    '白银用户' AS type
FROM
    customers
WHERE
    points BETWEEN 2000 AND 3000
UNION
SELECT
    customer_id,
    first_name,
    points,
    '黄金用户' AS type
FROM
    customers
WHERE
    points > 3000
ORDER BY
    用户编号;
-- 注意：
-- 1. 使用UNION，多个SELECT中只需要第一个SELECT中定义别名即可
-- 2. 如果使用ORDER BY也必须使用别名，如：
-- 	ORDER BY 用户编号 ; 正确写法
-- 	ORDER BY customer_id ; 错误写法


/*
子查询
        IN 运算符
        子查询 VS JOIN
ALL


ANY
        相关子查询
EXISTS
        SELECT子句中的子查询
        FROM子句中的子查询

ROLLUP

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