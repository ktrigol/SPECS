DROP TABLE "SPC_DEFINITION";
--------------------------------------------------------
--  DDL for Table SPC_DEFINITION
--------------------------------------------------------

  CREATE TABLE "SPC_DEFINITION" ("ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE 
                                  , "APP_ID" NUMBER --& NEW 
                                  , "PAGE_ID" NUMBER --& NEW 
                                  , "GROUP_DEF_ID" NUMBER --& NEW 
                                  , "SPC_CODE" VARCHAR2(500) COLLATE "USING_NLS_COMP"
                                  , "DISP_SEQ" NUMBER 
                                  , "FIELD_TYPE" VARCHAR2(60) COLLATE "USING_NLS_COMP"
                                  , "COUNTER_CODE" VARCHAR2(50) COLLATE "USING_NLS_COMP"
                                  , "MANDATORY_IND" NUMBER DEFAULT 0
                                  , "READ_ONLY_IND" NUMBER DEFAULT 0
                                  , "ACTIVE_IND" NUMBER DEFAULT 1
                                  , "SYSDATE_IND" NUMBER --?
                                  , "HELP_TEXT_IND" NUMBER DEFAULT 0
                                  , "LIST_GROUP" VARCHAR2(255) COLLATE "USING_NLS_COMP"
                                  , "LIST_CODE" VARCHAR2(255) COLLATE "USING_NLS_COMP"
                                  , "DEFAULT_VALUE" VARCHAR2(2000) COLLATE "USING_NLS_COMP"
                                  , "ITEM_SIZE" NUMBER
                                  , "ITEM_MAX_LENGTH" NUMBER
                                  , "FORMAT_ID" NUMBER
                                  --, "SPC_CONDITION_PRNT_ID" NUMBER --?
                                  --, "SPC_CONDITION_DISP_ID" NUMBER
                                  --, "MAX_VALUE" VARCHAR2(255) COLLATE "USING_NLS_COMP"
                                  --, "MIN_VALUE" VARCHAR2(255) COLLATE "USING_NLS_COMP"
                                  , "CREATED" DATE
                                  , "CREATED_BY" VARCHAR2(60) COLLATE "USING_NLS_COMP"
                                  , "MODIFIED" DATE
                                  , "MODIFIED_BY" VARCHAR2(60) COLLATE "USING_NLS_COMP"
                                  )  DEFAULT COLLATION "USING_NLS_COMP";

   COMMENT ON COLUMN "SPC_DEFINITION"."APP_ID" IS 'Application ID to relate to the specificity';
   COMMENT ON COLUMN "SPC_DEFINITION"."PAGE_ID" IS 'Page ID to relate to the specificity';
   COMMENT ON COLUMN "SPC_DEFINITION"."GROUP_DEF_ID" IS 'References the ID of the table SPC_GROUP_DEFINITION';
   COMMENT ON COLUMN "SPC_DEFINITION"."SPC_CODE" IS 'Allows the specificity to be identify by a code';
   COMMENT ON COLUMN "SPC_DEFINITION"."DISP_SEQ" IS 'Allows the specificities to be order by the sequence number';
   COMMENT ON COLUMN "SPC_DEFINITION"."FIELD_TYPE" IS 'Indicates the type of item that corresponds to the specificity (date,list,text,etc..)';
   COMMENT ON COLUMN "SPC_DEFINITION"."COUNTER_CODE" IS 'This column references the counter defined in SPC_VAL_COUNTER';
   COMMENT ON COLUMN "SPC_DEFINITION"."MANDATORY_IND" IS 'Flag for mandatory specificities';
   COMMENT ON COLUMN "SPC_DEFINITION"."READ_ONLY_IND" IS 'Flag for read only specificities';
   COMMENT ON COLUMN "SPC_DEFINITION"."SYSDATE_IND" IS 'Indicates if the specificity of date should have a validation (1: max date sysdate; 2: min date sysdate)';
   COMMENT ON COLUMN "SPC_DEFINITION"."ACTIVE_IND" IS 'Indicates if the specificity is active or inactive';
   COMMENT ON COLUMN "SPC_DEFINITION"."HELP_TEXT_IND" IS 'Indicates if the specificity has a help text';
   COMMENT ON COLUMN "SPC_DEFINITION"."DEFAULT_VALUE" IS 'Allows the user to define a default value for the specificity';
   COMMENT ON COLUMN "SPC_DEFINITION"."ITEM_SIZE" IS 'Allows the user to define the size of the item';
   COMMENT ON COLUMN "SPC_DEFINITION"."ITEM_MAX_LENGTH" IS 'Allows the user to define the maximum length of the item';
   COMMENT ON COLUMN "SPC_DEFINITION"."FORMAT_ID" IS 'Allows the user to assign the format of the item';
   --COMMENT ON COLUMN "SPC_DEFINITION"."SPC_CONDITION_PRNT_ID" IS ''; --?
   --COMMENT ON COLUMN "SPC_DEFINITION"."SPC_CONDITION_DISP_ID" IS ''; --?
   --COMMENT ON COLUMN "SPC_DEFINITION"."MAX_VALUE" IS ''; --?
   --COMMENT ON COLUMN "SPC_DEFINITION"."MIN_VALUE" IS ''; --?
   COMMENT ON COLUMN "SPC_DEFINITION"."CREATED" IS 'Allows to identify the date the record was created';
   COMMENT ON COLUMN "SPC_DEFINITION"."CREATED_BY" IS 'Allows to identify the user who created the record';
   COMMENT ON COLUMN "SPC_DEFINITION"."MODIFIED" IS 'Allows identify the date the record was modified';
   COMMENT ON COLUMN "SPC_DEFINITION"."MODIFIED_BY" IS 'Allows to identify the user who modified the record';
--------------------------------------------------------
--  DDL for Index ID_SPC_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ID_SPC_PK" ON "SPC_DEFINITION" ("ID");
--------------------------------------------------------
--  DDL for Index SPC_DEFINITION_UK1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "SPC_DEFINITION_UK1" ON "SPC_DEFINITION" ("APP_ID", "PAGE_ID", "SPC_CODE");
--------------------------------------------------------
--  DDL for Index SPC_DEFINITION_IDX1
--------------------------------------------------------

  CREATE INDEX "SPC_DEFINITION_IDX1" ON "SPC_DEFINITION" ("ID", "APP_ID", "PAGE_ID"/*, "SPC_CODE"*/);
--------------------------------------------------------
--  DDL for Trigger SPC_DEFINITION_BIU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "SPC_DEFINITION_BIU" 
    before insert or update  
    on SPC_DEFINITION 
    for each row
begin
    if inserting and :new.created is null then
        select nvl(max(d.disp_seq) + 10, 10)
        into :new.disp_seq
        from spc_definition d
        where d.app_id = :new.app_id
        and   d.page_id = :new.page_id
        and   d.group_def_id = :new.group_def_id;

        :new.spc_code   := 'ITEM_' || :new.id;
        :new.created    := sysdate; 
        :new.created_by := nvl(sys_context('APEX$SESSION','APP_USER'),user); 
    end if; 
    if updating and :new.group_def_id != :old.group_def_id then
        select nvl(max(d.disp_seq) + 10, 10)
        into :new.disp_seq
        from spc_definition d
        where d.app_id = :new.app_id
        and   d.page_id = :new.page_id
        and   d.group_def_id = :new.group_def_id;
    end if;
    :new.modified    := sysdate; 
    :new.modified_by := nvl(sys_context('APEX$SESSION','APP_USER'),user); 
end SPC_DEFINITION_BIU;
--------------------------------------------------------
--  Constraints for Table SPC_DEFINITION
--------------------------------------------------------

  --ALTER TABLE "SPC_DEFINITION" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("APP_ID" NOT NULL ENABLE); 
  ALTER TABLE "SPC_DEFINITION" MODIFY ("PAGE_ID" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("SPC_CODE" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("DISP_SEQ" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("FIELD_TYPE" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("CREATED" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("CREATED_BY" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("MODIFIED" NOT NULL ENABLE);
  ALTER TABLE "SPC_DEFINITION" MODIFY ("MODIFIED_BY" NOT NULL ENABLE);

  ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "ID_SPC_PK" PRIMARY KEY ("ID") USING INDEX "ID_SPC_PK"  ENABLE;
  ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "SPC_DEFINITION_UK1" UNIQUE ("APP_ID", "PAGE_ID", "SPC_CODE") USING INDEX  ENABLE;
  
--------------------------------------------------------
--  Ref Constraints for Table SPC_DEFINITION
--------------------------------------------------------
  
  ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "SPC_DEFINITION_FK1" FOREIGN KEY ("GROUP_DEF_ID") REFERENCES "SPC_GROUP_DEFINITION" ("ID") ENABLE;
  ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "SPC_DEFINITION_FK2" FOREIGN KEY ("FORMAT_ID") REFERENCES "SPC_FORMAT" ("ID") ENABLE;
  --ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "SPC_DEFINITION_FK1" FOREIGN KEY ("SPC_CONDITION_PRNT_ID") REFERENCES "SPC_DEFINITION" ("ID") ENABLE; --?
  --ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "SPC_DEFINITION_FK2" FOREIGN KEY ("SPC_CONDITION_DISP_ID") REFERENCES "SPC_DEFINITION" ("ID") ENABLE; --?
  --ALTER TABLE "SPC_DEFINITION" ADD CONSTRAINT "SPC_DEFINITION_FK3" FOREIGN KEY ("COUNTER_CODE") REFERENCES "SPC_VAL_COUNTER" ("CODE") ENABLE;