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
            另外，INSERT还要满足附加条件：视图必须包含底层原表的所有必须字段。
        6. WITH CHECK OPTION
            在创建视图末尾加上WITH CHECK OPTION ，视图不会因为修改某些字段的值而导致某行数据消失。
            如：在创建视图时有个限制条件name > 30,你使用UPDATE将name修改为20，当前数据肯定会从视图消失。但是如果
            在创建视图末尾加上WITH CHECK OPTION，你执行该语句，会报错，表示不允许修改。
*/

# 创建视图
USE sql_invoicing;
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

# 使用视图
SELECT *
FROM
    sales_by_client;

SELECT
    s.name,
    s.total_sales,
    c.phone
FROM
    sales_by_client s
        JOIN clients c USING (client_id)
WHERE
    s.total_sales > 900;


# 删除视图
DROP VIEW IF EXISTS sales_by_client;

# 创建视图
# 创建一个客户差额表视图，可以看到客户的id，名字以及差额（发票总额-支付总额）
USE sql_invoicing;

DROP VIEW client_balance;

CREATE VIEW client_balance AS
SELECT
    client_id,
    c.name,
    SUM(invoice_total - payment_total) AS balance
FROM
    clients c
        JOIN invoices i USING (client_id)
GROUP BY
    client_id;

SELECT *
FROM
    client_balance;


# 修改视图

# 将client_balance视图修改为 按差额 降序排列
# 方法1. 先 DROP 再 CREATE。意思就是先删除原有视图，然后创建新视图。
# 方法2. CREATE OR REPLACE。意思就是先看你有视图吗，如果有就修改，没有就创建。
USE sql_invoicing;
# 方法1：
DROP VIEW IF EXISTS client_balance;
CREATE VIEW client_balance AS
SELECT
    client_id,
    c.name,
    SUM(invoice_total - payment_total) AS balance
FROM
    clients c
        JOIN invoices i USING (client_id)
GROUP BY
    client_id
ORDER BY
    balance DESC;
# 方法2：
CREATE OR REPLACE VIEW client_balance AS
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

# 可更新视图
# 创建视图
USE sql_invoicing;
CREATE OR REPLACE VIEW invoices_with_balance AS
SELECT
    invoice_id,
    number,
    client_id,
    invoice_total,
    payment_total,
    invoice_date,
    invoice_total - payment_total AS balance,
    due_date,
    payment_date
FROM
    invoices
WHERE
    (invoice_total - payment_total) > 0
WITH CHECK OPTION;

SELECT *
FROM
    invoices_with_balance;
# invoices_with_balance视图满足条件，是可更新视图，可以增删改！

# 1. DELETE
# 删掉id为1的发票记录
DELETE
FROM
    invoices_with_balance
WHERE
    invoice_id = 1;
# 2. UPDATE
# 将2号发票记录的期限延后两天
UPDATE invoices_with_balance
SET
    due_date = DATE_ADD(due_date, INTERVAL 2 DAY)
WHERE
    invoice_id = 2;
# INSERT
# 在视图中用INSERT新增记录，其底层必须包含原始表的所有必须字段！
# 例如，若这个invoices_with_balance视图里没有invoice_date字段（invoices中的必须字段），那就无法通过该
# 视图向invoices表新增记录，因为invoices表不会接受必须字段invoice_date为空的记录

# 通过视图新增数据比较复杂切不可靠，一般不会这么操作
# 这里就不演示了，知道可以这么做就行！

/*
WITH CHECK OPTION

  创建invoices_with_balance视图时，末尾没有添加WITH CHECK OPTION,以下SQL语句可以执行成功，
并且对应的数据会从视图消失。因为符合视图中的筛选条件。
  如果末尾添加WITH CHECK OPTION，以下SQL语句执行会报错，不允许修改。
*/

UPDATE invoices_with_balance
SET
#     这里通过修改价格来达到不满足该视图条件，不满足，正常应该是不会在该视图显示，
#     但是使用WITH CHECK OPTION，既然数据会从视图消失，那干脆就不让你改了。
    invoice_total = payment_total
WHERE
    invoice_id = 3;
