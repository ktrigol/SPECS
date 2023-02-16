DROP TABLE "SPC_VAL_COUNTER";
--------------------------------------------------------
--  DDL for Table SPC_VAL_COUNTER
--------------------------------------------------------

  CREATE TABLE "SPC_VAL_COUNTER" ("CODE" VARCHAR2(50) COLLATE "USING_NLS_COMP"
                                , "GREATEST_VALUE" NUMBER DEFAULT 0
                                , "YEAR" VARCHAR2(4) COLLATE "USING_NLS_COMP"
                                )  DEFAULT COLLATION "USING_NLS_COMP";

   COMMENT ON COLUMN "SPC_VAL_COUNTER"."CODE" IS 'Allow users to reference the counter by the code in the specificities';
   COMMENT ON COLUMN "SPC_VAL_COUNTER"."GREATEST_VALUE" IS 'Current value of the greatest number for the counter';
   COMMENT ON COLUMN "SPC_VAL_COUNTER"."YEAR" IS 'Allows the counter to reset by year';
--------------------------------------------------------
--  DDL for Index INC_GREATEST_VAL_COUNTER_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "INC_GREATEST_VAL_COUNTER_PK" ON "SPC_VAL_COUNTER" ("CODE", "YEAR");
--------------------------------------------------------
--  Constraints for Table SPC_VAL_COUNTER
--------------------------------------------------------

  ALTER TABLE "SPC_VAL_COUNTER" MODIFY ("CODE" NOT NULL ENABLE);
  ALTER TABLE "SPC_VAL_COUNTER" MODIFY ("YEAR" NOT NULL ENABLE);
  ALTER TABLE "SPC_VAL_COUNTER" ADD CONSTRAINT "INC_GREATEST_VAL_COUNTER_PK" PRIMARY KEY ("CODE", "YEAR") USING INDEX  ENABLE;
