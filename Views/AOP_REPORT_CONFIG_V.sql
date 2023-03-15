--------------------------------------------------------
--  DDL for View AOP_REPORT_CONFIG_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE VIEW "AOP_REPORT_CONFIG_V" (
          "ID"
        , "REPORT_CODE"
        , "REPORT_TYPE"
        , "REPORT_NAME"
        , "FILENAME"
        , "MIME_TYPE"
        , "REPORT"
        , "OUTPUT_TYPE"
        , "DOWNLOAD_FILENAME"
        , "DOWNLOAD_MIME_TYPE"
        , "LAST_UPDATE"
    ) DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select t1.id
       , t1.report_code
       , t1.report_type
       , t2.report_name
       , t2.filename 
       , t2.mime_type
       , t2.report 
       , t1.output_type
       , t2.download_filename
       , t2.download_mime_type
       , t2.modified
  from aop_report_config t1
  left join aop_report_config_lang t2
  on t1.id = t2.report_id 
  where t2.report_lang_id = flw_util.get_language_id()
 or nvl(t2.report_lang_id, -1 ) = -1;
