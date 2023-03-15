DROP TABLE "AOP_REPORT_CONFIG";
--------------------------------------------------------
--  DDL for Table AOP_REPORT_CONFIG
--------------------------------------------------------

  CREATE TABLE "AOP_REPORT_CONFIG" (
      "ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE 
    , "REPORT_CODE" VARCHAR2(50) COLLATE "USING_NLS_COMP"
    , "REPORT_TYPE" VARCHAR2(4) COLLATE "USING_NLS_COMP"
    , "OUTPUT_TYPE" VARCHAR2(4) COLLATE "USING_NLS_COMP"
    , "CREATED" DATE
    , "CREATED_BY" VARCHAR2(60) COLLATE "USING_NLS_COMP"
    , "MODIFIED" DATE
    , "MODIFIED_BY" VARCHAR2(60) COLLATE "USING_NLS_COMP"
    )  DEFAULT COLLATION "USING_NLS_COMP";

   COMMENT ON TABLE "AOP_REPORT_CONFIG" IS 'Table to create the report configuration';
   COMMENT ON COLUMN "AOP_REPORT_CONFIG"."ID" IS 'Unique ID for the record';
   COMMENT ON COLUMN "AOP_REPORT_CONFIG"."REPORT_CODE" IS 'Report code';
   COMMENT ON COLUMN "AOP_REPORT_CONFIG"."CREATED" IS 'Date and time the record was created';
   COMMENT ON COLUMN "AOP_REPORT_CONFIG"."CREATED_BY" IS 'User who created the record';
   COMMENT ON COLUMN "AOP_REPORT_CONFIG"."MODIFIED" IS 'Date and time the record was last modified';
   COMMENT ON COLUMN "AOP_REPORT_CONFIG"."MODIFIED_BY" IS 'User who last modified the record';

--------------------------------------------------------
--  DDL for Index ID_SPC_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "AOP_REPORT_CONFIG_PK" ON "AOP_REPORT_CONFIG" ("ID");
--------------------------------------------------------
--  DDL for Index AOP_REPORT_CONFIG_UK1
--------------------------------------------------------

  CREATE UNIQUE INDEX "AOP_REPORT_CONFIG_UK1" ON "AOP_REPORT_CONFIG" ("REPORT_CODE");
--------------------------------------------------------
--  DDL for Index AOP_REPORT_CONFIG_IDX1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "AOP_REPORT_CONFIG_BIU" 
    before insert or update  
    on AOP_REPORT_CONFIG 
    for each row
begin
    if inserting and :new.created is null then
        :new.created    := sysdate; 
        :new.created_by := nvl(sys_context('APEX$SESSION','APP_USER'),user); 
    end if; 
    :new.modified    := sysdate; 
    :new.modified_by := nvl(sys_context('APEX$SESSION','APP_USER'),user); 
end AOP_REPORT_CONFIG_BIU;

ALTER TRIGGER "AOP_REPORT_CONFIG_BIU" ENABLE;
--------------------------------------------------------
--  Constraints for Table AOP_REPORT_CONFIG
--------------------------------------------------------

  ALTER TABLE "AOP_REPORT_CONFIG" MODIFY ("REPORT_CODE" NOT NULL ENABLE);
  ALTER TABLE "AOP_REPORT_CONFIG" MODIFY ("CREATED" NOT NULL ENABLE);
  ALTER TABLE "AOP_REPORT_CONFIG" MODIFY ("CREATED_BY" NOT NULL ENABLE);
  ALTER TABLE "AOP_REPORT_CONFIG" MODIFY ("MODIFIED" NOT NULL ENABLE);
  ALTER TABLE "AOP_REPORT_CONFIG" MODIFY ("MODIFIED_BY" NOT NULL ENABLE);

  ALTER TABLE "AOP_REPORT_CONFIG" ADD CONSTRAINT "AOP_REPORT_CONFIG_PK" PRIMARY KEY ("ID") USING INDEX "AOP_REPORT_CONFIG_PK"  ENABLE;
  ALTER TABLE "AOP_REPORT_CONFIG" ADD CONSTRAINT "AOP_REPORT_CONFIG_UK1" UNIQUE ("REPORT_CODE") USING INDEX "AOP_REPORT_CONFIG_UK1"  ENABLE;

