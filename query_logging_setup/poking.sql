/**********************************************

Bigquery Log Queries

Docs on DataModel --> https://cloud.google.com/bigquery/docs/reference/auditlogs/rest/Shared.Types/BigQueryAuditMetadata 

Docs on data_access logs --> https://cloud.google.com/bigquery/docs/reference/auditlogs#data_access_data_access
Docs on admin_activity logs --> https://cloud.google.com/bigquery/docs/reference/auditlogs#admin_activity_activity
Docs on system_event logs --> https://cloud.google.com/bigquery/docs/reference/auditlogs#system_event_system_event 

Look through this reddit post for ideas from RedditEng --> https://www.reddit.com/r/RedditEng/comments/13iat74/wrangling_bigquery_at_reddit/

Github | GoogleCloudPlatform/bigquery-utils --> https://github.com/GoogleCloudPlatform/bigquery-utils/tree/master/views/audit
Github | GoogleCloudPlatform/bigquery-utils/views/audit/bigquery_audit_logs_v2.sql --> https://github.com/GoogleCloudPlatform/bigquery-utils/blob/master/views/audit/bigquery_audit_logs_v2.sql 
Github | GoogleCloudPlatform/bigquery-utils/views/audit/bigquery_script_logs_v2.sql --> https://github.com/GoogleCloudPlatform/bigquery-utils/blob/master/views/audit/bigquery_script_logs_v2.sql


**********************************************/

-- Dataset Volumetrics
SELECT
  REGEXP_EXTRACT(protopayload_auditlog.resourceName, '^projects/[^/]+/datasets/([^/]+)/tables') AS datasetRef,
  COUNT(DISTINCT REGEXP_EXTRACT(protopayload_auditlog.resourceName, '^projects/[^/]+/datasets/[^/]+/tables/(.*)$')) AS active_tables,
  COUNTIF(JSON_QUERY(protopayload_auditlog.metadataJson, "$.tableDataRead") IS NOT NULL) AS dataReadEvents,
  COUNTIF(JSON_QUERY(protopayload_auditlog.metadataJson, "$.tableDataChange") IS NOT NULL) AS dataChangeEvents,
  MAX(timestamp)
FROM `bearded-data.bigquery_logs.cloudaudit_googleapis_com_data_access_*`
WHERE
  JSON_QUERY(protopayload_auditlog.metadataJson, "$.tableDataRead") IS NOT NULL
  OR JSON_QUERY(protopayload_auditlog.metadataJson, "$.tableDataChange") IS NOT NULL
GROUP BY datasetRef
ORDER BY datasetRef;

-- Job Volumetrics
SELECT DATE_TRUNC(eventTimestamp, DAY)
  , COUNT(*) AS number_of_jobs
  , SUM(CASE WHEN jobChange.jobStatus.errorResult.code IS NOT NULL THEN 1 ELSE 0 END) AS number_of_errored_jobs
  , SUM(estimatedCostUsd) total_est_cost
FROM `bearded-data.bigquery_logs.bigquery_audit_logs_v2`
WHERE eventTimestamp BETWEEN TIMESTAMP(DATE_ADD(CURRENT_DATE(), INTERVAL -10 DAY)) AND TIMESTAMP(CURRENT_DATE())
GROUP BY 1
ORDER BY 1 DESC;

-- Errored Jobs
SELECT principalEmail, COUNT(*) errors
FROM `bearded-data.bigquery_logs.bigquery_audit_logs_v2`
WHERE eventTimestamp BETWEEN TIMESTAMP(DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)) AND TIMESTAMP(CURRENT_DATE())
AND jobChange.jobStatus.errorResult.code IS NOT NULL
GROUP BY 1 
ORDER BY 2;

-- Dive into specific errors
SELECT *
FROM `bearded-data.bigquery_logs.bigquery_audit_logs_v2`
WHERE eventTimestamp BETWEEN TIMESTAMP(DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)) AND TIMESTAMP(CURRENT_DATE())
AND jobChange.jobStatus.errorResult.code IS NOT NULL
AND principalEmail = 'testing@bearded-data.iam.gserviceaccount.com';

/**************************************************** TESTING OFF RAW TABLES ************************************************************/

SELECT DISTINCT
    insertid
    , protopayload_auditlog.authenticationInfo.principalEmail
    , resource.type
    , protopayload_auditlog.methodName
    , resource.labels.dataset_id
    , protopayload_auditlog.resourceName
    , REGEXP_EXTRACT(protopayload_auditlog.resourceName, r'/([^/]+)/?$') AS table_name
    , timestamp
    , protopayload_auditlog.metadataJson AS request_metadata
    , JSON_VALUE(protopayload_auditlog.metadataJson , "$.jobChange.job.jobConfig.queryConfig.query") AS request_query
    , JSON_VALUE(protopayload_auditlog.metadataJson , "$.jobInsertion.job.jobConfig.queryConfig.query") AS request_query_2
    , protopayload_auditlog.status.code
    , protopayload_auditlog.status.message
FROM `bearded-data.bigquery_logs.cloudaudit_googleapis_com_data_access_*`
WHERE 1=1
AND protopayload_auditlog.methodName IN (
  'google.cloud.bigquery.v2.JobService.Query'
  , 'google.cloud.bigquery.v2.JobService.GetQueryResults'
)
--AND severity='ERROR'
ORDER BY timestamp DESC;

SELECT DISTINCT
    insertid
    , protopayload_auditlog.authenticationInfo.principalEmail
    , resource.type
    , protopayload_auditlog.methodName
    , resource.labels.dataset_id
    , protopayload_auditlog.resourceName
    , REGEXP_EXTRACT(protopayload_auditlog.resourceName, r'/([^/]+)/?$') AS table_name
    , timestamp
    , protopayload_auditlog.metadataJson AS request_metadata
    , JSON_VALUE(protopayload_auditlog.metadataJson , "$.jobChange.job.jobConfig.queryConfig.query") AS request_query
    , JSON_VALUE(protopayload_auditlog.metadataJson , "$.jobInsertion.job.jobConfig.queryConfig.query") AS request_query_2
    , protopayload_auditlog.status.code
    , protopayload_auditlog.status.message
FROM `bearded-data.bigquery_logs.cloudaudit_googleapis_com_data_access_*`
WHERE 1=1
AND protopayload_auditlog.methodName IN (
  'google.cloud.bigquery.v2.TableService.InsertTable'
  , 'google.cloud.bigquery.v2.TableService.UpdateTable'
  , 'google.cloud.bigquery.v2.TableService.PatchTable'
  , 'google.cloud.bigquery.v2.TableService.DeleteTable'
)
--AND severity='ERROR'
ORDER BY timestamp DESC;

SELECT DISTINCT
    insertid
    , protopayload_auditlog.authenticationInfo.principalEmail
    , resource.type
    , protopayload_auditlog.methodName
    , resource.labels.dataset_id
    , protopayload_auditlog.resourceName
    , REGEXP_EXTRACT(protopayload_auditlog.resourceName, r'/([^/]+)/?$') AS table_name
    , timestamp
    , protopayload_auditlog.metadataJson AS request_metadata
    , JSON_VALUE(protopayload_auditlog.metadataJson , "$.jobChange.job.jobConfig.queryConfig.query") AS request_query
    , JSON_VALUE(protopayload_auditlog.metadataJson , "$.jobInsertion.job.jobConfig.queryConfig.query") AS request_query_2
    , protopayload_auditlog.status.code
    , protopayload_auditlog.status.message
FROM `bearded-data.bigquery_logs.cloudaudit_googleapis_com_data_access_*`
WHERE 1=1
AND protopayload_auditlog.methodName IN (
  'google.cloud.bigquery.v2.DatasetService.InsertDataset'
, 'google.cloud.bigquery.v2.DatasetService.UpdateDataset'
, 'google.cloud.bigquery.v2.DatasetService.PatchDataset'
, 'google.cloud.bigquery.v2.DatasetService.DeleteDataset'
, 'google.cloud.bigquery.v2.TableDataService.List'
)
--AND severity='ERROR'
ORDER BY timestamp DESC;


select distinct
protopayload_auditlog.authenticationInfo.principalEmail
, resource.labels.dataset_id
, protopayload_auditlog.resourceName
, REGEXP_EXTRACT(protopayload_auditlog.resourceName, r'/([^/]+)/?$') AS table_name
, timestamp
, protopayload_auditlog.requestMetadata.requestAttributes.query
, textpayload
, protopayload_auditlog.status.code
, protopayload_auditlog.status.message
FROM `bearded-data.bigquery_logs.cloudaudit_googleapis_com_activity_*`
where 1=1
--AND severity='ERROR'
ORDER BY timestamp DESC;


select distinct
protopayload_auditlog.authenticationInfo.principalEmail
, resource.labels.dataset_id
, protopayload_auditlog.resourceName
, REGEXP_EXTRACT(protopayload_auditlog.resourceName, r'/([^/]+)/?$') AS table_name
, timestamp
, protopayload_auditlog.requestMetadata.requestAttributes.query
, protopayload_auditlog.metadataJson
, protopayload_auditlog.status.code
, protopayload_auditlog.status.message
FROM `bearded-data.bigquery_logs.cloudaudit_googleapis_com_system_event*`
where 1=1
-- AND resource.type = 'bigquery_dataset'
-- AND severity='ERROR'
ORDER BY timestamp DESC;

