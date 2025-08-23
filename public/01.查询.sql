/*
  TODO：
  数据库问题
1. 查询名字长度大于2的数据
2. 查询id重复的数据
3. nvl


  查询操作中关键字的含义：
    SELECT：检索表格数据
        AS：给列字段起别名，也可以用空格代替AS。
        DESTINY：去除重复的行。
    FROM：选择表
    WHERE：根据条件过滤记录/行
    ORDER BY：对结果排序
        ASC 升序（默认内省）
        DESC 降序
    GROUP BY：聚合函数的分组
    HAVING：分组过滤
    LIMIT：限制结果数量

    INNER JOIN / JOIN：内连接。返回两张表匹配的记录
    LEFT JOIN：左连接（外）。左表返回所有记录，右表匹配左表
    RIGHT JOIN：右连接（外）。右表返回所有记录，左表匹配右表
    FULL JOIN：
    CROSS JOIN：将每个表的每个字段都排列出来

    ON：连接条件
    USING：连接条件
    ROLLUP：
    UNION：

  SQL语法注意事项
    1. SQL语句以分号表示结束。
    2. SQL无视所有大小写和空格，换行和空格只是为了美观，关键字建议使用大写。
    3. 注释
      #       表示单行注释
    斜杠**斜杠   表示多行注释
*/


# SELECT 语句
#     注意： * 表示查询所有的字段，这里只是为了方便演示，如果数据量特别大，不要使用*，会造成服务器或者网络负担。
#     SELECT选择的不仅可以是列，也可以是数字、列间表达式、列的聚合函数
#     列字段中可以使用算数运算 + - * / %

# 检索用户id小于10的用户信息，并根据first_name排序。
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
    name AS          商品名称,
    unit_price,
    unit_price * 1.1 'new price'
FROM
    products;

#  DISTINCT 表示去重,返回的两行数据完全重复才可以去重

#     检索手机号是11位的用户信息，根据州去重
USE sql_store;
SELECT DISTINCT
    state
FROM
    customers
WHERE
    LENGTH(phone) = 11;

/*
WHERE子句：行筛选条件，实际是一行一行或一条条记录依次验证是否符合条件，进行筛选

比较运算符： >、 < 、= 、>=、 <= 、!=  或 <>
*/
# 查询points大于3000的用户信息
SELECT *
FROM
    customers
WHERE
    points > 3000;

# 查询state不是VA的用户信息
SELECT *
FROM
    customers
WHERE
    state != 'VA';
# SQL中不区分大小写，所以'VA'和'va'效果一样

# 查询2019年的订单
# 注意SQL里日期的标准写法以及其需要用引号包裹
SELECT *
FROM
    orders
WHERE
    order_date > '2019-01-01';

/*
   逻辑运算符：AND、OR、NOT
           AND：需要满足所有条件
           OR：只需要满足一个
           NOT：取反
   用逻辑运算符AND、OR、NOT对数学运算和比较运算进行组合实现多重条件筛选
   执行优先级：数学→比较→逻辑

*/
# 查询90后并且积分大于1000的用户信息
SELECT *
FROM
    customers
WHERE
      birth_date > '1990-01-01'
  AND points > 1000;

# 查询用户信息。要么是90后，要么积分大于1000并且州为VA
SELECT *
FROM
    customers
WHERE
     birth_date > '1990-01-01'
  OR points > 1000
         AND state = 'VA';

# 等于以上代码
# AND优先级高于OR，但最好加括号，代码更清晰
SELECT *
FROM
    customers
WHERE
     birth_date > '1990-01-01'
  OR (points > 1000 AND state = 'VA');

# 查询 除了90后以及除了积分大于1000的用户信息
# 任何Boolean值都可以取返
SELECT *
FROM
    customers
WHERE
    NOT (birth_date > '1990-01-01' OR points > 1000);
# NOT 在这里就是除了的意思
# 同上
SELECT *
FROM
    customers
WHERE
      birth_date <= '1990-01-01'
  AND points <= 1000;

# 查询订单6中总价大于30的商品
SELECT *
FROM
    order_items
WHERE
      order_id = 6
  AND quantity * unit_price > 30;
# 总价 = 数量 * 单价

/*
   特殊比较运算：IN、BETWEEN、LIKE、REGEXP、IS NULL
           IN（a,b）：表示包含a或者b
           BETWEEN a AND b:表示在a和b之间 或 NOT BETWEEN 10 AND 20:表示不在10~20之间
           LIKE：模糊匹配
           REGEXP：正则匹配
           IS NULL：判断是否 IS NULL（为空）或 IS NOT NULL（不为空）
*/
# IN
# 用IN运算符将某一属性与多个值（一列值）进行比较 ，
# 实质是多重相等比较运算条件的简化
# 选出'va'、'fl'、'ga'三个州的顾客
SELECT *
FROM
    customers
WHERE
     state = 'VA'
  OR state = 'FL'
  OR state = 'GA';

# 注意：
# 不能 state = 'va' OR 'fl' OR 'ga' 因为数学和比较运算优先于逻辑运算，
# 加括号 state = ('va' OR 'fl' OR 'ga') 也不行，逻辑运算符只能连接布尔值。
# 使用IN简化以上WHERE子句
SELECT *
FROM
    customers
WHERE
    state IN ('va', 'fl', 'ga');
# 也可以加NOT，表示不包含这三个洲的顾客，NOT IN 表示取反的意思。
SELECT *
FROM
    customers
WHERE
    state NOT IN ('VA', 'FL', 'GA');

# 查询库存量刚好为100、500、72的产品信息
SELECT *
FROM
    products
WHERE
    quantity_in_stock IN (100, 500, 72);

# BETWEEN
# 表示范围型条件
# BWTWEEN之间用AND
# 必须闭区间，包含两端点
# 也可用于日期，毕竟日期本质也是数值，日期也有大小（早晚），可比较运算
# 同 IN 一样，BETWEEN 本质也是一种特定的 多重比较运算条件 的简化
# 选出积分在1k到3k的顾客
SELECT *
FROM
    customers
WHERE
      points >= 1000
  AND points <= 3000;
# 以上代码可简化为
SELECT *
FROM
    customers
WHERE
    points BETWEEN 1000
        AND 3000;
# 选出90后的顾客，（那就是90年到20年之间）
SELECT *
FROM
    customers
WHERE
    birth_date BETWEEN '1990-01-01'
        AND '2000-01-01';
#  BWTWEEN 前面也可以加 NOT ，NOT BETWEEN 表示不在这个范围区间。

# 选出不包含90后的顾客
SELECT *
FROM
    customers
WHERE
    birth_date NOT BETWEEN '1990-01-01'
        AND '2000-01-01';

# LIKE
#  模糊查找，查找具有某种模式的字符串的记录或行
# 注意
#  过时用法（但有时还是比较好用），下节课的正则表达式更灵活更强大
#  注意和正则表达式一样都是用引号包裹表示字符串,引号内描述想要的字符串模式
#  % 任何个数(包括0个）的字符(类似通配符里的*)
#    '%abc%' 表示包含abc
#    'a%' 表示以a开头
#    '%a' 表示以a结尾
#  _ 单个字符(类似通配符里的？)

# 筛选以brush开头的用户信息
SELECT *
FROM
    customers
WHERE
    last_name LIKE 'brush%';

# 筛选b和y之间包含四个字符的用户信息
SELECT *
FROM
    customers
WHERE
    last_name LIKE 'b____y';

# 分别选择满足如下条件的顾客：
# 1.地址包含'TRAIL'或'AVENUE'
# 2.电话号码以9 结束
SELECT *
FROM
    customers
WHERE
     address LIKE '%trail%'
  OR address LIKE '%avenue%'
  OR phone LIKE '%9';
# REGEXP
# - 正则表达式，在搜索字符串方面更为强大，可搜索更复杂的模板
#  - 以下为常用规则
#     符号          含义
#     ^           beginning
#     $           end
#     [abc]       含列表中的字母
#     [^abc]      不含列表中的字母
#     [a-f]       含a-f的
#     还有很多自己去查！！！
# 查找 姓中包含field的用户信息
SELECT *
FROM
    customers
WHERE
    last_name LIKE '%field%';
# 等效于
SELECT *
FROM
    customers
WHERE
    last_name REGEXP 'field';

# - 分别选择满足如下条件的顾客：
# 1. first names是ELKA或AMBUR
# 2. last names 以 EY或ON结束
# 3. last names以MY开头或包含SE
# 4. last names 包含BR或BU
SELECT *
FROM
    customers
WHERE
    first_name REGEXP 'elka|ambur' WHERE
    last_name REGEXP 'ey$|on$'
WHERE
    last_name REGEXP '^my|se'
WHERE
    last_name REGEXP 'b[ru]';
# 或 'br|bu'

#  注意
# - like 和 regexp 的模糊搜索里对文本模式的表达依旧不区分大小写
# - like 和 regexp 本质上也是条件判断，结果也是布尔值，自然也可以加 NOT 取反：NOT LIKE、NOT REGEXP

#  IS NULL
# - 找出空值，找出有某些属性缺失的记录
# 找出电话号码缺失的顾客，也许发个邮件提醒他们之类
SELECT *
FROM
    customers
WHERE
    phone IS NULL;
# 既然有 IS NULL 那就有 IS NOT NULL
# 注意：IS NULL 和IS NOT NULL（而非 NOT IS NULL）,这里NOT更符合英语语法的放在be动词后


# 找出还没发货的订单 (在线商城管理员的常见查询需求)
SELECT *
FROM
    orders
WHERE
    shipper_id IS NULL;

/*ORDER BY子句：对结果排序
- ASC 升序（默认内省）小到大
- DESC 降序
-   可以包含多列，可包括没选择的列（MySQL特性），不仅可以是列，也可是列间的数学表达式以及之前定义好的别名列
（MySQL特性）。
    总之，MySQL 里 ORDER BY 子句里可选排序依据的灵活性极大
-   最好别用 ORDER BY 1, 2（表示以 SELECT …… 选中列中的第1、2列为排序依据） 这种隐性依据，因为SELECT选择
的列一变就容易出错，还是显性地写出列名作为排序依据比较好
*/
SELECT
    `name`,
    unit_price,
    unit_price * 1.1 + 10 new_price
FROM
    products
# ORDER BY
#     new_price
# ORDER BY
#         unit_price
ORDER BY
    unit_price * 0.9;
# unit_price * 0.9 这样的数学运算也可以，只不过这个当前好像没意义！


# - 订单2的商品按总价降序排列
# 可以以总价的数学表达式为排列依据
SELECT *
FROM
    order_items
WHERE
    order_id = 2
ORDER BY
    quantity * unit_price DESC;

# 亦可以先定义总结别名，然后以别名为排列依据。（和以上的效果一样）

SELECT *,
       quantity * unit_price total_price
FROM
    order_items
WHERE
    order_id = 2
ORDER BY
    total_price DESC;


/*LIMIT： 限制返回结果的记录数量，“前N个” 或 “跳过M个后的前N个"*/

# 表示前限制3条数据
SELECT *
FROM
    customers
LIMIT 3;

# 表示限制前300行数据
SELECT *
FROM
    customers
LIMIT 300;

# 表示跳过前6条后，取前3条
# - 6,3表示跳过前6个，取第7~9个，6是偏移量，
# - 如：网页分页中每3条记录显示一页，第3页应该显示的记录就是limit 6,3
SELECT *
FROM
    customers
LIMIT 6,3;


# 根据points降序排列，限制三行
# - 由于不需要筛选条件，这里就没有WHERE
SELECT *
FROM
    customers
ORDER BY
    points DESC
LIMIT 3;

/*
多表联查
    目标：
        1. 会 inner join 和left join 的使用就能满足几乎所有的情景
        2. 了解 USING
        3. 了解 UNION

    1. inner join 内连接。（包含两张表共有的部分）
        1.1 跨数据库连接
        1.2 self join （自连接）
        1.3 多表连接（两张表以上）
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

/*
INNER JOIN 内连接
*/
# 查询所有的订单信息以及对应的客户信息。（意思就是既要有用户信息，还要有订单信息）
USE sql_store;
SELECT
    o.order_id,
    o.customer_id,
    first_name,
    last_name
FROM
    orders o
        INNER JOIN customers c
                   ON o.customer_id = c.customer_id
ORDER BY
    o.order_id;

# 查询每个订单都包含哪些商品信息
USE sql_store;
SELECT
    order_id      关联订单ID,
    oi.product_id 关联商品ID,
    name          商品名称,
    quantity      购买数量,
    oi.unit_price 商品单价
FROM
    order_items oi
        JOIN products p
             ON oi.product_id = p.product_id;

# 1.2 跨数据库连接
# 语法没区别就是表前面加数据库名
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
# 效果同上。（以不同的表为主）
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

# 1.3 自连接
# 通过employees表中的reports_to字段与employee_id字段关联
# e.reports_to 对应的就是员工id，因为他要对应他的上级 m.employee_id 则为员工的上级员工的id

# 内连接中的自连接。（只包含员工信息和员工对应的管理者信息）
USE sql_hr;
SELECT
    e.employee_id Emp_id,
    e.first_name  员工姓名,
    m.first_name  管理者姓名
FROM
    employees e
        JOIN employees m
             ON e.reports_to = m.employee_id;

# 左外连接中的自连接。（包含所有的员工信息，管理者也算员工，只是上司为NULL）
SELECT
    e.employee_id Emp_id,
    e.first_name  Emp,
    m.first_name  Manger
FROM
    employees e
        LEFT JOIN employees m ON e.reports_to = m.employee_id;

# 1.4 多表连接（两张表以上）
# 订单表同时连接顾客表和订单状态表，合并为有顾客信息和状态详情信息的详细订单表
USE sql_store;
SELECT
    o.order_id   订单编号,
    o.order_date 订单日期,
    c.first_name 名字,
    c.last_name  姓氏,
    os.name      订单状态,
    os.comment   订单状态说明
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id
        JOIN order_statuses os
             ON o.status = os.order_status_id;
# 同理，支付记录表连接顾客表和支付方式表形成顾客支付记录详情表
USE sql_invoicing;
SELECT
    p.invoice_id 关联发票ID,
    p.date       支付日期,
    p.amount     实付金额,
    c.name       委托方名称,
    pm.name      支付方式名称
FROM
    payments p
        JOIN clients c
             ON p.client_id = c.client_id
        JOIN payment_methods pm
             ON p.payment_method = pm.payment_method_id;
# 1.5 复合连接
#     就是某张表依赖其他多张表的信息

# 将订单项目表和订单项目备注表合并
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

# 1.6 （尽量别用）隐含连接

# 合并顾客表和订单表
USE sql_store;
SELECT *
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id;

# 隐式合并语法
SELECT *
FROM
    orders o,
    customers c
WHERE
    o.customer_id = c.customer_id;
/*
LEFT JOIN/RIGHT JOIN ：OUTER JOIN 外连接
左外连接/右外连接
*/

# 合并顾客表和订单表
USE sql_store;
SELECT *
FROM
    orders o
        JOIN customers c
             ON o.customer_id = c.customer_id;
# 以上使用的是inner join，下面我们使用 outer join
# 可以发现，使用LEFT JOIN 和 INNER JOIN 效果一样，但是使用RIGHT JOIN 会查出所有的用户信息，哪怕对应的订单信息为NULL
USE sql_store;
SELECT *
FROM
    orders o
        LEFT JOIN customers c
                  ON o.customer_id = c.customer_id;

SELECT *
FROM
    orders o
        RIGHT JOIN customers c
                   ON o.customer_id = c.customer_id;

# 以上两个连接的区别？
# 1. 使用inner join只展示有客户信息的订单信息。
# 2. 使用right join展示所有顾客信息以及对应的订单信息，没有顾客信息的订单信息为null填充。


# 展示各产品在订单项目中出现的记录和销量，也要包括没有订单的产品
# （首先肯定不用INNER JOIN，其次那就是以product为左表）
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

# 2.1 多表外连接
# 查询顾客、订单和发货商记录，要包括所有顾客（包括无订单的顾客），也要包括所有订单（包括未发出的）
# （只要说包含所有，就肯定不用INNER JOIN）
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

# 查询 订单 + 顾客信息 + 物流信息 + 订单状态信息，所有的订单（包括未发货的）
# 其实就只是前两个优先级变了一下，是要看全部订单而非全部顾客了
# 那就以order表为主表，最后一句是要所有的订单信息包括未发货的，如何判断是否发货就是看有没有承运商信息，
# 没有承运商信息就是未发货，那承运商信息就是 NULL，那承运商信息表就不能使用INNER JOIN ，只能使用LEFT JOIN
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

# 其他连接
# 3. （最好别用）自然连接 Natural Joins
USE sql_store;
SELECT
    o.order_id   用户编号,
    c.first_name 用户名
FROM
    orders o
        NATURAL JOIN customers c;

# CROSS JOIN 交叉连接

# 得到用户和商品的所有组合，所以不需要合并条件
USE sql_store;
SELECT
    c.first_name 用户,
    p.name       商品
FROM
    customers c
        CROSS JOIN products p
ORDER BY
    c.first_name;

# 上面是显性语法还有隐式语法
USE sql_store;
SELECT
    c.first_name 用户,
    p.name       商品
FROM
    customers c,
    products p
ORDER BY
    c.first_name;

# 交叉合并shippers和products，分别用显式和隐式语法
USE sql_store;
SELECT
    p.name 商品,
    s.name 快递
FROM
    products p,
    shippers s
ORDER BY
    s.name;

# 同上
USE sql_store;
SELECT
    p.name 商品,
    s.name 快递
FROM
    shippers s
        CROSS JOIN products p
ORDER BY
    s.name;

/*
USING
*/

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

# 复合主键表的复合连接条件的合并也可用USING
USE sql_store;
SELECT *
FROM
    order_items oi
        JOIN order_item_notes oin
             ON oi.order_id = oin.order_Id AND oi.product_id = oin.product_id;

# 使用USING
# 注意：一定注意USING后接的是括号，特容易搞忘
SELECT *
FROM
    order_items oi
        JOIN order_item_notes oin
             USING (order_id, product_id);
# USING对复合主键的简化效果更加明显

# sql_invoicing库里，将payments、clients、payment_methods三张表合并起来，以知道什么日期谁用什么方式付了多少钱
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
# 注意
# 列名不同就必须用 ON …… 了
# 实际中同一个字段在不同表列名不同的情况也很常见，不能想当然的用 USING，要先确认一下

# UNION 联合
# 其实UNION前面还是后面SQL语句都类似，就是筛选条件不一样，可能还会有新的列名。仅此而已！
# 注意：
# 1. 使用UNION，多个SELECT中只需要在第一个SELECT中定义别名即可
# 2. 如果使用ORDER BY也必须使用别名，如：
# 	    ORDER BY 用户编号 ; 正确写法
# 	    ORDER BY customer_id ; 错误写法

# 给订单表增加一个新字段——‘年份区分’，用以区分今年的和以前的订单
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

# 合并不同表的例子：同一列表里显示所有顾客以及商品名。（这个案例好像没啥意义！）
USE sql_store;
SELECT
    first_name AS 'Customers and Products of name'
# 新列名由排UNION前面的决定
FROM
    customers
UNION
SELECT
    name
FROM
    products;

# 给顾客按积分大小分类，添加新字段type，并按顾客id排序，分类标准如下
# points			  	 type
# <2000				 青铜用户
# 2000~3000		     白银用户
# >3000 		   	     黄金用户
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

# 分别统计 2019年上半年与下半年的发票总额，实际支付总额和差额。

# 	统计日期			total_invoice（发票总额）		total_payments（实际支付总额）    what_we_expect(the difference)差额
# 	上半年
# 	下半年
# 	Total
# 	思路：分类子查询 + 聚合函数 + UNION
USE sql_invoicing;
SELECT
    '上半年'                           AS 统计日期,
    SUM(invoice_total)                 AS total_invoice（开票总额）,
    SUM(payment_total)                 AS total_payments（支付总额）,
    SUM(invoice_total - payment_total) AS what_we_expect（差额）
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-01-01' AND '2019-06-30'

UNION
SELECT
    '下半年',
    SUM(invoice_total),
    SUM(payment_total),
    SUM(invoice_total - payment_total)
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-07-01' AND '2020-01-01'

UNION
SELECT
    'Total',
    SUM(invoice_total),
    SUM(payment_total),
    SUM(invoice_total - payment_total)
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-01-01' AND '2019-12-31';

#GROUP BY子句
# 按一列或多列分组，注意语句的位置。

# 按照一个字段分组
# 在invoices表中按不同顾客分组统计各个顾客下半年（2019年7月1号开始）开票总额并降序排列
# 各个顾客分组那就用顾客id分组！
USE sql_invoicing;
SELECT
    client_id,
    SUM(invoice_total) AS 开票总额
FROM
    invoices
WHERE
    invoice_date BETWEEN '2019-07-01' AND '2020-01-01'
GROUP BY
    client_id;


# 按照多个字段分组
# 汇总每个洲以及所对应的城市的开票总额
SELECT
    state,
    city,
    SUM(invoice_total) AS 开票总额
FROM
    invoices
        JOIN clients
             USING (client_id)
GROUP BY
    state, city
ORDER BY
    state;

# 在 payments 表中，按日期和支付方式分组统计总付款额。
# 意思就是分别统计出每日使用哪些支付方式，以及支付额度
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
#HAVING子句
# WHERE 和 HAVING 很相似，语法也一致，区别在于：
# 1. WHERE过滤行级数据 (原始表中的记录)，HAVING过滤组级数据（GROUP BY后的分组结果）
# 2. WHERE不能使用聚合函数（如：COUNT()、SUM()），HAVING可以使用聚合函数
# 3. WHERE在GROUP BY之前执行，HAVING在GROUP BY之后执行
# 4. WHERE只能使用表中存在的原始字段，HAVING可以使用原始字段，亦可以使用SELECT中定义的别名。


# 筛选支付总额大于500 并且 付款次数大于5的用户信息
USE sql_invoicing;
SELECT
    client_id,
    SUM(invoice_total) AS 支付总额,
    COUNT(*)           AS 付款次数
FROM
    invoices
GROUP BY
    client_id
HAVING
      支付总额 > 500
  AND 付款次数 > 5;

# 查找支付总额 大于100 并且 省份为陕西的用户信息，最好是用户名
USE sql_store;
SELECT
    c.customer_id,
    CONCAT(last_name, ' ', first_name) AS 用户名,
    SUM(oi.quantity * oi.unit_price)   AS 支付总额
FROM
    customers c
        JOIN orders o USING (customer_id)
        JOIN order_items oi USING (order_id)
WHERE
    state = '陕西'
GROUP BY
    c.customer_id
HAVING
    支付总额 > 100;

# ROLLUP 运算符（自动汇总）
# GROUP BY …… WITH ROLLUP 表示自动汇总（对 SUM 之类的聚合值进行分组汇总），若是多字段分组的话汇总也会是多层次的.
# 注意这是MySQL扩展语法，不是SQL标准语法
USE sql_invoicing;
SELECT
    client_id,
    SUM(invoice_total)
FROM
    invoices
GROUP BY
    client_id
WITH
    ROLLUP;
# 当然，总发票额那一行对应的client_id为空！！！

SELECT
    state,
    city,
    SUM(invoice_total) AS total_sales
FROM
    invoices
        JOIN clients USING (client_id)
GROUP BY
    state, city
WITH
    ROLLUP;
# 先按 city 汇总、再按 state 汇总、最后在总汇总。与分组顺序相反（当然，分组和汇总本来就是相反的两个过程）

USE sql_invoicing;
SELECT
    date,
    pm.name     AS pay_method,
    SUM(amount) AS total_payments
FROM
    payments p
        JOIN payment_methods pm
             ON p.payment_method = pm.payment_method_id
GROUP BY
    date, pay_method
WITH
    ROLLUP;

SELECT
    pm.name     AS payment_method,
    SUM(amount) AS total
FROM
    payments p
        JOIN payment_methods pm
             ON p.payment_method = pm.payment_method_id
GROUP BY
    pm.name
WITH
    ROLLUP;

# 子查询
#     子查询： 任何一个充当另一个SQL语句的一部分的 SELECT 查询语句都是子查询，子查询是一个很有用的技巧。
# 子查询的层级用括号实现。
#     注意：
#       一般多加括号都不会有问题，只有少加括号才会出问题，所以不确定执行顺序是否正确时最好加上括号确保万无一失。
#       MySQL执行时会先执行括号内的子查询（内查询），将获得的生菜价格作为结果返回给外查询

#   在products中，找到所有比Iphone16（id = 1）价格高的
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

# IN运算符
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

# 子查询 VS JOIN
#     子查询（Subquery）是将一张表的查询结果作为另一张表的查询依据并层层嵌套，其实也可以先将这些表连接
# （Join）合并成一个包含所需全部信息的详情表再直接在详情表里筛选查询。两种方法一般是可互换的，具体用哪
# 一种取决于 性能（Performance） 和 可读性（readability），之后会学习 执行计划，到时候就知道怎样编写并
# 更快速地执行查询，现在主要考虑可读性

# 上节课的案例，找出从未订购（没有invoices）的顾客：
# 方式1. 子查询
# 先用子查询查出有过发票记录的顾客名单，作为筛选依据
USE sql_invoicing;
SELECT *
FROM
    clients
WHERE
    client_id NOT IN (
                     SELECT DISTINCT
                         client_id
                     /*
                     其实这里加不加DISTINCT对子查询返回的结果有影响
                     但对最后的结果没有影响
                     */
                     FROM
                         invoices);

# 法2. 连接表
# 用顾客表 LEFT JOIN 发票记录表，再直接在这个合并详情
# 表中筛选出发票记录为空的顾客
USE sql_invoicing;
SELECT DISTINCT
    client_id,
    name
# 不能SELECT DISTINCT *
FROM
    clients
        LEFT JOIN invoices USING (client_id)
# 【注意不能用内连接，否则没有发票记录的顾客（我们的目标）直接就被筛掉了】
WHERE
    invoice_id IS NULL;

# 查询买过iphone16的客户信息
#    方式1：完全子查询
USE sql_store;
SELECT
    customer_id,
    first_name,
    last_name
FROM
    customers
WHERE
    customer_id IN (
                   SELECT
                       orders.customer_id
                   FROM
                       orders
                   WHERE
                       order_id IN (
                                   SELECT
                                       order_id
                                   FROM
                                       order_items
                                   WHERE
                                       product_id = 1));
#    方式2：子查询+表连接
SELECT
    customer_id,
    last_name,
    first_name
FROM
    customers
WHERE
    customer_id IN (
                   SELECT
                       o.customer_id
                   FROM
                       orders o
                           JOIN order_items oi ON o.order_id = oi.order_id
                   WHERE
                       product_id = 1);
#    方式3：完全表连接
SELECT DISTINCT
    c.customer_id,
    first_name,
    last_name
FROM
    customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
WHERE
    product_id = 1;
# 可以看出来，多重子查询更清晰明了


# ALL
#     > (MAX (……)) 和 > ALL(……) 等效可互换
# “比这里面最大的还大” = “比这里面的所有的都大”
USE sql_invoicing;
SELECT *
FROM
    invoices
WHERE
    invoice_total > (
                    SELECT
                        MAX(invoice_total)
                    FROM
                        invoices
                    WHERE
                        client_id = 5);

USE sql_invoicing;
SELECT *
FROM
    invoices
WHERE
    invoice_total > ALL (
                        SELECT
                            invoice_total
                        FROM
                            invoices
                        WHERE
                            client_id = 5);
# ANY
USE sql_invoicing;
SELECT *
FROM
    invoices
WHERE
    invoice_total > ANY (
                        SELECT
                            invoice_total
                        FROM
                            invoices
                        WHERE
                            client_id = 5);

USE sql_invoicing;
SELECT *
FROM
    clients
WHERE
    client_id IN ( # 或 = ANY (
                 # 子查询：有2次以上发票记录的顾客
                 SELECT
                     client_id
                 FROM
                     invoices
                 GROUP BY client_id
                 HAVING
                     COUNT(*) >= 2);
# 相关子查询
# EXISTS
# SELECT子句的子查询
# FROM子句的子查询