/***
 * Casting from mysql to postgres
 *
 */

-- On mysql
CREATE TEMPORARY table tmp_xlt_types (src varchar(64),
  dst varchar(64), PRIMARY key (src));
insert into tmp_xlt_types values ('date', 'date');
insert into tmp_xlt_types values ('datetime', 'timestamp');
insert into tmp_xlt_types values ('time', 'time');

-- Generate Postgres DDL
SELECT c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.DATETIME_PRECISION,
concat(
  'alter table ', c.TABLE_NAME, ' ',
  'alter column ', c.COLUMN_NAME, ' type ', xlt.dst,
  case when c.DATETIME_PRECISION >=4 /*because debezium*/
    then concat(
      ' using convert_unixtime_usec_to_timestamp(',c.COLUMN_NAME,') ')
    else ''
  end,
  ';'
) as cmd
FROM INFORMATION_SCHEMA.COLUMNS c
INNER JOIN INFORMATION_SCHEMA.TABLES t
  ON t.TABLE_CATALOG=c.TABLE_CATALOG
    and t.TABLE_SCHEMA=c.TABLE_SCHEMA
    and t.TABLE_NAME=c.TABLE_NAME
LEFT JOIN tmp_xlt_types xlt
  on xlt.src = c.DATA_TYPE
WHERE c.DATA_TYPE in ('datetime', 'date', 'timestamp', 'time')
  and c.TABLE_SCHEMA='culqidb'
  and c.TABLE_NAME not like 'tmp_%'
  and t.TABLE_TYPE='base table';


/**
 * Casting Date/Time Types on Postgres
 */
--int8 (usec precision) -> timestamp
CREATE OR REPLACE FUNCTION convert_unixtime_usec_to_timestamp(xdt int8)
RETURNS timestamp AS $$
  SELECT (to_timestamp(xdt/1000000) at time zone 'UTC')::timestamp
$$ LANGUAGE sql;

CREATE CAST (int8 as timestamp)
  with function convert_unixtime_usec_to_timestamp(int8) as assignment;


--int8 (msec precision) -> timestamp
CREATE OR REPLACE FUNCTION convert_unixtime_msec_to_timestamp(xdt int8)
RETURNS timestamp AS $$
  SELECT (to_timestamp(xdt/1000) at time zone 'UTC')::timestamp
$$ LANGUAGE sql;

CREATE CAST (int8 as timestamp)
  with function convert_unixtime_msec_to_timestamp(int8) as assignment;


--int4 -> timestamp [x]
CREATE OR REPLACE FUNCTION convert_unixtime_msec_to_timestamp(xdt int4)
RETURNS timestamp AS $$
  SELECT (to_timestamp(xdt/1000) at time zone 'UTC')::timestamp
$$ LANGUAGE sql;

CREATE CAST (int4 as timestamp)
  with function convert_unixtime_msec_to_timestamp(int4) as assignment;


--int4 -> date [x]
CREATE OR REPLACE FUNCTION convert_unixtime_days_to_date(xdt int4)
RETURNS date AS $$
  SELECT (to_timestamp(xdt*86400) at time zone 'UTC')::date
$$ LANGUAGE sql;

CREATE CAST (int4 as date)
  with function convert_unixtime_days_to_date(int4) as assignment;
