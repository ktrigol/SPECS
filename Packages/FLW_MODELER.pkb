    create or replace package body flw_modeler as 
    /*
    Copyright 203 Insum Solutions
    Author: Kael Trigo
    Overview:
    Package in charge of creating the xml file that will be used by the plugin
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
        -- Global variables
        g_xml_data clob := 
            '<?xml version="1.0" encoding="UTF-8"?>
            <bpmn:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:apex="https://flowsforapex.org" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" id="Definitions_1wzb475" targetNamespace="http://bpmn.io/schema/b" exporter="Flows for APEX" exporterVersion="22.2.0">
            <bpmn:process id="Process_pjnihis0" isExecutable="false" apex:isCallable="false" apex:manualInput="false">
                #XML_HEADER#
                #XML_ARROW_H#
            </bpmn:process>
            <bpmndi:BPMNDiagram id="BPMNDiagram_1">
                <bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_pjnihis0">
                #XML_ARROW_B#
                #XML_BODY#
                </bpmndi:BPMNPlane>
            </bpmndi:BPMNDiagram>
            </bpmn:definitions>';

        -- Global Constants
        k_pxl_spcing   number := 110;
        k_pxl_offset1  number := 50;
        k_pxl_offset2  number := 30;
        k_start_pos1   number := 350;
        k_start_pos2   number := 430;
        /************************************************************************
        ------------------------------------------------------------------------- 
        Function Description: Returns the complete xml file for the plugin
        Return: XML 
        Parameters:  
            @ p_spc_id    NOT NULL        ID of the specificity
            @ p_lang      NOT NULL        Code of the language
        -------------------------------------------------------------------------
        */
        function get_xml_flow_code ( 
            p_flw_type_id in number
        ) return clob
        is 
            l_xml           clob;
            l_xml_header    clob;
            l_xml_body      clob;
            l_xml_arrow_h   clob;
            l_xml_arrow_b   clob;
        begin
            -- Create the xml code for the substitution
            flw_modeler.gen_xml_substitution(
                p_flw_type_id => p_flw_type_id
                , p_xml_header  => l_xml_header
                , p_xml_body    => l_xml_body
                , p_xml_arrow_h => l_xml_arrow_h
                , p_xml_arrow_b => l_xml_arrow_b
            );

        return regexp_replace(
                regexp_replace(
                regexp_replace(
                regexp_replace(g_xml_data, '#XML_HEADER#' , l_xml_header)
                                        , '#XML_BODY#'   , l_xml_body)
                                        , '#XML_ARROW_B#', l_xml_arrow_b)
                                        , '#XML_ARROW_H#', l_xml_arrow_h);

        end get_xml_flow_code;
    
        /************************************************************************
        -------------------------------------------------------------------------
        Procedure Description: Generates the xml code for the substitution
        Parameters:
            @ p_flw_type_id    NOT NULL        ID of the flow type
        out:
            @ p_xml_header      NOT NULL        XML code for the header
            @ p_xml_body        NOT NULL        XML code for the body
            @ p_xml_arrow_h     NOT NULL        XML code for the arrows header
            @ p_xml_arrow_b     NOT NULL        XML code for the arrows body
        -------------------------------------------------------------------------
        */

        procedure gen_xml_substitution ( 
            p_flw_type_id     in number
            , p_xml_header      in out clob
            , p_xml_body        in out clob
            , p_xml_arrow_h     in out clob
            , p_xml_arrow_b     in out clob
        )is
            -- Variables
            l_xml_body          clob;
            l_xml_header        clob;
            l_xml_arrow_h       clob;
            l_xml_arrow_b       clob;
            l_end_event_pos     number;
            l_next_step_number  number;
            l_btn_name          flw_type_step_option_v.button_name%type;
            l_max_step_number   number;
            l_min_step_number   number;
            -- Cursor
            cursor c_xml(p_flw_type_id in number) is
                select rownum + 1 as rnum,  id, status, next_step_ids, previous_step_ids, step_number
                from (
                    select id
                        , status 
                        , (select listagg(distinct next_step_id,':') within group (order by next_step_id) 
                            from  flw_type_step_option_v 
                            where flw_type_step_id = t1.id) as next_step_ids
                        , (select listagg(distinct flw_type_step_id,':') within group (order by flw_type_step_id) 
                            from  flw_type_step_option_v 
                            where next_step_id = t1.id) as previous_step_ids
                        , step_number
                    from flw_type_step_v t1
                    where flw_type_id = p_flw_type_id
                    order by step_number
                );
        begin 

            -- Start event (circle)
            l_xml_header := '<bpmn:startEvent id="EventStart" name="Start" >
                              <bpmn:outgoing>StartSequenceFlow</bpmn:outgoing>
                            </bpmn:startEvent>';
            l_xml_body := '<bpmndi:BPMNShape id="Event_1h2j0b1_di" bpmnElement="EventStart">
                                <dc:Bounds x="102" y="372" width="36" height="36" />
                                <bpmndi:BPMNLabel>
                                <dc:Bounds x="95" y="415" width="53" height="14" />
                                </bpmndi:BPMNLabel>
                            </bpmndi:BPMNShape>';

            -- Get the first step and last step number of the flow
            select min(step_number) into l_min_step_number from flw_type_step_v where flw_type_id = p_flw_type_id;
            select max(step_number) into l_max_step_number from flw_type_step_v where flw_type_id = p_flw_type_id;

            -- Loop through the cursor
            for r_xml in c_xml(p_flw_type_id) loop
                -- Verify if the step has next steps
                if r_xml.next_step_ids is not null or r_xml.previous_step_ids is not null then 
                    l_end_event_pos := r_xml.rnum + 1;
                    -- Add the task
                    l_xml_header := l_xml_header ||
                        '<bpmn:task id="Task'||r_xml.step_number||'" name="'||r_xml.status||'" >';

                    -- Create the outgoing for each next step
                    for r_next_step_ids in (select column_value as next_step_id from table(apex_string.split(r_xml.next_step_ids,':'))) loop 
                        
                        -- Verify if the step has previous steps if not add the incoming from the start event
                        if l_min_step_number = r_xml.step_number then
                            l_xml_header := l_xml_header ||
                                '   <bpmn:incoming>StartSequenceFlow</bpmn:incoming>';
                            l_xml_arrow_h := l_xml_arrow_h ||
                            '<bpmn:sequenceFlow id="StartSequenceFlow" sourceRef="EventStart" targetRef="Task'||r_xml.step_number||'" />';
                            l_xml_arrow_b := l_xml_arrow_b ||
                            '<bpmndi:BPMNEdge id="Flow_055yyy0_di" bpmnElement="StartSequenceFlow">
                                <di:waypoint x="138" y="390" />
                                <di:waypoint x="'|| ((r_xml.rnum) * k_pxl_spcing) ||'" y="390" />
                            </bpmndi:BPMNEdge>';
                        end if;

                        -- Get the next step, step number
                        select step_number
                        into l_next_step_number
                        from flw_type_step_v
                        where id = r_next_step_ids.next_step_id;

                        -- Get the button name
                        select listagg( distinct button_name, ' \ ') within group ( order by id)
                        into l_btn_name
                        from flw_type_step_option_v
                        where flw_type_step_id = r_xml.id
                        and next_step_id = r_next_step_ids.next_step_id;

                        -- Add the outgoing tags
                        l_xml_header := l_xml_header ||
                            '   <bpmn:outgoing>SequenceFlow_'||r_xml.step_number||'_'||l_next_step_number||'</bpmn:outgoing>';
                    
                        l_xml_arrow_h := l_xml_arrow_h ||
                            '<bpmn:sequenceFlow id="SequenceFlow_'||r_xml.step_number||'_'||l_next_step_number||'" name="'||l_btn_name||'" sourceRef="Task'||r_xml.step_number||'" targetRef="Task'||l_next_step_number||'" />';

                        l_xml_arrow_b := l_xml_arrow_b || 
                            flw_modeler.get_xml_arrow_body ( 
                                p_from_task   => r_xml.step_number
                            , p_to_task     => l_next_step_number
                            , p_rownum      => r_xml.rnum
                            );
                    end loop;

                    -- Create the incoming for each previous step
                    for r_previous_step_ids in (select column_value as previous_step_id from table(apex_string.split(r_xml.previous_step_ids,':'))) loop 

                        -- Verify if the step has next steps if not add the outcoming for the end event
                        if l_max_step_number = r_xml.step_number then
                            l_xml_header := l_xml_header ||
                                '   <bpmn:outgoing>EndSequenceFlow</bpmn:outgoing>';
                            l_xml_arrow_h := l_xml_arrow_h ||
                            '<bpmn:sequenceFlow id="EndSequenceFlow" sourceRef="Task'||r_xml.step_number||'" targetRef="EventEnd" />';
                            l_xml_arrow_b := l_xml_arrow_b ||
                            '<bpmndi:BPMNEdge id="Flow_155yyy0_di" bpmnElement="EndSequenceFlow">
                                <di:waypoint x="'|| (((r_xml.rnum) * k_pxl_spcing) + 100 ) ||'" y="390" />
                                <di:waypoint x="' || (((l_end_event_pos) * k_pxl_spcing) + 60) || '" y="390" />
                            </bpmndi:BPMNEdge>';
                        end if;
                        
                        -- Get the step number from the previous step
                        select step_number
                        into l_next_step_number
                        from flw_type_step_v
                        where id = r_previous_step_ids.previous_step_id;

                        -- Add the incoming tags
                        l_xml_header := l_xml_header ||
                            '   <bpmn:incoming>SequenceFlow_'||l_next_step_number||'_'||r_xml.step_number||'</bpmn:incoming>';
                    
                    end loop;

                    -- Close the task tag
                    l_xml_header := l_xml_header ||
                        '</bpmn:task>';
                else 
                -- if there is no next step, then point to the end event
                -- TODO:
                    l_xml_header := l_xml_header ||
                        '<bpmn:task id="Task'||r_xml.rnum||'" name="'||r_xml.status||'" />';
                end if;

                -- Add the task to the body
                l_xml_body := l_xml_body ||
                '<bpmndi:BPMNShape id="Activity_'||r_xml.step_number||'i2x8rq_di" bpmnElement="Task'||r_xml.step_number||'">
                    <dc:Bounds x="'|| ((r_xml.rnum) * k_pxl_spcing) ||'" y="350" width="100" height="80" />
                </bpmndi:BPMNShape>';
                

            end loop;

            -- End event (circle)
            l_xml_header := l_xml_header || '<bpmn:endEvent id="EventEnd" name="End" >
                                                <bpmn:incoming>EndSequenceFlow</bpmn:incoming>
                                            </bpmn:endEvent>';
            l_xml_body  := l_xml_body || 
                '<bpmndi:BPMNShape id="Event_0xe2vcd_di" bpmnElement="EventEnd">
                    <dc:Bounds x="' || (((l_end_event_pos) * k_pxl_spcing) + 60) || '" y="372" width="36" height="36" />
                    <bpmndi:BPMNLabel>
                    <dc:Bounds x="' || (((l_end_event_pos) * k_pxl_spcing) + 60) || '" y="415" width="36" height="14" />
                    </bpmndi:BPMNLabel>
                </bpmndi:BPMNShape>';

            p_xml_header    := l_xml_header;
            p_xml_body      := l_xml_body;
            p_xml_arrow_h   := l_xml_arrow_h;
            p_xml_arrow_b   := l_xml_arrow_b;

        end;

        /************************************************************************
        -------------------------------------------------------------------------
        Function Description: Generates the xml body code for the arrows (sequence flows)
        Parameters:
            @ p_from_task NOT NULL              From task number (step number)
            @ p_to_task NOT NULL                To task number (step number)
            @ p_rownum NOT NULL                 Row number
        -------------------------------------------------------------------------
        */

        function get_xml_arrow_body ( 
            p_from_task   in varchar2
            , p_to_task     in varchar2
            , p_rownum      in number
        ) return clob 
        is
            -- Variables
            l_xml_arrow     clob;
        begin

            if p_from_task < p_to_task then
                l_xml_arrow := 
                '<bpmndi:BPMNEdge id="Flow_'||p_from_task||p_to_task||'p9pgyk_di" bpmnElement="SequenceFlow_'||p_from_task||'_'||p_to_task||'">
                    <di:waypoint x="'|| ((p_rownum ) * k_pxl_spcing + k_pxl_offset1) ||'" y="'||k_start_pos1||'" />
                    <di:waypoint x="'|| ((p_rownum ) * k_pxl_spcing + k_pxl_offset1) ||'" y="'||(k_start_pos1 - (p_rownum * k_pxl_offset2))||'" />
                    <di:waypoint x="'|| ((p_to_task + 1) * k_pxl_spcing + k_pxl_offset2) ||'" y="'||(k_start_pos1 - (p_rownum * k_pxl_offset2))||'" />
                    <di:waypoint x="'|| ((p_to_task + 1) * k_pxl_spcing + k_pxl_offset2) ||'" y="'||k_start_pos1||'" />
                <bpmndi:BPMNLabel>	
                    <dc:Bounds x="'|| ((p_to_task + 1) * k_pxl_spcing)||'" y="'||(350 - (p_rownum * k_pxl_offset2)-13)||'" width="10" height="0" />	
                </bpmndi:BPMNLabel>
                </bpmndi:BPMNEdge>';
            elsif p_from_task > p_to_task then
                l_xml_arrow := 
                '<bpmndi:BPMNEdge id="Flow_'||p_from_task||p_to_task||'p9pgyk_di" bpmnElement="SequenceFlow_'||p_from_task||'_'||p_to_task||'">
                    <di:waypoint x="'|| ((p_rownum ) * k_pxl_spcing + k_pxl_offset1) ||'" y="'||k_start_pos2||'" />
                    <di:waypoint x="'|| ((p_rownum ) * k_pxl_spcing + k_pxl_offset1) ||'" y="'||(k_start_pos2 + (p_from_task * k_pxl_offset2))||'" />
                    <di:waypoint x="'|| ((p_to_task + 1) * k_pxl_spcing + k_pxl_offset2) ||'" y="'||(k_start_pos2 + (p_from_task * k_pxl_offset2))||'" />
                    <di:waypoint x="'|| ((p_to_task + 1) * k_pxl_spcing + k_pxl_offset2) ||'" y="'||k_start_pos2||'" />
                <bpmndi:BPMNLabel>	
                    <dc:Bounds x="'|| ((p_to_task + 1) * k_pxl_spcing + k_pxl_offset2 + 18) ||'" y="'||(430 + (p_from_task * k_pxl_offset2) + 1)||'" width="10" height="0" />	
                </bpmndi:BPMNLabel>
                </bpmndi:BPMNEdge>';
            end if;
            return l_xml_arrow;

        end get_xml_arrow_body;

    end flw_modeler;