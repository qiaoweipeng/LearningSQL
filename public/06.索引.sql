/*
Index 索引

        索引在数据库的使用中及其重要，通过索引可以提高查询性能。（必须掌握）
    概念：

    1. 创建索引
        CREATE INDEX idx_name ON table_name (column_name);
    2. 查看索引
        SHOW INDEXES IN table_name;
    3. 前缀索引
        CREATE INDEX idx_name ON table_name (column(5));
    4. 全文索引
        CREATE FULLTEXT INDEX idx_name ON table_name (column_name);
    5. 组合索引
        CREATE INDEX idx_a_b ON customers (a, b);
    6. 组合索引的列数据
        需要重新添加索引
    7. 索引无效时
        就是要重新添加索引
    8. 使用索引排序

    9. 覆盖索引

    10. 维护索引

    11. 性能最佳实践（文档）
*/
USE sql_store;
EXPLAIN
SELECT
    customer_id
FROM
    customers
WHERE
    state = 'CA';

SELECT
    COUNT(*)
FROM
    customers;

# 创建索引
CREATE INDEX idx_state ON customers (state);

EXPLAIN
SELECT
    customer_id
FROM
    customers
WHERE
    points > 1000;

CREATE INDEX idx_points ON customers (points);
# 查看索引
SHOW INDEXES IN customers;

ANALYZE TABLE customers;

SHOW INDEXES IN orders;

# 前缀索引
CREATE INDEX idx_lastname ON customers (last_name(20));

SELECT
    COUNT(DISTINCT LEFT(last_name, 1)),
    COUNT(DISTINCT LEFT(last_name, 5)),
    COUNT(DISTINCT LEFT(last_name, 10))
FROM
    customers;
# 假设，用户想搜索包含 react 及 redux（两个前端的重要的 javascript 库）的文章，如果用LIKE操作符进行筛选：
USE sql_blog;
SELECT *
FROM
    posts
WHERE
     title LIKE '%react redux%'
  OR body LIKE '%react redux%';

# 全文索引
CREATE FULLTEXT INDEX idx_title_body ON posts (title, body);
# 利用全文索引，结合 MATCH 和 AGAINST 关键字 进行google式的模糊搜索:
SELECT *
FROM
    posts
WHERE
    MATCH(title, body) AGAINST('react redux');
# 还可以把 MATCH(title, body) AGAINST('react redux') 包含在选择语句里， 这样还能看到各结果的 relevance
# score 相关性得分（一个0到1的浮点数），可以看出结果是按相关行降序排列的
USE sql_blog;
SELECT *,
       MATCH(title, body) AGAINST('react redux')
FROM
    posts
WHERE
    MATCH(title, body) AGAINST('react redux');

# boolean模式
# 1. 尽量有 react，不要有 redux，必须有 form
SELECT *
FROM
    posts
WHERE
    MATCH(title, body) AGAINST('react -redux +form' IN BOOLEAN MODE);
# 2. 布林模式也可以实现精确搜索，就是将需要精确搜索的内容再用双引号包起来
SELECT *
FROM
    posts
WHERE
    MATCH(title, body) AGAINST('handling a form' IN BOOLEAN MODE);
# 全文索引十分强大，如果你要建一个搜索引擎可以使用它，特别是要搜索的是长文本时，如文章、博客、说明和描
# 述，否则，如果搜索比较短的字符串，比如名字或地址，就使用前置字符串

# 组合索引
# 查看customers表中的索引：
USE sql_store;
SHOW INDEXES IN customers;

EXPLAIN
SELECT
    customer_id
FROM
    customers
WHERE
      state = 'ca'
  AND points > 1000;

# 创建组合索引
CREATE INDEX idx_state_points ON customers (state, points);

# 删除索引
DROP INDEX idx_state ON customers;
DROP INDEX idx_points ON customers;
DROP INDEX idx_lastname ON customers;

# 索引无效时
# 查找在加州或积分大于1000的顾客id
# 注意之前查询的筛选条件都是与（AND），这里是或（OR）
USE sql_store;
EXPLAIN
SELECT *
FROM
    customers
WHERE
     state = 'ca'
  OR points > 1000;

CREATE INDEX idx_points ON customers (points);


EXPLAIN
SELECT
    customer_id
FROM
    customers
WHERE
    state = 'ca'
UNION
SELECT
    customer_id
FROM
    customers
WHERE
    points > 1000;


# 查询目前积分增加10分后超过2000分的顾客id
EXPLAIN
SELECT
    customer_id
FROM
    customers
WHERE
    points + 10 > 2010;

EXPLAIN
SELECT
    customer_id
FROM
    customers
WHERE
    points > 2010;

# 使用索引排序
SHOW STATUS;
SHOW STATUS LIKE 'last_query_cost';


EXPLAIN
SELECT
    customer_id
FROM
    customers
ORDER BY
    state;

EXPLAIN
SELECT
    customer_id
FROM
    customers
ORDER BY
    first_name;
SHOW STATUS LIKE 'last_query_cost';

