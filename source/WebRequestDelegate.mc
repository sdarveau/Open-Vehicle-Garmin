//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Cryptography;
using Toybox.Math;
using Toybox.System;
using Toybox.Lang;
using Toybox.StringUtil;

class WebRequestDelegate extends WatchUi.BehaviorDelegate {
    
    const TOKEN_SIZE = 22;
    
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
    
    function buildToken() {
    	var time = System.getClockTime();
	    Math.srand(time.sec);
	    var token = new [TOKEN_SIZE]b;
	    for(var i = 0; i < TOKEN_SIZE; i++)
	    {
	    	token.add(Math.rand() % 64);
	    }
	    return token;
	}
    
    function buildHash(token) {
	    
	    var hash = new Cryptography.Hash({ :algorithm => Cryptography.HASH_MD5 });
	
	    // Add the byte arrays to the hash
	    hash.update(token);
	
	    return hash.digest(); // Return computed hash as a ByteArray
	}

	function makeRequest() {
       //var url = "https://api.openvehicles.com:6869/api/charge/H23VAS";                     
	   var url = "https://c0tak3t4w4.execute-api.us-east-1.amazonaws.com/dev/ovms/charge";
       var params = {};

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
        	parentView.onReceive("Conn. Unavail.");
        }
        else if(responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
        	parentView.onReceive("Timeout:" + responseCode.toString());
        } 
        else {
            parentView.onReceive("Failed\nError: " + responseCode.toString());
        }
    }
}