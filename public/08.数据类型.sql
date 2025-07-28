/*
    Data types 数据类型
    目标：
        常用的数据类型必须掌握，不常用的了解就行！
    数据类型有哪些？
        1. String  （部分常用）。如char、varchar
        2. Integer （部分常用）。如 int
        3. Fixpoint、Float point （部分常用）。如：decimal
        4. Boolean （可用可不用）
            因为Boolean类型语意清晰，如果数据库有建议使用。
        4. Enum、Set （不用）
        5. Date and Time （部分常用）。如：date、datetime
        6. Blob （不用）
            几乎不用，除非一些极其特殊场景。
        7. JSON （不常用）
            非核心模型可以用，核心数据还是使用关系模型。
            JSON虽然普及率高，但性能不如关系模型！
 */
/*
  String 字符串类型
    CHAR()                  定长字符串
    VARCHAR()               可变字符串
    LONGTEXT                最大存储4GB             很少用
    MEDIUMTEXT()            最大存储16MB            很少用
    TEXT                    最大存储64KB            很少用
    TINYTEXT                最大存储255Bytes        很少用

    1. CHAR和VARCHAR最常用的两个字符串类型
        1. CHAR() 固定长度的字符串。如州（'CA', 'NY', ……）就是 CHAR(2)
        2. VARCHAR() 可变字符串 。
        建议：
            一般可以用VARCHAR(50) 来记录用户名和密码这样的短文本以及用 VARCHAR(255) 来记录像地址这样较长一些的文本，
        保持这样的习惯能够简化数据库设计，不必每次都想每一列该用多长的VARCHARVARCHAR 最多能储存64KB, 也就是最多约 65k
        个字符（如果都是英文即每个字母只占1个字节的话），超出部分会被截断。
            字符串类型也可以用来储存邮编，电话号码这样的特殊的数字型文本数据，因为邮编、电话号码等不会用来做数学运算而且
        常常包含‘-’或括号等

    2.储存较大文本的两个类型
        1. MEDIUMTEXT 最大储存16MB（约16百万的英文字符），适合储存JSON对象，CS视图字符串，中短长度的书
        2. LONGTEXT 最大储存4GB，适合储存书籍和以年记的日志

    3.还有两个用的较少
        1. TINYTEXT 最大储存 255 Bytes
        2. TEXT 最大储存 64KB，最大储存长度和 VARCHAR 一样，但最好用 VARCHAR，
        因为 VARCHAR 可以使用索引，可以提高查询速度！

    了解：国际字符
        所有这些字符串类型都支持国际字符，其中：
            英文字符占1个字节
            欧洲和中东语言字符占2个字节
            像中日这样的亚洲语言的字符占3个字节
        所以，如果一列数据的类型为 CHAR(10)，MySQL会预留30字节给那一列的值
*/


/*
Integer表示整型（整数类型）
    前置知识：https://hwqlhqyloqd.feishu.cn/sync/YP6qdubSgsmKVXbL8I6cEJ1ZnkR

    整数类型         占用内存            范围
    TINYINT         1B             -128,127
    SMALLINT        2B             -32K,32k
    MEDIUMINT       3B             -8M,8M
    INT             4B             -2B,2B
    BIGINT          8B             -9Z,9Z

    INT 占 4 字节，最多表示 356^4 即约 4B 种数值，正负各一半，所以范围约为 [-2B,2B]

    属性:
        1. UNSIGNED (不带符号)
            这些整数可以选择不带符号，加上 UNSIGNED 则只储存非负数 如最常用的 UNSIGNED TINYINT，占用空间和 TINYINT
        一样也是一字节，但表示的数字范围不是 [-128,127] 而是 [0,255]，适合储存像年龄这样的数据，可以表示更大的正数范围
        也可以防止意外输入负数

        2. ZEROFILL (填零)
            整数类型的另一个属性是填零（Zerofill），主要用于当你需要给数字前面添加零让它们位数保持一致时 我们用括号表示
        显示位数，如 INT(4) 则显示为 0001，注意这只影响MySQL如何显示数字而不影响如何保存数字

    经验： 不用强行去记，谷歌 mysql integer types 即可查阅
    注意：如果试图存入超出范围的数字，MySQL会抛出异常 'The value is out of range'

    最佳实践:
            总是使用能满足你需求的最小整数类型，如储存人的年龄用 UNSIGNED TINYINT（1B，[0,255]） 就足够了，
        至少可见的未来内没人能活过255岁
            数据需要在磁盘和内存间传输，虽然不同类型间只有几个字节的差异，但数据量大了以后对空间和查询效率的影响就很大了，
        所以在数据量较大时，有意识地分配每一字节，保持数据最小化是很有必要的。
*/

/*
Fixedpoint、Floatpoint 适用于精度要求高的数值
    类型              解释          备注
    DECIMAL         定点数         精确数字使用
    FLOAT           浮点数         单精度
    DOUBLE          双精度浮点数    双精度
    1. Fixedpoint Types 定点数类型
        1. DECIMAL（P，S）两个参数分别指定最大的有效数字位数和小数点后小数位数（小数位数固定）
        如：DECIMAL(9，2）=>1234567.89总共最多9位，小数点后两位，整数部分最多7位

        2. DECIMAL还有几个别名：DEC/NUMERIC／FIXED，最好就使用DECIMAL以保持一致性，但其它几个也要眼熟，别人用了要认识
    2. Floatingpoint Types浮点数类型
        进行科学计算，要计算特别大或特别小的数时，就会用到浮点数类型，浮点数不是精确值而是近似值，这也正是它能表示更大范围数值的原因
        1. FLOAT浮点数类型，占用4B
        2. DOUBLE双精度浮点数，占用8B，显然能比前者储存更大（精确）的数值
    小结
        如果需要记录精确数字，比如【货币金额】，就是用DECIMAL类型
        如果要进行【科学计算】，要处理很大或很小的数据，而且精确值不重要的话，就用FLOAT或DOUBLE
*/

/*
 Boolean
    有时我们需要储存 是/否 型数据，如 “这个博客是否发布了？”，这里我们就要用到布尔值，来表示真或假
    MySQL里有个数据类型叫BOOL/ BOOLEAN
    注意：布尔值其实本质上就是 微整数 TINYINT 的另一种表现形式，TRUE/FALSE 实质上就是1/0，但个人觉得写成TRUE/FALSE表意更清楚
    UPDATE posts SET is_published = TRUE / FALSE 【或】 SET is_published = 1 / 0
*/

/*
Enum、Set 基本不用，了解就行。
enumeration n. 枚举

    有时我们希望某个字段从固定的一系列值中取值，我们就可以用到 ENUM() 和 SET() 类型，前者是取一个值，后者是取多个值

    1. ENUM()
        从固定一系列值中取一个值

     案例：例如，我们希望 sql_store.products（产品表）里多一个size（尺码）字段，取值为 small/medium/large 中的一个，可以打开产品表的设计模式，添加size列，数据类型设置为 ENUM('small','medium','large')，然后apply。
         对应SQL语句为：(修改表结构的语句下一章会讲)
             ALTER TABLE `sql_store`.`products`
             ADD COLUMN `size`ENUM('small','medium','large') NULL AFTER `unit_price`;
         则产品表会增加一个尺码列，可将其中的值设为 small/medium/large(大小写无所谓)，但若设为其他值会报错

    2. SET()
      SET 和 ENUM 类似，区别是，SET是从固定一系列值中取多个值而非一个值

    注意：
        讲解 ENUM 和 SET 只是为了眼熟，最好不要用这两个数据类型，问题很多：
        1. 修改可选的值（如想增加一个'extra large'）会重建整个表，耗费资源
        2. 想查询可选值的列表或者想用可选值当作一个下拉列表都会比较麻烦
        3. 难以在其它表里复用，其它地方要用只有重建相同的列，之后想修改就要多处修改，又会很麻烦
    最佳实践：
        像这种某个字段从固定的一系列值中取值的情况，不应该使用 ENUM 和 SET 而应该用这一系列的值另外建一个 “查询表” (lookup table)
        如：上面案例中，应该另外建一个size尺码表，就像sql_invoicing里为支付方式专门建了一个payment_methods表一样。
        这样就解决了上面的所有问题，既方便查询可选值的列表和作为下拉选项，也方便复用和更改
*/

/*
Date 表示日期和时间
    类型              解释          举例
    DATE            有日期没时间      2020-01-01
    TIME            有时间没日期      01:01:01
    DATETIME        包含日期和时间     2020-01-01 01:01:01
    TIMESTAMP       时间戳
    YEAR            年               2020

    DATETIME和TIMESTAMP的区别：
        TIMESTAMP 占4B，最晚记录2038年，被称为“2038年问题”
        DATETIME 占8B 所以，如果要储存超过2038年的日期时间，就要用DATETIME
*/

/*
    Blob 二进制大对象类型
        我们用Blob类型来储存大的二进制数据，包括PDF，图像，视频等等几乎所有的二进制的文件，具体来说，
    MySQL里共有4种Blob类型，它们的区别在于可储存的最大文件大小：
    类型          最大可存储
    TINYBOLB        255B
    BLOB            65KB
    MEDIUM BLOB     16MB
    LONG BLOB       4GB
    注意：
        通常应该将二进制文件存放在数据库之外，关系型数据库是设计来专门处理结构化关系型数据而非二进制文件的。
        如果将文件储存在数据库内，会有如下问题：
            1.数据库的大小将迅速增长
            2.备份会很慢
            3.性能问题
            4.需要额外的读写图像的代码
        所以，尽量别用数据库来存文件，除非这样做确实有必要，而且上面这些问题已经被考虑到了
    */

/*
JSON
前置知识：https://hwqlhqyloqd.feishu.cn/wiki/Z58WwgflqirN9HkUBLzc0Fg6nZb

JSON的案例，看代码
    JSON在前后端交互中，使用确实很多，但是在数据库中使用并不多！
    我们就来学习一下JSON类型在SQL中如何增删改查
*/
# 增：
# 先给商品表添加一个JSON类型的字段：
# 方式1：
# 用单引号包裹（注意不能是双引号），里面是 JSON 的标准格式：
#     双引号包裹键 key
#     值 value 可以是数、数组、甚至另一个用 {} 包裹的JSON对象
#     键值对间用逗号隔开
USE sql_store;
UPDATE products
SET
    properties = '
    {
      "dimensions": [
        1,
        2,
        3
      ],
      "weight": 10,
      "manufacturer": {
        "name": "sony"
      }
    }'
WHERE
    product_id = 1;
# 方式2：
#     也可以用 MySQL 里的一些针对 JSON 的内置函数来创建商品属性：
UPDATE products
SET
    properties = JSON_OBJECT(
            'weight', 10,
            'dimensions', JSON_ARRAY(1, 2, 3),
            'manufacturer', JSON_OBJECT('name', 'sony')
                 )
WHERE
    product_id = 1;

# 查：
#     方式1：
#     使用 JSON_EXTRACT() 函数，其中：
#         第1参数指明 JSON 对象
#         第2参数是用单引号包裹的路径，路径中 $ 表示当前对象，点操作符 . 表示对象的属性
SELECT
    product_id,
    JSON_EXTRACT(properties, '$.weight') AS weight
FROM
    products
WHERE
    product_id = 1;
#     方式2：
# 更简便的方法，使用列路径操作符 -> 和 ->>，后者可以去掉结果外层的引号
SELECT
    properties -> '$.weight' AS weight,
    properties -> '$.dimensions',
    properties -> '$.dimensions[0]',-- 索引为0的，json索引从0开始.
    properties -> '$.manufacturer',
    properties -> '$.manufacturer.name',
    properties ->> '$.manufacturer.name'
FROM
    products
WHERE
    product_id = 1;
# 筛选出制造商为sony的产品
SELECT
    product_id,
    properties ->> '$.manufacturer.name' AS manufacturer_name
FROM
    products
WHERE
    properties ->> '$.manufacturer.name' = 'sony';
# 改：
# 如果我们是要重新设置整个 JSON 对象就用前面 增 里讲到的 JSON_OBJECT() 函数，
# 但如果是想修改已有 JSON 对象里的部分属性，就要用 JSON_SET() 函数
USE sql_store;
UPDATE products
SET
    properties = JSON_SET(
            properties,
            '$.weight', 20, -- 【修改weight属性】
            '$.age', 10 -- 【增加age属性】
                 )
WHERE
    product_id = 1;
# 注意
# JSON_SET() 是获取已有 JSON 对象并修改部分属性然后返回修改后的 JSON 对象，
# 所以其第1参数是要修改的 JSON 对象，并且可以用 SET properties = JSON_SET(properties, ……)
#     的语法结构来实现对 properties 的修改
# 删：
# 可以用 JSON_REMOVE() 函数实现对已有 JSON 对象特性属性的删除，原理和 JSON_SET() 一样
UPDATE products
SET
    properties = JSON_REMOVE(
            properties,
            '$.weight',
            '$.age'
                 )
WHERE
    product_id = 1;
