package gadget.util
{
	
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.events.Request;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.http.HTTPService;
	import mx.utils.StringUtil;
	import mx.utils.URLUtil;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.utils.HTTPLoader;
	
	public class SSOUtils
	{
		
		private static var sessionId:String; 
		private static var techSessionId:String;
		public function SSOUtils()
		{
		}
		
		public static function resetSession():void{
			sessionId =null;
			techSessionId=null;
		}
		
		private static  function technicallUserLogin(_preferences:Object,errorHandler:Function, successHandler:Function):void{
			var request:URLRequest = new URLRequest();			
			var strForwardSlash:String = _preferences.sodhost.charAt(_preferences.sodhost.length-1) == "/" ? "" : "/";			
			var stream:URLLoader = new URLLoader();
			
			stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:HTTPStatusEvent):void{
				var session:String = getHeaderValue(e.responseHeaders,'Set-Cookie');
				techSessionId =session.split(';')[0];
				successHandler(techSessionId);
			} );
			
			stream.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{				
				errorHandler(e);	
			});			
			request.url=_preferences.sodhost + strForwardSlash + "Services/Integration?command=login";			
			request.manageCookies=false;
			var username:String = _preferences.tech_username;
			var password:String = _preferences.tech_password;			
			
			request.requestHeaders.push(new URLRequestHeader("Username", username));
			request.requestHeaders.push(new URLRequestHeader("Password", password));		
			
			stream.load(request);		
		}
		
		
		/*
		* 
		*/
		public static function execute(pref:Object, successHandler:Function,errorHandler:Function,isTestLogin:Boolean=false,isAddmin:Boolean=false):void{
			if(isTestLogin){
				resetSession();
			}
			if(isAddmin){
				if(techSessionId==null){
					technicallUserLogin(pref,errorHandler,successHandler);
				}else{
					successHandler(techSessionId);
				}
				return;
			}
			if(sessionId!=null && sessionId!=''){
				successHandler(sessionId);
				return;
			}
			var sodhost:String = pref.sodhost;
			var strForwardSlash:String = sodhost.charAt(sodhost.length-1) == "/" ? "" : "/";
			var url:String = sodhost + strForwardSlash +  "Services/Integration?command=ssoitsurl&ssoid="+pref.company_sso_id;			
			
			
			
			var req:URLRequest=new URLRequest(url);
			req.followRedirects=false;
			req.method=URLRequestMethod.GET;
			req.useCache=false;
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {				
				errorHandler(e);
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {				
				doGetLocation(pref,successHandler,errorHandler,e,isTestLogin);
			});
			loader.load(req);
			
		}
		
		private static function getHeaderValue(headers:Array ,key:String, isJSESSION:Boolean = false): String{
			for each(var rHeader:URLRequestHeader in headers){
				if(isJSESSION){
					if(rHeader.name==key && rHeader.value.indexOf("JSESSIONID") != -1){
						return rHeader.value;
					}
				}else{
					if(rHeader.name==key){
						return rHeader.value;
					}
				}
			}	
			return '';
		}
		
		private static function doGetLocation(pref:Object,successHandler:Function,errorHandler:Function,e:HTTPStatusEvent,isTestLogin:Boolean):void{
			if(e.status==200){
				var headers:Array=e.responseHeaders;
				
				
				
				var loginUrl:String=getHeaderValue(headers,'X-SsoItsUrl');	
				var ssoHost:String = URLUtil.getProtocol(loginUrl)+"://"+URLUtil.getServerNameWithPort(loginUrl);
				var targetURL:String = loginUrl.substr(loginUrl.indexOf("TARGET"),loginUrl.length);
				targetURL = unescape(targetURL.split("=")[1]);
				var req:URLRequest=new URLRequest(loginUrl);
				req.method=URLRequestMethod.GET;
				req.followRedirects=true;
				
				req.useCache=true;
				//req.userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
				
				var loader:URLLoader=new URLLoader();
				loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
					errorHandler(e);
				});
				
				var isBreak:Boolean = false; 				
				
				loader.addEventListener(Event.COMPLETE,	function(e:Event):void{
					
					var body:String = URLLoader(e.target).data;
					
					var SAMLResponse:String=getValue(body,"name=\"SAMLResponse\" value=\"","\"");	
					if(StringUtils.isEmpty(SAMLResponse)){
						//try to get value from old version
						SAMLResponse = getValue(body,"NAME=\"SAMLResponse\" Value=\"","\">");
					}
					if(StringUtils.isEmpty(SAMLResponse)){
						
						var actionUrl:String=getValue(body,"action=\"","\"");
						req = new URLRequest(ssoHost+actionUrl);
						req.method=URLRequestMethod.GET;
						req.followRedirects=true;
						
						req.useCache=true;
						
						loader=new URLLoader();
						loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {					
							errorHandler(e);
						});
						
						loader.addEventListener(Event.COMPLETE,function(e:Event):void {	
							req = new URLRequest(ssoHost+"/nidp/app/login?sid=0");
							req.method=URLRequestMethod.POST;
							req.followRedirects=true;
							req.useCache=false;
							
							
							
							
							//req.userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
							req.contentType="application/x-www-form-urlencoded";
							
							var params:URLVariables = new URLVariables();
							params["Ecom_User_ID"] = pref.sodlogin;//"VIPUSER2";
							params["Ecom_Password"] = pref.sodpass;//"welcome2";
							params["option"] = "credential";
							req.data=params;
							loader=new URLLoader();
							
							
							loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {					
								errorHandler(e);
							});
							loader.addEventListener(Event.COMPLETE,function(e:Event):void {			
								
								invokeURLAndParse(pref,successHandler,errorHandler,isTestLogin,loginUrl,targetURL);
								
							});					
							
							
							loader.load(req);
						});			
						
						loader.load(req);
						
					}else{
						//have session
						postParse(body,pref,successHandler,errorHandler,isTestLogin,targetURL);
						
					}
					
					
		
					
				});
				loader.load(req);
				
				
				
				
				
			}else{
				//todo error
				var error:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,e.toString());				
				errorHandler(error);
			}
		}
import gadget.util.StringUtils;

		/**
		 * var actionUrl:String=getValue(body,"Action=\"","\"");						
			var SAMLResponse:String=getValue(body,"NAME=\"SAMLResponse\" Value=\"","\">");		
			var req:URLRequest= new URLRequest(actionUrl);
			req.method=URLRequestMethod.POST;
			req.followRedirects=false;
			
			req.useCache=false;
			var params:URLVariables = new URLVariables();
			params["TARGET"] = targetUrl;
		 * */
		private static function postParse(body:String,pref:Object,successHandler:Function,errorHandler:Function,isTestLogin:Boolean,targetUrl:String):void{
			var actionUrl:String=getValue(body,"action=\"","\"");	
			var targetParam:String = "RelayState";			
			var SAMLResponse:String=getValue(body,"name=\"SAMLResponse\" value=\"","\"");	
			if(StringUtils.isEmpty(actionUrl)){
				//OldVersion
				targetParam="TARGET";
				actionUrl= getValue(body,"Action=\"","\"");
				SAMLResponse=getValue(body,"NAME=\"SAMLResponse\" Value=\"","\">");		
			}
			var req:URLRequest= new URLRequest(actionUrl);
			req.method=URLRequestMethod.POST;
			req.followRedirects=false;
			
			req.useCache=false;
			var params:URLVariables = new URLVariables();
			params[targetParam] = targetUrl;
			params["SAMLResponse"] = SAMLResponse;
			req.data=params;
			var haveLocation:Boolean = false;
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {					
				errorHandler(e);
			});
			
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {	
				if(e.status==302){
					haveLocation = true;
					doGetSessionId(pref,successHandler,errorHandler,e,isTestLogin);
				}
				//trace(e.responseHeaders);
			});	
			
			loader.addEventListener(Event.COMPLETE,function(e:Event):void {	
				body = URLLoader(e.target).data;				
				if(!haveLocation){					
					var actionUrl1:String=htmlUnescape(getValue(body,"action=\"","\""));	
					var odSsoTokenG:String=htmlUnescape(getValue(body,"name=\"odSsoTokenG\" value=\"","\""));	
					actionUrl1 = unescape(actionUrl1);
					odSsoTokenG = unescape(odSsoTokenG);
					var req1:URLRequest= new URLRequest(targetUrl);
					req1.method=URLRequestMethod.POST;
					req1.followRedirects=false;
					//req1.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0";			
					req1.useCache=false;
					var params:URLVariables = new URLVariables();
					params["command"] = "ssologin";
					params["ssoid"] = "JD";
					params["odSsoTokenG"] = odSsoTokenG;
					req1.data=params;
					var loader1:URLLoader=new URLLoader();
					loader1.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void{
						doGetSessionId(pref,successHandler,errorHandler,e,isTestLogin);
					});
					loader1.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void {					
						errorHandler(e);
					});
					loader1.load(req1);
				}
			});	
			
			
			loader.load(req);
		}
		
		
		private static function invokeURLAndParse(pref:Object,successHandler:Function,errorHandler:Function,isTestLogin:Boolean,loginUrl:String,targetUrl:String):void{
			
			
			var req:URLRequest=new URLRequest(loginUrl);
			req.method=URLRequestMethod.GET;
			req.followRedirects=true;
			
			req.useCache=true;
			//req.userAgent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1";
			
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
				errorHandler(e);
			});			
			loader.addEventListener(Event.COMPLETE,	function(e:Event):void{
				
				var body:String = URLLoader(e.target).data;
				postParse(body,pref,successHandler,errorHandler,isTestLogin,targetUrl);
				
			});
			loader.load(req);	
			
			
		}
		
		private static function htmlUnescape(str:String):String
		{
			try{
				var xml:XML =new XML("<convert value='"+str+"'/>");
				return xml.@value;
			}catch(e:Error){
				//cannot convert html element
				
			}
			return str;
			
		}
		
		private static function doGetSessionId(pref:Object,successHandler:Function,errorHandler:Function,e:HTTPStatusEvent,isTestLogin:Boolean):void{
						
			var locationUrl:String = getHeaderValue(e.responseHeaders,"Location");
			
			if(locationUrl==''){
				errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,"INVALID_USER_PASSWORD"));;
				return;
			}
			
			var req:URLRequest=new URLRequest(locationUrl);
			req.method=URLRequestMethod.GET;
			//req.userAgent = "Mozilla/6.0 (Windows NT 6.2; WOW64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1";
			req.useCache=false;
			
			var loader:URLLoader=new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR,function(e:IOErrorEvent):void{
				errorHandler(e);
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,function(e:HTTPStatusEvent):void {				
				doExecute(successHandler,errorHandler,e,isTestLogin);					
			});			
			loader.load(req);
			
			
		}
		
		
		private static function getValue(body:String,startStr:String,endStr:String):String{
			//			var startStr:String="NAME=\"refid\"";
			var startInd:int = body.indexOf(startStr);		
			if(startInd==-1){
				return "";
			}
			startInd= startInd+ startStr.length;
			var endInd:int=body.indexOf(endStr,startInd);
			var tempRefid:String = body.substring(startInd,endInd);				
			return tempRefid;
		}
		
		private static function doExecute(successHandler:Function,errorHandler:Function,e:HTTPStatusEvent,isTestLogin:Boolean=false ):void{
			if(e.status==200){				
				var headers:Array=e.responseHeaders;
				var loginUrl:String='';
				for each(var rHeader:URLRequestHeader in headers){
					if(rHeader.name=='Set-Cookie' && rHeader.value.indexOf("JSESSIONID") != -1){
						sessionId=rHeader.value.split(';')[0];
						break;
					}
				}
				if(sessionId!=null && sessionId!=''){
					successHandler(sessionId);
				}
				if(isTestLogin){
					resetSession();
				}
				
				
				
			}else{
				errorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR,false,false,e.toString()));
			}
			
		}
		
		
	}
}