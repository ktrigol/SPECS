CREATE TABLE  "DEMO_STAGIAIRE_DEPARTEMENT" 
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"DEP_NAME" VARCHAR2(500) COLLATE "USING_NLS_COMP"
   )  DEFAULT COLLATION "USING_NLS_COMP";

  CREATE UNIQUE INDEX  "ID_STAGIAIRE_DEP_PK" ON  "DEMO_STAGIAIRE_DEPARTEMENT" ("ID");

ALTER TABLE  "DEMO_STAGIAIRE_DEPARTEMENT" ADD CONSTRAINT "DEMO_STAGIAIRE_DEP_PK" PRIMARY KEY ("ID")
  USING INDEX  "ID_STAGIAIRE_DEP_PK"  ENABLE;
/