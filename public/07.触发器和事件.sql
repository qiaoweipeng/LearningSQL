/*
Triggers and Events 触发器和事件
    什么是触发器和事件？
        触发器：触发器就是在增删改前后自动执行的一段SQL，通常我们使用触发器来保证数据的一致性。
        事件：事件是一段根据计划执行的代码，可以执行一次，或者按某种规律执行。比如：每天早上10点或每月一次
            通过事件我们可以设置auto database维护任务。比如：删除过期数据、将数据从一张表复制到存档表或者汇总数据
        生成报告，所以很有用。

    Trigger （触发器）
        1.创建触发器
            和创建储存过程类似，要暂时更改分隔符，用CREATE关键字，用BEGIN和END包裹的主体
        2.查看触发器
            SHOW TRIGGERS;
        3.删除触发器
            DROP TRIGGER IS EXISTS trigger_name;
        4.使用触发器进行审核
        发现 payments_audit 表里果然多了两条记录以记录这两次增和删的操作
        注意
        实际运用中不会为数据库中的每张表建立一个审核表，相反，会有一个整体架构，通过一个总审核表来记录，这在
        之后设计数据库中会讲到。

    Event（事件）
        1.查看事件

        2.删除事件

        3.修改事件
*/

# 创建触发器
/*在 sql_invoicing 库中，发票信息表中，一条发票记录可以对应支付记录表中的多次支付记录，
发票信息表中的已支付总额应该等于这张发票所有付款记录之和，为了保持数据一致性，可以通过
触发器，只要有新增支付记录，发票表中相应发票的已支付总额（payement_total）也要自动增加相应数额*/
USE sql_invoicing;
DELIMITER $$
CREATE TRIGGER payments_after_insert # 命名习惯：做什么_之前/之后_增/删/改
    AFTER INSERT
    ON payments -- 触发条件语句
    FOR EACH ROW -- 触发频率语句
BEGIN
    UPDATE invoices
    SET
        payment_total = payment_total + NEW.amount
    WHERE
        invoice_id = NEW.invoice_id;
    /*INSERT INTO payments_audit
    VALUES (NEW.client_id, NEW.date, NEW.amount, 'insert', NOW());*/
END$$
DELIMITER ;
# 几个关键点：
# 1. 命名习惯（三要素）：触发表_before/after(表示SQL语句执行之前或之后触发)_触发的SQL语句类型
# 2. 触发条件语句：BEFORE/AFTER INSERT/UPDATE/DELETE ON 触发表
# 3. 触发频率语句：这里 FOR EACH ROW 表明每一个受影响的行都会启动一次触发器。其它有的DBMS还支持表
# 级别的触发器，即不管插入一行还是五行都只启动一次触发器，到Mosh录制为止MySQL还不支持这样的功能
# 4. 主体：主体里可以对各种表的数据进行修改以保持数据一致性，但注意唯一不能修改的表是触发表，否则会引发
# 无限循环（“触发器自燃”），主体中最关键的是使用 NEW/OLD 关键字来指代受影响的新/旧行（若INSERT用
# NEW，若DELETE用OLD，若UPDATE似乎理论上两个都可以用，但应该业主要用NEW）并可跟 '点+字段' 地
# 方式来引用这些行的相应属性

# 测试payments_after_insert触发器
# 往payments里新增付款记录，发现invoices表对应发票的付款总额确实相应更新
INSERT INTO
    payments
VALUES
    (DEFAULT, 5, 3, '2019-01-01', 10, 1);

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
    /* INSERT INTO payments_audit
     VALUES (OLD.client_id, OLD.date, OLD.amount, 'delete', NOW());*/
END $$

DELIMITER ;
# 测试payments_after_delete
DELETE
FROM
    payments
WHERE
    payment_id = 10;

# 查看触发器
SHOW TRIGGERS;
# 如果之前创建时遵行了三要素命名习惯，这里也可以用 LIKE 关键字来筛选特定表的触发器
SHOW TRIGGERS LIKE '%delete';
SHOW TRIGGERS LIKE 'payments%';

# 删除触发器
DROP TRIGGER IF EXISTS payments_after_delete;
DROP TRIGGER IF EXISTS payments_after_insert;

# 首先，需要打开MySQL事件调度器（event_scheduler），这是一个时刻寻找需要执行的事件的后台程序
# 查看MySQL所有系统变量：
SHOW VARIABLES;
SHOW VARIABLES LIKE 'event%';
-- 使用 LIKE 操作符查找以event开头的系统变量
-- 【通常为了节约系统资源而默认关闭】

# 用SET语句开启或关闭,不想用事件时可关闭以节省资源，这样就不会有一个不停寻找需要执行的事件的后台程序
SET GLOBAL event_scheduler = ON;
# ON/OFF
# 创建事件
# 创建这样一个 yearly_delete_stale_audit_row 事件，每年删除过期的（超过一年的）日志记录
DELIMITER $$
CREATE
    EVENT yearly_delete_stale_audit_row
    -- stale adj. 陈腐的；不新鲜的
    -- 设定事件的执行计划：
    ON SCHEDULE
        EVERY 1 YEAR STARTS '2019-01-01' ENDS '2029-01-01'
    -- 主体部分：（注意 DO 关键字）
    DO BEGIN
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