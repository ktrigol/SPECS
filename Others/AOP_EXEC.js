/***********************************************************/
/***********************************************************/
/**** AOP : Function tools to execute the reports****/
/***********************************************************/
/***********************************************************/



/*
APPLICATION PROCESS TO CREATE IN APEX
--------------------------------------
AOP_PROCESS
--------------------------------------
begin
    
    -------
    --Generate the report to have a blob result in a collection
    -------
    aop_rapports_pkg.generer_rapport(
                        p_code_rapport   => apex_application.g_x01,
                        p_valeurs        => apex_application.g_x02,
                        p_langue_rapport => apex_application.g_x03                  
    );
    
exception when no_data_found then
        aop_util_pkg.ecrire_json_output(p_execution_flag => 0,
                                            p_error_message => 'Aucune donnée trouvée pour produire le rapport.');
       
end;

--------------------------------------
AOP_PROCESS_BATCH
--------------------------------------
DECLARE
  l_item varchar2(32767);  
BEGIN
    AOP_RAPPORTS_BATCH_PKG.creer_rapport_batch(apex_application.g_x01,apex_application.g_x02);
    
    apex_json.open_object;
    apex_json.write('success', true);
    apex_json.close_object; 
EXCEPTION
when others then 
    apex_json.open_object;
    apex_json.write('success', true);
    apex_json.close_object;
END;
*/
var aop = aop || {};

var $wP;

aop.rapport_aop = {};

aop.rapport_aop.display_error_message = function(p_error_message) {

    apex.message.clearErrors();
    apex.message.showErrors(
        [{
            type: "error",
            location: "page",
            message: p_error_message,
            unsafe: false
        }]
    );

};

//General Function to call the AOP reports
aop.rapport_aop.executer_rapport_aop = function(p_process_name, p_valeurs, p_langue_rapport) {
    console.log(p_process_name)

    $wP = parent.apex.widget.waitPopup();
    apex.server.process(
        'AOP_PROCESS', {
            x01: p_process_name,
            x02: p_valeurs,
            x03: p_langue_rapport
        }, {
            success: function(pData) {
                           
                $wP.remove();
                if (pData.execution_flag == 1 && (!pData.p_inline || pData.p_inline == 'N')) {
                    apex.navigation.redirect(pData.url);
                } else if (pData.execution_flag == 1 && pData.p_inline == 'Y') {
                    apex.navigation.redirect(pData.url);
                } else {
                    aop.rapport_aop.display_error_message(pData.error_message);
                }

            }
        }
    );
};

//General Function to call the AOP reports in Batch
aop.rapport_aop.executer_rapport_aop_batch = function(p_process_name, p_valeurs) {
    alert(p_process_name);
    alert(p_valeurs);
    $wP = parent.apex.widget.waitPopup();
    apex.server.process(
        'AOP_PROCESS_BATCH', {
            x01: p_process_name,
            x02: p_valeurs
        }, {
            success: function(pData) {
                $wP.remove();
                
                if (pData.execution_flag == 1 && (!pData.p_inline || pData.p_inline == 'N')) {
                    apex.navigation.redirect(pData.url);
                } else if (pData.execution_flag == 1 && pData.p_inline == 'Y') {
                    apex.navigation.openInNewWindow(pData.url);
                } else {
                    aop.rapport_aop.display_error_message(pData.error_message);
                }

            }
        }
    );
};


/***********************************************************/
//Saving Triggering Element when opening a modal page LOV
try {
$(".button.a-Button.a-Button--popupLOV.ig-lov-open").click(function(event) {
    var vTriggeringElementId = $(this).closest("tr").find("td.lov input").attr("id");
    var vTriggeringCtx;

    if (vTriggeringElementId == null) {
        vTriggeringCtx = "IG";

        var static = $(this).closest('div[class=a-IG]').attr("id");
        static = static.substr(0, static.length - 3);

        var rowId = $(this).closest('tr').data('id');
        var columns = $(this).attr("cols-to-set");

        var sessionRowId = gLocalStorage.setItem( "triggeringRowId", rowId );
        var sessioncolumns = gLocalStorage.setItem( "triggeringColumns", columns );
        var sessionStaticId = gLocalStorage.setItem( "triggeringRegion", static );

    }
    else {
        vTriggeringCtx = "ITEM";
        // var sessionElement = gLocalStorage.setItem( "triggeringElementId", vTriggeringElementId );
        var fields = $(this).attr("cols-to-set");
        var sessionElement = gLocalStorage.setItem( "triggeringFields", fields );

    }

    var sessionContext = gLocalStorage.setItem( "triggeringElementCtxId", vTriggeringCtx );

});
}
catch(err) {
  console.log("Error with Saving Triggering Element when opening a modal page LOV");
}


//OnClose event for modal pages LOV
try {
$(document).on("apexafterclosedialog", function(e, data) {

    /*
    var vActiveElement = e.currentTarget.activeElement;
    if ( $(vActiveElement).attr("class").indexOf("ig-lov-open") < 0 ){
        return;
    }
    */

    var vTriggeringCtx = gLocalStorage.getItem( "triggeringElementCtxId" );

    if (vTriggeringCtx == "ITEM") {

        /*
        if ( ($(this).data) && (vItemId) ) {
            apex.item( vItemId ).setValue(data.P2000_R1);
        }
        */

        var fields = gLocalStorage.getItem( "triggeringFields" );

        var fieldArray = fields.split(',');

        var returnValue;

        for (var i = 0; i < fieldArray.length; i++) {
            switch(i) {
                case 0:
                    returnValue = data.P2000_D1;
                    break;
                case 1:
                    returnValue = data.P2000_R1;
                    break;
                case 2:
                    returnValue = data.P2000_D2;
                    break;
                case 3:
                    returnValue = data.P2000_R2;
                    break;
                case 4:
                    returnValue = data.P2000_D3;
                    break;
                case 5:
                    returnValue = data.P2000_R3;
                    break;
                case 6:
                    returnValue = data.P2000_D4;
                    break;
                case 7:
                    returnValue = data.P2000_R4;
                    break;
                case 8:
                    returnValue = data.P2000_D5;
                    break;
                case 9:
                    returnValue = data.P2000_R5;
                    break;
                case 10:
                    returnValue = data.P2000_D6;
                    break;
                case 11:
                    returnValue = data.P2000_R6;
                    break;
            }

                apex.item( fieldArray[i] ).setValue(returnValue);
        }

        // localStorage.removeItem( "triggeringElementId" );
        gLocalStorage.removeItem( "triggeringFields" );

    } else if (vTriggeringCtx == "IG") {

        var static = gLocalStorage.getItem( "triggeringRegion" );

        var ig$ = apex.region(static).widget();
        var model = ig$.interactiveGrid("getViews", "grid").model;

        var rowId = gLocalStorage.getItem( "triggeringRowId" );
        var columns = gLocalStorage.getItem( "triggeringColumns" );

        var record = model.getRecord(rowId);

        var columnArray = columns.split(',');

        var returnValue;

        for (var i = 0; i < columnArray.length; i++) {
            switch(i) {
                case 0:
                    returnValue = data.P2000_D1;
                    break;
                case 1:
                    returnValue = data.P2000_R1;
                    break;
                case 2:
                    returnValue = data.P2000_D2;
                    break;
                case 3:
                    returnValue = data.P2000_R2;
                    break;
                case 4:
                    returnValue = data.P2000_D3;
                    break;
                case 5:
                    returnValue = data.P2000_R3;
                    break;
                case 6:
                    returnValue = data.P2000_D4;
                    break;
                case 7:
                    returnValue = data.P2000_R4;
                    break;
                case 8:
                    returnValue = data.P2000_D5;
                    break;
                case 9:
                    returnValue = data.P2000_R5;
                    break;
                case 10:
                    returnValue = data.P2000_D6;
                    break;
                case 11:
                    returnValue = data.P2000_R6;
                    break;
            }

            model.setValue(record,columnArray[i],returnValue);
        }

        gLocalStorage.removeItem( "triggeringRegion" );
        gLocalStorage.removeItem( "triggeringRowId" );
        gLocalStorage.removeItem( "triggeringColumns" );

    }

    gLocalStorage.removeItem( "triggeringElementCtxId" );

});
}
catch(err) {
  console.log("Error with OnClose event for modal pages LOV");
}


