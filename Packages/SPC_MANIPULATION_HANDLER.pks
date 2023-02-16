create or replace PACKAGE "SPC_MANIPULATION_HANDLER" AS 

/*
   Copyright 203 Insum Solutions
   Author: Kael Trigo
   Overview:

   Package in charge of manipulating and save the specificities data.

   Requirements

   * APEX is installed 
   * Package is executed from within an APEX application
     or
     At least one APEX workspace has been created

   If APEX is not installed go to apex.oracle.com for instructions.

   <provide code example to use workspace API>

   Modification History
 *------------------------------------------------------------------* 
 | Date      | Who                | What                            |
 *------------------------------------------------------------------*
   0000-00-00 Name Lastname        text

 *------------------------------------------------------------------*

 */
  
    /************************************************************************
    ------------------------------------------------------------------------- 
    Procedure Description: Runs the collection and save the changes on the 
                           spc_data table
    Parameters: 
    -------------------------------------------------------------------------
    */

    procedure set_spc_data;
    

END SPC_MANIPULATION_HANDLER;

