/*
Procedure 存储过程
    其实现在存储过程用的很少，因为后端开发都有很强大的ORM框架。（但是必须了解）

    概念：
    1. 什么是存储过程？
        储存过程是一个包含SQL代码块的数据库对象，我们调用储存过程来获取数据，其实和视图很像，但还是有很大的区别。

    2. 存储过程有啥用？
        2.1 假设你要开发软件，你的SQL语句写在哪里呢？
            如果将SQL和业务代码混在一起，会变得难以维护，所以应该将SQL代码和业务代码分开，这时使用存储过程就很合理。
            将SQL放在存储过程或者函数汇总，在业务代码汇总调用对应的存储过程就行。
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
/*
手动调用存储过程
*/
CALL get_clients();

/*
删除存储过程
    注意加上 IF EXISTS,这样不会报错，DROP VIEW 也一样。
    如果原本不存在该视图或者存储过程，直接使用DROP会报错。
*/
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
CREATE PROCEDURE get_clients_by_state(state char(2)) # state char(2) 表示需要传入的参数，以及参数类型，多个参数用','分隔
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
CREATE PROCEDURE get_clients_by_state(state char(2)) # state char(2) 表示需要传入的参数，以及参数类型，多个参数用','分隔
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
    #         if static = null，IFNULL函数则返回第二个参数的值，那就是c.tatie,c.tatic就是自己本身，最后c.state = c.state 结果为True
    #             那就执行对应的SELECT
    #         if static != null, 那 c.static = static传过来的值，根据值来执行SQL。
END $$
DELIMITER ;

CALL get_clients_by_state(NULL);
CALL get_clients_by_state('CA');



# 创建带"默认参数"的存储过程
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
