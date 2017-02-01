

var SUPPORTPLATFORMTYPES = {
    //
    iOS     : "Apple_iOS",
    Android : "Google_Android",
    Unknown : "undefined_Unknown"
};

var CURRENT_PLATFORM = SUPPORTPLATFORMTYPES.Unknown;


var Bridge = new function() {
    //
    this.toNative = function(className, params, callBack) {
        //
        if(this.canNativePlatformIdentifiy()) {
            if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.iOS) {
                //
                this.toNative_iOS(className, params, callBack);
            } else if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.Android) {
                //
                this.toNative_Android(className, params, callBack);
            }
        } else {
            //
        }
    };
    //
    this.fromNative = function(jsonObj_) {
        // 
        setTimeout(
            function() {
                   //
                var jsonObj = jsonObj_;
                if(Bridge.canNativePlatformIdentifiy()) {
                   //
                    if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.iOS) {
                   //
                    	Bridge.fromNative_iOS(jsonObj);
                    } else if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.Android){
                   //
                    	Bridge.fromNative_Android(jsonObj);
                    }
                } else {
                   // 
                }
            }
        ,50);
    };
    
    this.callbackFromNative = function(jsonObj_) {
        //
    	setTimeout(function() {
			//
			var jsonObj = jsonObj_;
			//
			if (Bridge.canNativePlatformIdentifiy() == true) {
				//
				if (CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.iOS) {
					//
					Bridge.callbackFromNative_iOS(jsonObj);
				} else if (CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.Android) {
					//
					Bridge.callbackFromNative_Android(jsonObj);
				}
			} else {
				//
			}
		}, 50);
    };
    
    this.callbackToNative = function(jsonObj) {
        //
        if(this.canNativePlatformIdentifiy() == true) {
            //
            if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.iOS) {
                //
                this.callbackToNative_iOS(jsonObj);
            } else if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.Android) {
                //
                this.callbackToNative_Android(jsonObj);
            }
        } else {
            //
        }
    };
    //-----------------------------------------------------------------------------------------------------------------------------------------------//
    ///////////////////////////////       iOS             /////////////////////////////////////////////
    this.toNative_iOS = function(className, params, callBack) {
        //
        var jsonObj = {
        className: className,
        params: params,
        callBack: callBack
        };
        //
        var iframe = document.createElement("IFRAME");
        
        iframe.setAttribute("src", "js-objective-c-callfromwebview:"+JSON.stringify(jsonObj));
        
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    };
    
    this.callbackFromNative_iOS = function(jsonObj) {
        //
        var obj = jsonObj;
        var js = obj["callBackJS"];
        delete obj["callBackJS"];
        
        eval(js+"(obj)");
    };
    
    this.fromNative_iOS = function(json) {
        //
        var obj = json;
        var js = obj["functionName"];
        var params = obj["params"];
        var callBackClass = obj["callBackClass"];
        
        delete obj["functionName"];
        delete obj["callBackClass"];
        
        var callBackJsonObj = null;
        var response = null;
        
        try {
            eval("var val = "+js+"(params)");
            if(typeof(val) == "undefined") {
                response = {
                    callStatus : true,
                };
            } else {
                response = {
                    callStatus : true,
                    parm : val
                };
            }
            callBackJsonObj = {
            status: true,
            className: callBackClass,
            response:response
            };
            
        } catch(e) {
            var reason = {reason: e.message};
            
            response = {
                callStatus : false,
            reason: reason
            };
            
            callBackJsonObj = {
            status:false,
            className: callBackClass,
            response: response
            };
        }
        //
        this.callbackToNative_iOS(callBackJsonObj);
    };
    
    this.callbackToNative_iOS = function(jsonObj) {
        // 
        var iframe = document.createElement("IFRAME");
        iframe.setAttribute("src", "js-objective-c-responsefromwebview:"+JSON.stringify(jsonObj));
        
        document.documentElement.appendChild(iframe);
        iframe.parentNode.removeChild(iframe);
        iframe = null;
    };
    //----------------------------------------------------------------------------------------------------------------------------//
    ///////////////////////////////       Android             /////////////////////////////////////////////
    
    
    this.toNative_Android = function(className, params, callBack) {
        //
        var jsonObj = {
        className: className,
        params: params,
        callBack: callBack
        };
        //
        BridgeInterface.requestFromWebView(JSON.stringify(jsonObj));
    };
    
    this.callbackFromNative_Android = function(jsonObj) {
        //
        var obj = jsonObj;
        var js = obj["callBackJS"];
        delete obj["callBackJS"];
        
        eval(js+"(obj)");
    };
    
    this.fromNative_Android = function(jsonObj) {
        //
        var obj = jsonObj;
        var js = obj["functionName"];
        var params = obj["params"];
        var callBackClass = obj["callBackClass"];
        
        delete obj["functionName"];
        delete obj["callBackClass"];
        
        var callBackJsonObj = null;
        var response = null;
        
        try {
            eval("var val = "+js+"(params)");
            if(typeof(val) == "undefined") {
                response = {
                    callStatus : true,
                };
            } else {
                response = {
                    callStatus : true,
                    parm : val
                };
            }
            callBackJsonObj = {
            status: true,
            className: callBackClass,
            response:response
            };
            
        } catch(e) {
            var reason = {reason: e.message};
            
            response = {
                callStatus : false,
            reason: reason
            };
            
            callBackJsonObj = {
            status:false,
            className: callBackClass,
            response: response
            };
        }
        
        this.callbackToNative_Android(callBackJsonObj);
    };
    
    
    this.callbackToNative_Android = function(jsonObj) {
        BridgeInterface.responseFromWebView(JSON.stringify(jsonObj));
    };
    
    
    //----------------------------------------------------------------------------------------------------------------------------//
    ///////////////////////////////       Get Current OS             /////////////////////////////////////////////
    
    this.canNativePlatformIdentifiy = function() {
        //
        if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.Unknown) {
            CURRENT_PLATFORM = this.getOS();
            if(CURRENT_PLATFORM == SUPPORTPLATFORMTYPES.Unknown) {
                return false;
            }
        }
        //
        return true;
    };
    
    this.getOS = function() {
        //
        var userAgent = navigator.userAgent || navigator.vendor || window.opera;
        
        if (userAgent.match(/iPad/i) || userAgent.match(/iPhone/i) || userAgent.match(/iPod/i)) {
            return SUPPORTPLATFORMTYPES.iOS;
        } else if (userAgent.match(/Android/i)) {
            return SUPPORTPLATFORMTYPES.Android;
        }
        //
        return SUPPORTPLATFORMTYPES.Unknown;
    };
};



var proxyConsolelog = window.console.log.bind(window.console);