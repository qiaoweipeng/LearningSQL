-- 1. INSERT
-- 	1.1 插入单行
-- 在 顾客表中插入一条新顾客信息
USE sql_store;
SELECT *
FROM customers;

-- 方式1：不指明列名（注意连括号也省了），但插入的值必须按所有字段的顺序完整插入
INSERT INTO customers
VALUES (default, '露露', '王', '2003-07-15', DEFAULT, '北京中南海', '北京', '北京', 800);

-- 方式2：指明列名，可跳过取默认值的列且可更改顺序。（推荐使用！）
INSERT INTO customers (first_name, last_name, address, city, state)
VALUES ('大米', '刘', '西安市北大街55号', '西安市', '陕西');

-- 1.2 插入多行
USE sql_store;
INSERT INTO shippers (name)
VALUES ('中通'),
			 ('极兔');

-- 插入多条产品信息
USE sql_store;

INSERT INTO products
VALUES (DEFAULT, '耳机1', 100, 30),
			 (DEFAULT, '耳机2', 100, 20),
			 (DEFAULT, '耳机3', 100, 60);

-- 或者

INSERT INTO products (name, quantity_in_stock, unit_price)
VALUES ('耳机1', 100, 30),
			 ('耳机2', 100, 20),
			 ('耳机3', 100, 60);
-- 注意：
-- 对于AI (Auto Incremental 自动递增) 的id字段，MySQL会记住删除的/用过的id，并在此基础上递增

-- 1.3 插入分级行
-- 新增一个订单（order），里面包含两个订单项目/两种商品（order_items），请同时更新订单表和订单项目表
USE sql_store;
INSERT INTO orders (customer_id, order_date, status)
VALUES (1, '2025-03-05', 1);
-- 可以先试一下用 SELECT last_insert_id() 看能否成功获取到的最新的order_id
INSERT INTO order_items -- 全是必须字段，就不用指定了。
VALUES (LAST_INSERT_ID(), 1, 2, 2.5),
			 (LAST_INSERT_ID(), 2, 10, 30);


-- 1.4 创建表的副本
-- 	法1. 删除重建：DROP TABLE 要删的表名、CREATE TABLE 新表名 AS 子查询
-- 	法2. 清空重填：TRUCATE '要清空的表名'、INSERT INTO 表名 子查询

-- 	运用 CREAT TABLE 新表名 AS 子查询，快速创建orders的副本表‘orders_archived’
USE sql_store;

CREATE TABLE orders_archived AS
SELECT * -- 子查询
FROM orders;

-- 删除orders_archived表
DROP TABLE orders_archived;

-- 将符合条件的数据放到新表里面
-- 方式1：使用drop table 和 create table
USE sql_store;
DROP TABLE orders_archived; -- 删除表
CREATE TABLE orders_archived AS -- 创建表并添加内容
SELECT *
FROM orders
WHERE order_date < '2019-01-01';

-- 方式2:使用truncate 和 insert into
TRUNCATE TABLE orders_archived; -- 清空表
INSERT INTO orders_archived -- 添加符合条件的信息到新表。（不用指明列名，会直接用子查询里饿列名）
SELECT * -- 子查询，代替原先插入语句中VALUES(....,....)...的部分
FROM orders
WHERE order_date < '2019-01-10';

-- 查询测试
SELECT *
FROM orders_archived;

-- 创建一个存档发票表，只包含有过支付记录的发票并将顾客id换成顾客名字
-- 思路：
-- 	1. 先创建子查询，确定新表的内容。
-- 		a. 合并发票和用户表
-- 		b. 筛选支付记录不为空的信息
-- 		c. 筛选需要的列（重命名）
-- 	2. 第一步得到的查询内容，先运行看结果在将子查询的内容存到新表中
USE sql_invoicing;

DROP TABLE invoices_archived;

CREATE TABLE invoices_archived AS
SELECT i.invoice_id 发票编号, c.name 用户名, i.payment_date
FROM invoices i
			 JOIN clients c
						USING (client_id)
WHERE i.payment_date IS NOT NULL;

-- 查询测试
SELECT *
FROM invoices_archived;
-- 或者 i.payment_date > 0

-- 2. UPDATE
-- 	语法：
-- UPDATE 表
-- SET 要修改的字段 = 具体值 / NULL / DEFAULT / 列间数学表达式 （修改多个字段用逗号分隔）
-- WHERE 行筛选
-- 	2.1 更新单行
USE sql_invoicing;
UPDATE invoices
SET payment_total = 100,
		payment_date  = due_date
WHERE invoice_id = 3;

-- payment_total的值还可以这样写：
-- 		100 -- 数值为100
-- 		0 -- 数值为0
-- 		default -- 默认值
-- 		null -- 空
-- 		0.5 * invoice_total -- 表达式

-- payment_date的值还可这样写：
-- 	default --默认值
-- 	null --空
-- 	due_date -- 其他值

-- 查询测试
SELECT *
FROM invoices
WHERE invoice_id = 3;
-- 	2.2 更新多行
-- 语法和上面一样，就是让 WHERE…… 的条件包含更多记录，就会同时更改多条记录了

USE sql_invoicing;
UPDATE invoices
SET payment_total = 100,
		payment_date  = due_date
WHERE invoice_id 3;
-- 该客户的发票记录不止一条，将同时更改。
-- WHERE invoice_id IN (3,4); -- 满足这个条件的客户信息都会被修改
-- 	甚至可以直接忽略where语句会直接更改整个表的全部记录

-- 给所有非90后顾客增加50点积分
USE sql_store;
UPDATE customers
SET points = points + 50
WHERE birth_date NOT BETWEEN '1990-01-01' AND '2000-01-01';

-- 查询测试
SELECT *
FROM customers
WHERE birth_date NOT BETWEEN '1990-01-01' AND '2000-01-01';
-- 	2.3 UPDATE 中使用子查询
USE sql_invoicing;
UPDATE invoices
SET payment_total = 888,
		payment_date  = due_date
-- 满足单个条件
WHERE client_id = (SELECT client_id FROM clients WHERE name = 'Yadel');
-- 放入括号，确保先执行

-- 若子查询返回多个数据（一列多条数据）时就不能用等号而要用 IN 了：
USE sql_invoicing;
UPDATE invoices
SET payment_total = 999,
		payment_date  = due_date
-- 满足多个条件
WHERE client_id IN (SELECT clients.client_id FROM clients WHERE state IN ('CA', 'NY'));
-- 查询测试
SELECT *
FROM invoices;

--  最佳实践
-- Update 前，最好先验证一下子查询以及WHERE行筛选条件是不是准确的，筛选出的是不是我们的修改目标，
-- 确保不会改错记录，再套入UPDATE SET语句更新，如上面那个就可以先验证子查询：
SELECT client_id
FROM clients
WHERE state IN ('ca', 'ny');
-- 以及验证WHERE行筛选条件（即先不UPDATE，先SELECT，改之前，先看一看要改的目标选对了没）
SELECT *
FROM invoices
WHERE client_id IN (SELECT clients.client_id FROM clients WHERE state IN ('ca', 'ny'));
-- 确保WHERE行筛选条件准确准确无误后，再放到修改语句后执行修改：
UPDATE invoices
SET payment_total = 888,
		payment_date  = due_date
WHERE client_id IN (SELECT client_id
										FROM clients
										WHERE state IN ('va', 'ny'))
-- 有子查询的 Update 主要验证 Where 条件中的 子查询部分正不正确，而没有子查询的 Update 则应该将 update
-- 换成 select 先验证一下整个 Where 筛选条件正不正确。

-- 将 orders 表里那些 分数>3k 的用户的订单 comments 改为 ‘gold customer’
--  思路：
--  	先去orders表中使用子查询，查询customers表中customer_id > 3000的用户，确定没有问题，将子查询代入undate语句
USE sql_store;
UPDATE orders
SET comments = '黄金客户'
WHERE customer_id IN (SELECT customer_id
											FROM customers
											WHERE points > 3000);
-- 3. DELETE
-- 删除行
USE sql_invoicing;
DELETE
FROM invoices
WHERE client_id = 3;
-- 如果删除报错1451，说明有外键关联无法删除，可以将外键的删除行为改为CASCADE，表示级联操作的意思（删除父表记录，自动删除子表关联记录）。一般不建议使用。有些情况也可以使用，比如订单表和订单项表。

-- 以上没法直接删除，那就先手动删除其子表的内容。

DELETE
FROM payments
WHERE client_id = 3;

-- 查询测试
SELECT *
FROM invoices WHERE client_id = 3;


-- 4. 恢复数据库

--  就是重新运行那个SQL文件以重置数据库