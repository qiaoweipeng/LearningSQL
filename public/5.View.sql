/*
Views 视图

   概念：

    视图就是为了简化查询，你可以理解为一张虚拟表，在原table基础在再次抽象，将一些复杂的查询写在视图中，只需要使用视图即可。

    视图的优点：
        1. 简化查询
        2. 如果表结构发生变动或字段发生变动，不需要修改所有的SQL语句。只需要修改视图对应的SQL即可。
        3. 限制对原始表的数据访问，只能操作视图相应的数据，当然想要应用好，也很不容易。
        4. 虽然视图有这么多优点，但是也不要随意乱用。

    语法：
        1. 创建视图
            CREATE VIEW view_name AS
                SELECT...FROM....WHERE...;
        2. 删除视图
            DROP VIEW view_name;
        3. 使用视图？把视图当一张表用就行
            SELECT * FROM view_name...;
        4. 修改视图？
            1. (推荐)把视图SQL脚本使用git管理。修改视图有两种写法：
                    a. 先DROP 在 CREATE。（不推荐，因为每次修改前都要先DROP）
                    b. 使用CREATE OR REPLACE。（推荐，不需要DROP）
            2.（不推荐）如果你的原始视图SQL脚本找不到，那就去菜单栏对应的数据库找到需要修改的视图，右键，修改。
        5. 可更新视图
            如果视图中没使用过GROUP BY、聚合函数、HAVING、DISTINCT、UNION，则为可更新视图。
            可更新视图不但可以用在SELECT中，还可以用在INSERT、DELETE、UPDATE语句中。
        6. WITH CHECK OPTION
            在创建视图末尾加上WITH CHECK OPTION ，视图不会因为修改某些字段的值而导致某行数据消失。
            如：在创建视图时有个限制条件name > 30,你使用UPDATE将name修改为20，当前数据肯定会从视图消失。但是如果
            在创建视图末尾加上WITH CHECK OPTION，你执行该语句，会报错，表示不允许修改。

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