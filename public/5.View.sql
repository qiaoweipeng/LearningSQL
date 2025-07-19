/*
View 视图
也常用
*/
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