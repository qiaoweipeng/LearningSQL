/*
Triggers and Events 触发器和事件
    什么是触发器和事件？
        触发器：触发器就是在增删改前后自动执行的一段SQL，通常我们使用触发器来保证数据的一致性。
        事件：事件是一段根据计划执行的代码，可以执行一次，或者按某种规律执行。比如：每天早上10点或每月一次
            通过事件我们可以设置自动任务。比如：自动删除过期数据、将数据从一张表复制到存档表或者汇总数据
        生成报告，所以很有用。

    Trigger （触发器）
        1.创建触发器
            和创建储存过程类似，要暂时更改分隔符，用CREATE关键字，用BEGIN和END包裹的主体
        语法：
            CREATE TRIGGER trigger_name
                trigger_time trigger_event
                ON table_name FOR EACH ROW
                [trigger_order] -- MySQL 8.0+ 支持
                BEGIN
                    -- 触发器逻辑（SQL 语句）
                END;
        说明：
            trigger_name:命名规范 table-name_after/before_insert/delete/update
            trigger_time:[after/before],在事件执行前还是执行后触发。
            trigger_event：[insert/update/delete]插入时，修改时，还是删除时触发。
            table_name：关联的数据库表名
            FOR EACH ROW：必选项，表示行级触发器（每影响一行触发一次）
            触发器内部访问特殊值
                在触发器逻辑中可访问两类特殊记录：
            记录类型	    可用事件	             说明
            OLD	      UPDATE, DELETE	代表修改/删除前的数据
            NEW       INSERT, UPDATE	代表插入/修改后的数据


        2.查看触发器
            SHOW TRIGGERS;
        3.删除触发器
            DROP TRIGGER IS EXISTS trigger_name;
        4.使用触发器进行审核
            就是对数据库表的操作记录的保存。比如某张表谁在什么时候修改了什么，
                在用户操作完后，触发器触发会把记录保存在一张记录表中。
    Event（事件）
        1.创建事件
            和创建触发器类似。
        2.查看事件
            SHOW EVENTS;
        3.删除事件
            DROP EVENT IF EXISTS event_name;
        3.修改事件
            一般不用！
*/

/*在 sql_invoicing 库的发票信息表中，一条发票记录可以对应支付记录表中的多次支付记录，
发票信息表中的已支付总额应该等于这张发票所有付款记录之和，为了保持数据一致性，可以通过
触发器，只要有新增支付记录，发票表中相应发票的已支付总额（payment_total）也要自动增加相应数额*/
USE sql_invoicing;
# 创建触发器
DELIMITER $$
CREATE TRIGGER payments_after_insert
    AFTER INSERT -- 插入之后触发
    ON payments -- 关联的表
    FOR EACH ROW -- 每影响一行触发一次
BEGIN
    UPDATE invoices
    SET
        payment_total = payment_total + NEW.amount
    WHERE
        invoice_id = NEW.invoice_id;

    #     这个是使用触发器进行审核
    INSERT INTO payments_audit
    VALUES (NEW.client_id, NEW.date, NEW.amount, 'insert', NOW());
END$$
DELIMITER ;

# 测试payments_after_insert触发器
# 往payments里新增付款记录，发现invoices表对应发票的付款总额确实相应更新
INSERT INTO
    payments(client_id, invoice_id, date, amount, payment_method)
VALUES
    (5, 3, NOW(), 1000, 3);

# 创建触发器
# 创建一个与payments_after_insert触发器相反的触发器，每当有付款记录被删除时，自动减少发票表中对应发票的付款总额
DELIMITER $$
CREATE TRIGGER payments_after_delete
    AFTER DELETE
    ON payments
    FOR EACH ROW
BEGIN
    UPDATE invoices
    SET
        payment_total = payment_total - OLD.amount
    WHERE
        invoice_id = OLD.invoice_id;
    #     触发器审核
    INSERT INTO payments_audit
    VALUES (OLD.client_id, OLD.date, OLD.amount, 'delete', NOW());
END $$

DELIMITER ;
# 测试payments_after_delete
DELETE
FROM
    payments
WHERE
    payment_id = 13;

# 查看触发器
SHOW TRIGGERS;
SHOW TRIGGERS LIKE 'payments%';

# 删除触发器
DROP TRIGGER IF EXISTS payments_after_delete;
DROP TRIGGER IF EXISTS payments_after_insert;

# 使用触发器进行审核
#     我们在payments_after_delete和payments_after_insert触发器分别添加以下代码：
#       INSERT INTO payments_audit
#      VALUES (OLD.client_id, OLD.date, OLD.amount, 'delete/insert', NOW());
#     发现 payments_audit 表里果然多了两条记录以记录这两次增和删的操作

# 首先，需要打开MySQL事件调度器（event_scheduler），这是一个时刻寻找需要执行的事件的后台程序
# 查看MySQL所有系统变量：
SHOW VARIABLES;
SHOW VARIABLES LIKE 'event%';
# 用SET语句开启或关闭,不想用事件时可关闭以节省资源，这样就不会有一个不停寻找需要执行的事件的后台程序
SET GLOBAL event_scheduler = ON;
# ON/OFF

# 创建事件
# 创建这样一个 yearly_delete_stale_audit_row 事件，每年删除过期的（超过一年的）日志记录
DELIMITER $$
CREATE EVENT yearly_delete_stale_audit_row
    -- stale adj. 陈腐的；不新鲜的
    -- 设定事件的执行计划：
    ON SCHEDULE
        EVERY 1 YEAR STARTS '2019-01-01' ENDS '2029-01-01'
    -- 主体部分：（注意 DO 关键字）
    DO BEGIN
    #         清除一年前的操作记录
    DELETE
    FROM
        payments_audit
    WHERE
        action_date < NOW() - INTERVAL 1 YEAR;
END$$
DELIMITER ;

# 查看事件
SHOW EVENTS;
-- 可看到各个数据库的事件
SHOW EVENTS LIKE 'yearly%';
-- 【之前命名以时间间隔开头的好处：方便筛选】
# 删除事件
DROP EVENT IF EXISTS yearly_delete_stale_audit_row;