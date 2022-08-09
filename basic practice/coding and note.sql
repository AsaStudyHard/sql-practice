SHOW SCHEMAS;

/*
  SQL110 插入记录（一）
  现在有两个用户的作答记录详情如下：
    用户1001在2021年9月1日晚上10点11分12秒开始作答试卷9001，并在50分钟后提交，得了90分；
    用户1002在2021年9月4日上午7点1分2秒开始作答试卷9002，并在10分钟后退出了平台。
    试卷作答记录表exam_record中，表已建好，其结构如下，请用一条语句将这两条记录插入表中。

  日期 + interval expr unit
  具体的可以参考: https://dev.mysql.com/doc/refman/5.7/en/expressions.html#temporal-intervals

  mysql 中时间类型
    数据类型	    “零”价值
    DATE	    '0000-00-00'
    TIME	    '00:00:00'
    DATETIME	'0000-00-00 00:00:00'
    TIMESTAMP	'0000-00-00 00:00:00'
    YEAR	    0000
*/
USE sql_basic;
DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;

# truncate 删除表数据, 同时重置我们的主键自增
TRUNCATE exam_record;


INSERT INTO `exam_record`
VALUES (NULL, 1001, 9001, '2021-09-01 22:11:12', '2021-09-01 22:11:12' + INTERVAL 50 MINUTE, 90),
       (NULL, 1002, 9002, '2021-09-04 07:01:02', NULL, NULL);


/*
 SQL111 插入记录（二）
 我们已经创建了一张新表exam_record_before_2021用来备份2021年之前的试题作答记录，结构和exam_record表一致，
 请将2021年之前的已完成了的试题作答纪录导入到该表。

 使用insert into 和 select 一起使用, 但是我们需要注意的是insert中的 field 和 select中的field必须要是一致的
 使用日期函数获取我们目标数据进行比对

 */
DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
CREATE TABLE IF NOT EXISTS exam_record_before_2021
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
TRUNCATE exam_record;
TRUNCATE exam_record_before_2021;

INSERT INTO exam_record(uid, exam_id, start_time, submit_time, score)
VALUES (1001, 9001, '2020-01-01 09:00:01', NULL, NULL),
       (1001, 9002, '2020-01-02 09:01:01', '2020-01-02 09:21:01', 70),
       (1001, 9002, '2020-09-02 09:00:01', NULL, NULL),
       (1002, 9001, '2021-05-02 10:01:01', '2021-05-02 10:30:01', 81),
       (1002, 9002, '2021-09-02 12:01:01', NULL, NULL);

INSERT INTO `exam_record_before_2021`(uid, exam_id, start_time, submit_time, score)
SELECT uid, exam_id, start_time, submit_time, score
FROM sql_basic.exam_record
WHERE YEAR(submit_time) < 2021
  AND score IS NOT NULL;

SELECT *
FROM exam_record_before_2021;

/*
 SQL112 插入记录（三）
 现在有一套ID为9003的高难度SQL试卷，时长为一个半小时，请你将 2021-01-01 00:00:00 作为发布时间
 插入到试题信息表examination_info（其表结构如下图），不管该ID试卷是否存在，都要插入成功，请尝试插入它。

 notice: 使用replace into 与insert into 完全类似, 但是需要注意的是, replace into必须要要表中含有索引, 他会把旧索引数据删除, 然后添加新索引的数据
 */
DROP TABLE IF EXISTS examination_info;
CREATE TABLE IF NOT EXISTS examination_info
(
    id           int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    exam_id      int UNIQUE NOT NULL COMMENT '试卷ID',
    tag          varchar(32) COMMENT '类别标签',
    difficulty   varchar(8) COMMENT '难度',
    duration     int        NOT NULL COMMENT '时长(分钟数)',
    release_time datetime COMMENT '发布时间'
) CHARACTER SET utf8
  COLLATE utf8_bin;
TRUNCATE examination_info;
INSERT INTO examination_info(exam_id, tag, difficulty, duration, release_time)
VALUES (9001, 'SQL', 'hard', 60, '2020-01-01 10:00:00'),
       (9002, '算法', 'easy', 60, '2020-01-01 10:00:00'),
       (9003, 'SQL', 'medium', 60, '2020-01-02 10:00:00'),
       (9004, '算法', 'hard', 80, '2020-01-01 10:00:00');

REPLACE INTO `examination_info`
VALUES (NULL, 9003, 'SQL', 'hard', 90, '2021-01-01 00:00:00');


/*
 SQL113 更新记录（一）
 请把examination_info表中tag为PYTHON的tag字段全部修改为Python。
 */
DROP TABLE IF EXISTS examination_info;
CREATE TABLE IF NOT EXISTS examination_info
(
    id           int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    exam_id      int UNIQUE NOT NULL COMMENT '试卷ID',
    tag          varchar(32) COMMENT '类别标签',
    difficulty   varchar(8) COMMENT '难度',
    duration     int        NOT NULL COMMENT '时长',
    release_time datetime COMMENT '发布时间'
) CHARACTER SET utf8
  COLLATE utf8_bin;
TRUNCATE examination_info;
INSERT INTO examination_info(exam_id, tag, difficulty, duration, release_time)
VALUES (9001, 'SQL', 'hard', 60, '2020-01-01 10:00:00'),
       (9002, 'python', 'easy', 60, '2020-01-01 10:00:00'),
       (9003, 'Python', 'medium', 80, '2020-01-01 10:00:00'),
       (9004, 'PYTHON', 'hard', 80, '2020-01-01 10:00:00');

UPDATE sql_basic.`examination_info`
SET tag = 'Python'
WHERE tag = 'PYTHON';
# 使用replace函数, 表示替换的意思.
UPDATE sql_basic.`examination_info`
SET tag = REPLACE(tag, 'PYTHON', 'Python')
WHERE tag = '%PYTHON%';


/*
 SQL114 更新记录（二）
 请把exam_record表中2021年9月1日之前开始作答的未完成记录全部改为被动完成，即：将完成时间改为'2099-01-01 00:00:00'，分数改为0

 notice: 在 set 中表示多个条件时, 使用 逗号(comma )进行分隔
 */
DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
INSERT INTO exam_record(uid, exam_id, start_time, submit_time, score)
VALUES (1001, 9001, '2020-01-02 09:01:01', '2020-01-02 09:21:01', 80),
       (1001, 9002, '2021-09-01 09:01:01', '2021-09-01 09:21:01', 90),
       (1002, 9001, '2021-08-02 19:01:01', NULL, NULL),
       (1002, 9002, '2021-09-05 19:01:01', '2021-09-05 19:40:01', 89),
       (1003, 9001, '2021-09-02 12:01:01', NULL, NULL),
       (1003, 9002, '2021-09-01 12:01:01', NULL, NULL);

UPDATE sql_basic.`exam_record`
SET submit_time = '2099-01-01 00:00:00',
    score       = 0
WHERE DATE(start_time) < '2021-09-01'
  AND submit_time IS NULL;


/*
 SQL115 删除记录（一)
 请删除exam_record表中作答时间小于5分钟整且分数不及格（及格线为60分）的记录；

 notice: 我们需要获取start_time 和 submit_time之间分钟数,
        解决思路: 1. subdate(submit_time, interval 5 minute) < start_time
                2. timestampdiff(minute, start_time, submit_time) < 5
                   TIMESTAMPDIFF(unit,datetime_expr1,datetime_expr2)
                3. adddate(start_time, interval 5 minute) > submit_time
*/
DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
TRUNCATE exam_record;
INSERT INTO exam_record(uid, exam_id, start_time, submit_time, score)
VALUES (1001, 9001, '2020-01-01 22:11:12', '2020-01-01 23:16:12', 50),
       (1001, 9002, '2020-01-02 09:01:01', '2020-01-02 09:06:00', 58),
       (1002, 9001, '2021-05-02 10:01:01', '2021-05-02 10:05:58', 60),
       (1002, 9002, '2021-06-02 19:01:01', '2021-06-02 19:05:01', 54),
       (1003, 9001, '2021-09-05 19:01:01', '2021-09-05 19:40:01', 49),
       (1003, 9001, '2021-09-05 19:01:01', '2021-09-05 19:15:01', 70),
       (1003, 9001, '2021-09-06 19:01:01', '2021-09-06 19:05:01', 80),
       (1003, 9002, '2021-09-09 07:01:02', NULL, NULL);
DELETE
FROM sql_basic.exam_record
WHERE score < 60
  AND ADDDATE(start_time, INTERVAL 5 MINUTE) > submit_time;

/*
SQL116 删除记录（二)
请删除exam_record表中未完成作答或作答时间小于5分钟整的记录中，开始作答时间最早的3条记录。

notice: 获取分钟的间隔方式和上文一样, 关键在于如何获取前3条记录, 使用limit, 注意在delete中使用limit只要一个参数就好了, limit3
        如果写成limit0, 3就会报错了
*/

DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
TRUNCATE exam_record;
INSERT INTO exam_record(uid, exam_id, start_time, submit_time, score)
VALUES (1001, 9001, '2020-01-01 22:11:12', '2020-01-01 23:16:12', 50),
       (1001, 9002, '2020-01-02 09:01:01', '2020-01-02 09:06:00', 58),
       (1001, 9002, '2020-01-02 09:01:01', '2020-01-02 09:05:01', 58),
       (1002, 9001, '2021-05-02 10:01:01', '2021-05-02 10:06:58', 60),
       (1002, 9002, '2021-06-02 19:01:01', NULL, NULL),
       (1003, 9001, '2021-09-05 19:01:01', NULL, NULL),
       (1003, 9001, '2021-09-05 19:01:01', NULL, NULL),
       (1003, 9002, '2021-09-09 07:01:02', NULL, NULL);
DELETE
FROM sql_basic.`exam_record`
WHERE TIMESTAMPDIFF(MINUTE, start_time, submit_time) < 5
   OR submit_time IS NULL
ORDER BY start_time
LIMIT 3;


/*
 SQL117 删除记录（三）
 请删除exam_record表中所有记录，并重置自增主键。

 notice:DROP TABLE, TRUNCATE TABLE, DELETE TABLE　三种删除语句的区别
        1.DROP TABLE　清除表的scheme(表定义), 执行后不能撤销，被删除表格的关系，索引，权限等等都会被永久删除。
        2.TRUNCATE TABLE　只清除数据，保留表结构，列，权限，索引，视图，关系等等，相当于清零数据，执行后不能撤销。
        3.DELETE TABLE　删除（符合某些条件的）数据，执行后可以撤销。（但如何撤销我不知道T_T, 是作为事务进行回滚? 以后再学习)
        运行速度一般DROP最快，DELETE最慢，但是DELETE最安全。
 */

DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
TRUNCATE exam_record;
INSERT INTO exam_record(uid, exam_id, start_time, submit_time, score)
VALUES (1001, 9001, '2020-01-01 22:11:12', '2020-01-01 23:16:12', 50),
       (1001, 9002, '2020-01-02 09:01:01', '2020-01-02 09:06:00', 58);

TRUNCATE sql_basic.exam_record;


/*
 查询
 */

DROP TABLE IF EXISTS exam_record;
CREATE TABLE exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;

INSERT INTO exam_record(uid, exam_id, start_time, submit_time, score)
VALUES (1001, 9001, '2020-01-02 09:01:01', '2020-01-02 09:21:01', 80),
       (1001, 9001, '2021-05-02 10:01:01', '2021-05-02 10:30:01', 81),
       (1001, 9001, '2021-06-02 19:01:01', '2021-06-02 19:31:01', 84),
       (1001, 9002, '2021-09-05 19:01:01', '2021-09-05 19:40:01', 89),
       (1001, 9001, '2021-09-02 12:01:01', NULL, NULL),
       (1001, 9002, '2021-09-01 12:01:01', NULL, NULL),
       (1002, 9002, '2021-02-02 19:01:01', '2021-02-02 19:30:01', 87),
       (1002, 9001, '2021-05-05 18:01:01', '2021-05-05 18:59:02', 90),
       (1003, 9001, '2021-02-06 12:01:01', NULL, NULL),
       (1003, 9001, '2021-09-07 10:01:01', '2021-09-07 10:31:01', 89),
       (1004, 9001, '2021-09-06 12:01:01', NULL, NULL);

# null 不会被计数, 注意distinct 和 if的使用, if(expr, true res, false res), 然后distinct对整体进行去重
SELECT COUNT(start_time)                                          AS 'total_pv',
       COUNT(submit_time)                                         AS 'complete_pv',
       COUNT(DISTINCT IF(submit_time IS NOT NULL, exam_id, NULL)) AS 'complete_exam_id'
FROM exam_record;


/*
SQL119 修改表
请在用户信息表，字段level的后面增加一列最多可保存15个汉字的字段school；
并将表中job列名改为profession，同时varchar字段长度变为10；achievement的默认值设置为0。

notice:
        1. alter table table_name add column field_name type [after field_name]  使用after表示我们这个字段放在哪个字段后 我们也可以直接使用first替代, 表示放在第一位
        2. alter table table_name modify column field_name type  修改field的类型
        3. alter table table_name change column old_name new_name type 修改字段名
        4. alter table table_name drop colum field_name 删除字段
        5. alter table table_name modify colum field_name type first
        6. alter table table_name rename new_name

 */

DROP TABLE IF EXISTS user_info;
CREATE TABLE IF NOT EXISTS user_info
(
    id            int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid           int UNIQUE NOT NULL COMMENT '用户ID',
    `nick_name`   varchar(64) COMMENT '昵称',
    achievement   int COMMENT '成就值',
    level         int COMMENT '用户等级',
    job           varchar(10) COMMENT '职业方向',
    register_time datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;

ALTER TABLE user_info
    ADD COLUMN `school`          varchar(15) AFTER level,
    CHANGE COLUMN job profession varchar(10),
    MODIFY COLUMN achievement int DEFAULT 0;

DESC user_info;


/*
 SQL120 删除表

 现在随着数据越来越多，存储告急，请你把很久前的（2011到2014年）备份表都删掉（如果存在的话）
 */
DROP TABLE IF EXISTS exam_record;
CREATE TABLE IF NOT EXISTS exam_record
(
    id          int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    uid         int      NOT NULL COMMENT '用户ID',
    exam_id     int      NOT NULL COMMENT '试卷ID',
    start_time  datetime NOT NULL COMMENT '开始时间',
    submit_time datetime COMMENT '提交时间',
    score       tinyint COMMENT '得分'
) CHARACTER SET utf8
  COLLATE utf8_general_ci;
CREATE TABLE IF NOT EXISTS exam_record_2010 (LIKE exam_record);
CREATE TABLE IF NOT EXISTS exam_record_2012 (LIKE exam_record);
CREATE TABLE IF NOT EXISTS exam_record_2013 (LIKE exam_record);
CREATE TABLE IF NOT EXISTS exam_record_2014 (LIKE exam_record);
CREATE TABLE IF NOT EXISTS exam_record_2015 (LIKE exam_record);

DROP TABLE IF EXISTS `exam_record_2011`,
    `exam_record_2012`,
    `exam_record_2013`,
    `exam_record_2014`;

/*
 SQL121 创建索引

 在duration列创建普通索引idx_duration、在exam_id列创建唯一性索引uniq_idx_exam_id、在tag列创建全文索引full_idx_tag。
 */
DROP TABLE IF EXISTS examination_info;
CREATE TABLE IF NOT EXISTS examination_info
(
    id           int PRIMARY KEY AUTO_INCREMENT COMMENT '自增ID',
    exam_id      int UNIQUE NOT NULL COMMENT '试卷ID',
    tag          varchar(32) COMMENT '类别标签',
    difficulty   varchar(8) COMMENT '难度',
    duration     int        NOT NULL COMMENT '时长',
    release_time datetime COMMENT '发布时间'
) CHARACTER SET utf8
  COLLATE utf8_bin;

ALTER TABLE `examination_info`
    ADD INDEX `idx_duration` (duration),
    ADD UNIQUE INDEX `uniq_idx_exam_id` (exam_id),
    ADD FULLTEXT INDEX `full_idx_tag` (tag);

SHOW INDEX FROM sql_basic.`examination_info`;

/*
 SQL122 删除索引

 请删除examination_info表上的唯一索引uniq_idx_exam_id和全文索引full_idx_tag。
 */
ALTER TABLE sql_basic.`examination_info`
    DROP INDEX `uniq_idx_exam_id`,
    DROP index `full_idx_tag`;






