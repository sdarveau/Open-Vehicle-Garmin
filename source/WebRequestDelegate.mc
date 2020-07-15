//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.StringUtil;

class WebRequestDelegate extends WatchUi.BehaviorDelegate {
    
    var parentView;
    

	// Set up the callback to the view
    function initialize(view) {
        BehaviorDelegate.initialize();
        parentView = view;
        
        parentView.onLoading();
        makeRequest();
    }

    // Handle menu button press
    function onMenu() {
        makeRequest();
        return true;
    }

    function onSelect() {
    	parentView.onLoading();
        makeRequest();
        return true;
    }

	function makeRequest() {                  
	   	var url = "https://uic35l8x77.execute-api.us-east-1.amazonaws.com/prod/ovms/charge";
	   
	   	var vehicle_id = "";
	   	var username = "";
	   	var password = "";
	   
	   	try {
		   	if ( Toybox.Application has :Storage ) {
	       		vehicle_id = Application.Properties.getValue("vehicleid");
	       		username = Application.Properties.getValue("username");
	       		password = Application.Properties.getValue("token");
		   	}
			else {
		   	   	vehicle_id = Application.getApp().getProperty("vehicleid");
		   	   	username = Application.getApp().getProperty("username");
		   	   	password = Application.getApp().getProperty("token");
		   	}
		}
		catch(ex instanceof InvalidKeyException) {
			parentView.credentialsSet = false;
			return;
		}
		catch(ex) {
			return;
		}
	   	
       	var params = {
        	"vehicle_id" => vehicle_id,
       		"username" => username,
       	   	"password" => password
       	};

       	var options = {                                             
        	:method => Communications.HTTP_REQUEST_METHOD_GET,      
           	:headers => {                                           
            	       "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                                                               
           	:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
       	};
       
       	var responseCallback = method(:onReceive);                  

       	Communications.makeWebRequest(url, params, options, method(:onReceive));
	}

    // Receive the data from the web request
    function onReceive(responseCode, data) {
    	System.print("response code: " + responseCode.toString());
        if (responseCode == 200) {
            parentView.onReceive(data);
        }
        else if(responseCode == Communications.BLE_CONNECTION_UNAVAILABLE){
        	parentView.connectionAvailable = false;
        	parentView.onReceive("Conn. Unavail.");
        }
        else if(responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
        	parentView.onReceive("Timeout:" + responseCode.toString());
        } 
        else {
            parentView.onReceive("Error: " + responseCode.toString());
        }
    }
}