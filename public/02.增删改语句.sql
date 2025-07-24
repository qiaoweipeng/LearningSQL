/*
1. 增
    INSERT INTO table_name VALUES(); 不指名列名添加数据，必须按列顺序依次添加
    INSERT INTO table_name() VALUES(); 指明列名添加数据，可以自由添加。

2. 改
    UPDATE table_name SET
        要修改的字段 = 具体值 WHERE 行筛选

3. 删除
    DELETE FROM table_name WHERE 行筛选
*/

/*
INSERT
*/
# 插入单行数据
-- 在 顾客表中插入一条新顾客信息
USE sql_store;
-- 方式1：不指明列名（注意连括号也省了），但插入的值必须按所有字段的顺序完整插入
INSERT INTO
    customers
VALUES
    (default, '露', '王', '2003-07-15', DEFAULT, '北京中南海', '北京', '北京', 800, '123@qq.com', 30);

-- 方式2：指明列名，可跳过取默认值的列且可更改顺序。（推荐使用！）
INSERT INTO
    customers (first_name, last_name, address, city, state, email, membership_level)
VALUES
    ('杰', '刘', '西安市北大街55号', '西安市', '陕西', '44545454@gmail.com', 34);

# 插入多行数据
# 不论是插入单行还是多行，语句没啥区别！
USE sql_store;
# 指定列，插入数据
INSERT INTO
    shippers (name)
VALUES
    ('UPS'),
    ('中铁快运');

-- 插入多条产品信息
USE sql_store;
# 不指定列插入数据，需要按顺序插入所有数据
INSERT INTO
    products
VALUES
    (DEFAULT, '耳机1', 100, 30, 'EJ-01-01', NULL),
    (DEFAULT, '耳机2', 100, 20, 'EJ-01-02', NULL),
    (DEFAULT, '耳机3', 100, 60, 'EJ-01-03', NULL);

# 指定列，插入数据
INSERT INTO
    products (name, quantity_in_stock, unit_price)
VALUES
    ('耳机1', 100, 30),
    ('耳机2', 100, 20),
    ('耳机3', 100, 60);
-- 注意：对于AI (Auto Incremental 自动递增) 的id字段，MySQL会记住删除的/用过的id，并在此基础上递增

# 插入分级行
-- 新增一个订单（order）里面包含两个子订单项目（order_items），请同时更新order和order_items
USE sql_store;
# 1.先插入一条订单数据
INSERT INTO
    orders (customer_id, order_date, status)
VALUES
    (1, '2025-03-05', 1);
-- 可以先试一下用 SELECT last_insert_id() 看能否成功获取到的最新的order_id
SELECT LAST_INSERT_ID();
# 2.再插入两条订单项
INSERT INTO
    order_items -- 全是必须字段，就不用指定了。
VALUES
    (LAST_INSERT_ID(), 1, 2, 2.5),
    (LAST_INSERT_ID(), 2, 10, 30);


# 创建表的副本
-- 	方式1. 删除重建：DROP TABLE IF EXISTS 要删的表名 ;
#         CREATE TABLE 新表名 AS 子查询;
-- 	方式2. 清空重填：TRUNCATE '要清空的表名';
#         INSERT INTO 表名 子查询;

# 使用方法1创建。将旧表所有数据备份到新表中。
USE sql_store;
CREATE TABLE orders_archived AS
SELECT * -- 子查询
FROM
    orders;

-- 删除orders_archived表
DROP TABLE IF EXISTS orders_archived;

# 使用方式1创建。将符合条件的数据放到新表中。
USE sql_store;
DROP TABLE IF EXISTS orders_archived; -- 先删除表
CREATE TABLE orders_archived AS -- 然后创建表并添加内容
SELECT *
FROM
    orders
WHERE
    order_date < '2019-01-01';

-- 使用方式2创建。将符合条件的数据放到新表中。
TRUNCATE TABLE orders_archived; -- 先清空表。（前提是要有表，没有表那也没法清空）
INSERT INTO
    orders_archived -- 添加符合条件的信息到新表。（不用指明列名，会直接用子查询里的列名）
SELECT * -- 子查询，代替原先插入语句中VALUES(....,....)...的部分
FROM
    orders
WHERE
    order_date < '2019-01-10';


/*
创建一个发票存档表，字段有发票唯一标识、委托方名称、实际支付日期，必须是有过支付记录。
思路：
	1. 先创建子查询，确定新表的内容。
		a. 合并发票和用户表
		b. 筛选支付记录不为空的信息
		c. 筛选需要的列（重命名）
	2. 第一步得到的查询内容，先运行看结果在将子查询的内容存到新表中*/
USE sql_invoicing;
# 先删除表
DROP TABLE invoices_archived;
# 创建表
CREATE TABLE invoices_archived AS
    # 新表的内容
SELECT
    i.invoice_id 发票唯一标识,
    c.name       委托方名称,
    i.payment_total
#     i.payment_date '实际支付日期'
# 注意：这里的别名尽量不要用中文或干脆不要用别名，要不然后面的where匹配可能会出现问题！
FROM
    invoices i
        JOIN clients c
             ON i.client_id = c.client_id
WHERE
    i.payment_total IS NOT NULL;

/*
UPDATE
语法：
    UPDATE 表
    SET 要修改的字段 = 具体值 / NULL / DEFAULT / 数学表达式 /其他字段的值（修改多个字段用逗号分隔）
    WHERE 行筛选

    更新数据，可以更新单行或多行，限制条件是单行就是单行，多行就是多行。
    注意：更新数据一定要有WHERE限制条件，要不然全部都被修改了！
*/

# 将某些商品信息修改完整
USE sql_store;
UPDATE products
SET
    name       = 'AirPods4苹果蓝牙耳机',
    unit_price = 1299
WHERE
    name LIKE '%耳机1%';

-- 给所有非90后顾客增加50点积分
USE sql_store;
UPDATE customers
SET
    points = points + 50
WHERE
    birth_date NOT BETWEEN '1990-01-01' AND '2000-01-01';

-- 查询测试
SELECT
    birth_date,
    points
FROM
    customers
WHERE
    birth_date NOT BETWEEN '1990-01-01' AND '2000-01-01';

# UPDATE中使用子查询
#     1. 子查询先放入括号中，确保先执行
#     2. 可以看到子查询这里既可以用 = ，亦可以用 IN 匹配,不论返回单条还是多条记录。
#     3. Update 前，最好先验证一下子查询以及WHERE行筛选条件是不是准确的。

# 将名字为李三的客户，所有订单给备注"国家栋梁,加急配送"
USE sql_store;
UPDATE orders
SET
    comments = '国家栋梁请尽快配送'
WHERE
    customer_id IN (
                   SELECT
                       customer_id
                   FROM
                       customers
                   WHERE
                         first_name = '三'
                     AND last_name = '李');
# 修改刘牛的订单信息
UPDATE orders
SET
    comments = '新用户'
WHERE
    customer_id = (
                  SELECT
                      customer_id
                  FROM
                      customers
                  WHERE
                        first_name = '牛'
                    AND last_name = '刘');
-- 将 orders 表里那些 分数>3k 的用户的订单 comments 改为 ‘gold customer’
USE sql_store;
UPDATE orders
SET
    comments = '黄金客户牛'
WHERE
    customer_id IN (
                   SELECT
                       customer_id
                   FROM
                       customers
                   WHERE
                       points > 3000);
/*
DELETE
*/
-- 删除行
USE sql_invoicing;
DELETE
FROM
    invoices
WHERE
    client_id = 3;
# 如果删除报错1451，说明有外键关联无法删除，可以将外键的删除行为改为CASCADE，
# 表示级联操作的意思（删除父表记录，自动删除子表关联记录）。
# 一般不建议使用。有些情况也可以使用，比如订单表和订单项表。

-- 以上没法直接删除，那就先手动删除其子表的内容。

DELETE
FROM
    payments
WHERE
    client_id = 3;

-- 查询测试
SELECT *
FROM
    invoices
WHERE
    client_id = 3;


# 恢复数据库
# 就是重新运行那个SQL文件以重置数据库
# 用Navicat就可以。