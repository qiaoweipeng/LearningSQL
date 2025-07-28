/*
Procedure 存储过程
    现在存储过程用的很少，因为后端开发都有很强大的ORM框架。（但是必须了解）

    概念：
    1. 什么是存储过程？
        储存过程是一个包含SQL代码块的数据库对象，我们调用储存过程来获取数据，其实和视图很像，但还是有很大的区别。

    2. 存储过程有啥用？
        2.1 假设你要开发软件，你的SQL语句写在哪里呢？
            如果将SQL和业务代码混在一起，会变得难以维护，所以应该将SQL代码和业务代码分开，这时使用存储过程就很合理。
            将SQL放在存储过程或者函数中，在业务代码中调用对应的存储过程就行。
        2.2存储过程还会对性能有优化
            大部分DBMS会对储存过程中的代码进行一些优化，因此有时储存过中的SQL代码执行起来会更快。
        2.3 存储过程和视图一样，能加强数据安全
            我们可以移除对所有原始表的访问权限，让各种增删改的操作都通过储存过程来完成，然后就可以决定谁可以执行何种储存过程，
            可以限制用户对数据的操作范围。例如，防止特定的用户删除数据。
    语法：
        1. 创建存储过程
            DELIMITER $$ # 临时使用$$作为分隔符，避免";"被误解析，你用$$或||都行，只是一个分隔符而已。
                CREATE PROCEDURE get_data() # 表示创建一个名为get_data()的存储过程，括号里面可以带参数
                    BEGIN # 存储过程主体代码的开始
                        主体代码;
                    END $$ # 主体代码的结束
            DELIMITER ; # 恢复默认分隔符

        # 有些GUI工具自带创建存储过程的按钮，也可以用来创建存储过程，只需要自己写主体代码。

        2. 调用存储过程
            call get_data()
            # 当然也可以在菜单栏找到对应的视图点击运行。

        2. 删除存储过程
            DROP PROCEDURE IF EXISTS get_data;

        3. 带参数的存储过程
            就是调用此存储过程需要传入参数，也可以设置默认参数。

        4. 参数验证：就是对传过来的参数进行验证，符合条件就执行SQL，不符合就报错。
            1. 储存过程除了可以查，也可以增删改，但修改数据前最好先进行参数验证以防止不合理的修改
            2. 主要利用 IF 条件语句和 SIGNAL SQLSTATE MESSAGE_TEXT 关键字
            3. 语法：在存储过程主体开头添加以下语句：
                    IF 错误参数条件表达式 THEN
                    SIGNAL SQLSTATE '错误类型'
                    [SET MESSAGE_TEXT = '关于错误的补充信息']（可选）
            4. 参数验证一般前后端验证，这里只是最后的防线。
            5. 错误类型查看网址：https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=codes-sqlstate-values-common-error
        5. 输出参数：
            没事别搞！除非真的需要！
        6. 变量
            变量分两种:
            1. 用户或会话变量： SET @变量名 = 值
            2. 本地变量： DECLARE 变量名 数据类型 [DEFAULT 默认值]
            用户或会话变量（User or session variable）：
                上节课讲过，用 SET 语句并在变量名前加 @ 前缀来定义，将在整个用户会话期间存续，在会话结束断开MySQL
                连接时才被清空，这种变量主要在调用带输出变量的储存过程时使用，用来传入储存过程作为输出参数来获取结果
                值。
            本地变量（Local variable）
                在储存过程或函数中通过 DECLARE 声明并使用，在函数或储存过程执行结束时就被清空，常用来执行储存过程
                （或函数）中的计算
*/

/*
创建存储过程
*/
USE sql_invoicing;
DELIMITER $$
CREATE PROCEDURE get_clients()
BEGIN
    SELECT *
    FROM
        clients;
END $$
DELIMITER ;

# 调用存储过程
CALL get_clients();

# 删除存储过程
DROP PROCEDURE IF EXISTS get_clients;

#创建存储过程
USE sql_invoicing;
DELIMITER $$
CREATE PROCEDURE get_balance()
BEGIN
    SELECT
        c.name,
        i.invoice_id,
        i.payment_total,
        i.invoice_total,
        SUM(invoice_total - payment_total) AS balance
    FROM
        clients c
            JOIN invoices i USING (client_id)
    GROUP BY
        c.name, i.invoice_id;
END $$
DELIMITER ;

CALL get_balance();

# 创建带"参数"的存储过程
# 根据州获取用户信息
USE sql_invoicing;
DELIMITER $$
# state char(2) 表示需要传入的参数，以及参数类型，多个参数用','分隔
CREATE PROCEDURE get_clients_by_state(state char(2))
BEGIN
    SELECT * FROM clients c WHERE c.state = state; # 根据输入参数筛选
END $$
DELIMITER ;

CALL get_clients_by_state('CA');
# CALL get_clients_by_state(); # 报错，因为参数必填


# 根据用户id获取发票信息
USE sql_invoicing;
DELIMITER $$
CREATE PROCEDURE get_invoices_by_clients(client_id int)
BEGIN
    SELECT * FROM invoices i WHERE i.client_id = client_id; # 根据输入参数筛选
END $$
DELIMITER ;

CALL get_invoices_by_clients(1);

# 创建带"默认参数"的存储过程
# 根据州获取用户信息,如果用户输入为NULL，那就返回所有用户信息
USE sql_invoicing;
DELIMITER $$
# state char(2) 表示需要传入的参数，以及参数类型，多个参数用','分隔
CREATE PROCEDURE get_clients_by_state(state char(4))
BEGIN
    #     IF state IS NULL
    #         THEN
    #             SELECT * FROM clients;
    #         ELSE
    #             SELECT * FROM clients c WHERE c.state = state; # 根据输入参数筛选
    #         END IF;

    #     以上主体代码可以简化为

    SELECT * FROM clients c WHERE c.state = IFNULL(state, c.state);
    # c.state = IFNULL(state, c.state)含义：
    #         if static = null，IFNULL函数则返回第二个参数的值，那就是c.tatie,c.tatic就是自己本身，
    #           最后c.state = c.state 结果为True,那就执行对应的SELECT
    #         if static != null, 那 c.static = static传过来的值，根据值来执行SQL。
END $$
DELIMITER ;

CALL get_clients_by_state(NULL);
CALL get_clients_by_state('CA');

# 根据用户id以及用户的支付方式，查询支付记录信息。
#     如果id和支付方式为NULL，则返回所有用户以及所有的支付记录。
USE sql_invoicing;
DELIMITER $$
CREATE PROCEDURE get_payments(
    client_id int,
    payment_method_id tinyint
)
BEGIN
    SELECT *
    FROM
        payments p
    WHERE
          p.client_id = IFNULL(client_id, p.client_id)
      AND p.payment_method = IFNULL(payment_method_id, p.payment_method);
END $$
DELIMITER ;

CALL get_payments(1, 1);
CALL get_payments(5, NULL);
CALL get_payments(NULL, 2);
CALL get_payments(NULL, NULL);

# 参数验证：就是对传过来的参数进行验证，复合条件就执行SQL，不符合就报错。
# 创建一个修改invoice的存储过程。payment_amount参数不能为负数！
DROP PROCEDURE IF EXISTS make_payment;
DELIMITER $$
CREATE PROCEDURE `make_payment`(
    invoice_id INT,
    payment_amount DECIMAL(9, 2),
    payment_date DATE
)
BEGIN
    # 添加参数验证
    IF payment_amount <= 0
        THEN
            SIGNAL SQLSTATE '22003'
                SET MESSAGE_TEXT = '金额不符合条件！';
        END IF;
    UPDATE invoices i
    SET
        i.payment_total = payment_amount,
        i.payment_date  = payment_date
    WHERE
        i.invoice_id = invoice_id;
END$$
DELIMITER ;

CALL make_payment(2, 1000, '2015-09-09');
# -100肯定不行
CALL make_payment(2, -100, '2015-09-09');

# 输出参数
# 这个procedure是没有带输出参数的，先演示没有带输出参数的。
DELIMITER $$
CREATE PROCEDURE `get_unpaid_invoices_for_client`(
    client_id INT
)
BEGIN
    SELECT
        COUNT(*),
        SUM(invoice_total)
    FROM
        invoices i
    WHERE
          i.client_id = client_id
      AND payment_total = 0;
END$$
DELIMITER ;
CALL get_unpaid_invoices_for_client(5);

# 这个procedure是带输出参数的。和上面的对比一下
DELIMITER $$
CREATE PROCEDURE `get_unpaid_invoices_for_client`(
    client_id INT,
    OUT invoice_count INT,
    OUT invoice_total DECIMAL(9, 2)
    -- 默认是输入参数，输出参数要加OUT前缀
)
BEGIN
    SELECT
        COUNT(*),
        SUM(invoice_total)

    INTO invoice_count, invoice_total
    -- SELECT后跟上INTO语句将SELECT选出的值传入输出参数（输出变量）中
    FROM
        invoices i
    WHERE
          i.client_id = client_id
      AND payment_total = 0;
END$$
DELIMITER ;
# 调用存储过程
SET @invoice_count = 0;
SET @invoice_total = 0;
CALL get_unpaid_invoices_for_client(5, @invoice_count, @invoice_total);
SELECT @invoice_count, @invoice_total;

# 变量
# 创造一个 get_risk_factor 储存过程，
# 使用公式 risk_factor = invoices_total / invoices_count * 5
DELIMITER $$
CREATE PROCEDURE `get_risk_factor`()
BEGIN
    -- 声明三个本地变量，可设默认值
    DECLARE risk_factor DECIMAL(9, 2) DEFAULT 0;
    DECLARE invoices_total DECIMAL(9, 2);
    DECLARE invoices_count INT;
    -- 用SELECT得到需要的值并用INTO传入invoices_total和invoices_count
    SELECT
        SUM(invoice_total),
        COUNT(*)
    INTO invoices_total, invoices_count
    FROM
        invoices;
    -- 【用SET语句给risk_factor计算赋值】
    SET risk_factor = invoices_total / invoices_count * 5;
    -- 【SELECT展示】最终结果risk_factor
    SELECT risk_factor;
END$$
DELIMITER ;


# 自定义函数
/*
    因为自定义函数和存储过程很相似，所以就和存储过程放在一起学习！
    函数和储存过程的作用非常相似，唯一区别是函数只能返回单一值而不能返回多行多列的结果集，
        当你只需要返回一个值时就可以创建函数。
    创建函数的语法和创建储存过程的语法极其相似，区别只在两点：
        1. 参数设置和 body 主体之间，有一段确定返回值类型以及函数属性的语句段
        2. 最后是返回（RETURN）值而不是查询（SELECT）值
    函数属性的说明：
        1. DETERMINISTIC:函数对相同地输入永远返回相同的结果。比如：计算折扣价，有固定地计算逻辑
        2. READS SQL DATA:函数会查询数据库（如执行 SELECT），但不会修改数据。
        3. MODIFIES SQL DATA:函数会修改数据库数据（如执行 INSERT/UPDATE/DELETE）。避免在函数中使用（用存储过程替代）
    */
# 定义函数
USE sql_invoicing;
DELIMITER $$
CREATE FUNCTION `get_risk_factor_for_client`(
    client_id INT
)
    RETURNS INTEGER
    READS SQL DATA
BEGIN
    DECLARE risk_factor DECIMAL(9, 2) DEFAULT 0;
    DECLARE invoices_total DECIMAL(9, 2);
    DECLARE invoices_count INT;
    SELECT
        SUM(invoice_total),
        COUNT(*)
    INTO invoices_total, invoices_count
    FROM
        invoices i
    WHERE
        i.client_id = client_id;
    -- 注意不再是整体risk_factor而是特定顾客的risk_factor
    SET risk_factor = invoices_total / invoices_count * 5;
    RETURN IFNULL
           (risk_factor, 0);

END$$
DELIMITER ;
# 使用函数
SELECT
    client_id,
    name,
    get_risk_factor_for_client(client_id) AS risk_factor
-- 其实是逐行调用
FROM
    clients;
# 删除函数
DROP FUNCTION IF EXISTS get_risk_factor_for_client;

