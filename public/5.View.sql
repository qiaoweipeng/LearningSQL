/*
Views 视图

三大优点：
    简化查询、增加抽象层和减少变化的影响、数据安全性

具体来讲：
1. （首要优点）简化查询 simplify queries

2. 增加抽象层，减少变化的影响 Reduce the impact of changes：视图给表增加了一个抽象层（模块化），这样
如果数据库设计改变了（如一个字段从一个表转移到了另一个表），只需修改视图的查询语句使其能保持原有查
询结果即可，不需要修改使用这个视图的那几十个查询。相反，如果没有视图这一层的话，所有查询将直接使用
指向原表的原始查询语句，这样一旦更改原表设计，就要相应地更改所有的这些查询。

3. 限制对原数据的访问权限 Restrict access to the data：在视图中可以对原表的行和列进行筛选，这样如果你禁
止了对原始表的访问权限，用户只能通过视图来修改数据，他们就无法修改视图中未返回的那些字段和记录。但
需注意，这并不像听上去这么简单，需要良好的规划，否则最后可能搞得一团乱。

了解这些优点，但不要盲目将他们运用在所有的情形中。
*/

# 1. 创建View

# demo1：创建sales_by_client视图
USE sql_invoicing;
# 创建View
CREATE VIEW sales_by_client AS
SELECT
    client_id,
    name,
    SUM(invoice_total) AS total_sales
FROM
    clients c
        JOIN invoices i USING (client_id)
GROUP BY
    client_id, name;
# 若要删掉该视图用 DROP VIEW sales_by_client 或 菜单栏找到对应的视图右键删除
DROP VIEW sales_by_client;
# 创建视图后可就当作sql_invoicing库下一张表一样进行各种操作
# 使用View
USE sql_invoicing;
SELECT
    s.name,
    s.total_sales,
    phone
FROM
    sales_by_client s
        JOIN clients c USING (client_id)
WHERE
    s.total_sales > 500;


# demo2：创建一个客户差额表视图，可以看到客户的id，名字以及差额（发票总额-支付总额）
USE sql_invoicing;
# 创建视图
CREATE VIEW client_blance AS
SELECT
    client_id,
    c.name,
    SUM(invoice_total - payment_total) AS balanse
FROM
    clients c
        JOIN invoices i USING (client_id)
GROUP BY
    client_id;

# 使用视图
SELECT *
FROM
    client_blance;

# 2. 更新或删除View

/*
    1. 修改视图可以先 DROP 再 CREATE，但最好是用 CREATE OR REPLACE
    2. 视图的SQL可以在菜单栏对应视图右键，下查看和修改，最好还是保存为sql文件Git管理。
*/
# demo：想在上一节的顾客差额视图的查询语句最后加上按差额降序排列

# 方法1：先drop再create
USE sql_invoicing;
DROP VIEW client_blance;
# 若不存在这个视图，用DROP会报错，最好加上 IF EXISTS，后面会讲

CREATE VIEW client_blance AS
SELECT
    client_id,
    c.name,
    SUM(invoice_total - payment_total) AS balanse
FROM
    clients c
        JOIN invoices i USING (client_id)
GROUP BY
    client_id
ORDER BY
    balanse DESC;
# 方法2：菜单栏中找到对应的View修改，直接修改SQL即可。