package gadget.dao
{
	import com.hurlant.crypto.Crypto;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.i18n.i18n;
	import gadget.service.UserService;
	import gadget.util.CacheUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	public class PreferencesDAO extends BaseSQL {
		
		private var stmtRead:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtGetAll:SQLStatement;
		public static const ENABLE_APPLICATION_UPDATE:String = "enable_application_update";
		public static const ENABLE_DASHBOARD:String = "enable_dashboard";
		public static const ENABLE_CUSTOM_LAYOUT:String = "enable_custom_layout";
		public static const ENABLE_LIST_LAYOUT:String = "enable_list_layout";
		public static const ENABLE_VIEW_LAYOUT:String = "enable_view_layout";
		public static const ENABLE_FILTER:String = "enable_filter";
		public static const ENABLE_CONNECTION_INFORMATION:String = "enable_connection_information";
		public static const ENABLE_TRANSACTION:String = "enable_transaction";
		public static const ENABLE_USER_INTERFACE:String = "enable_user_interface";
		public static const ENABLE_OPTION:String = "enable_option";
		public static const ENABLE_AUTO_CONFIGURATION:String = "enable_auto_configuration";
		public static const ENABLE_HOME_TASK:String = "enable_home_task";
		public static const ENABLE_MISSING_PDF:String = "enable_missing_pdf";
		public static const DISABLE_EXPORT_PDF_BUTTON:String = "disable_export_pdf_button";
		public static const PDF_LOGO:String = "pdf_logo";
		public static const PDF_HEADER:String = "pdf_header";
		public static const WINDOW_LOGO:String = "window_logo";
		public static const BACKGROUND_COLOR:String = "background_color";
		public static const DISABLE_CUSTOM_LAYOUT:String = "disable_custom_layout";
		public static const HIDE_USER_INTERFACE:String = "hide_user_interface";
		public static const DISABLE_SYNCHRONIZATION_INTERVAL:String = "disable_synchronization_interval";
		public static const DISABLE_CRM_ONDEMAND_URL:String = "disable_crm_ondemand_url";
		public static const USER_SIGNATURE:String = "user_signature";
		public static const HIDE_USER_SIGNATURE:String = "hide_user_signature";
		public static const HIDE_TASK_LIST:String = "hide_task_list";
		public static const ENABLE_SR_SYNC_ORDER_STATUS:String = "enable_sr_sync_order_status";
		public static const DISABLE_PDF_CVS_EXPORT:String = "disable_pdf_cvs_export";
		public static const FRAME_RATE:String="frame_rate";
		public static const ENABLE_CHECK_CONFLICTS:String="enable_check_conflict";
		//public static const ACCOUNT_DELETE:String = "account_delete";
		//public static const CONTACT_DELETE:String = "contact_delete";
		//public static const LEAD_DELETE:String = "lead_delete";
		//public static const OPPORTUNITY_DELETE:String = "opportunity_delete";
		//public static const DISABLE_AUTORIZE_DELETION:String = "disable_authorize_deletion";
		public static const SYNC_ROLE_SERVICE:String = "sync_role_service";
		public static const SYNC_ACCESS_PROFIL:String = "sync_access_profil";
		public static const PDF_SIZE:String ="pdf_size";
		public static const ENABLE_BUTTON_ACTIVITY_CREATE_CALL:String = "enable_button_activity_create_call";
		public static const UPDATE_URL:String = "update_url";
		public static const START_AT_LOGIN:String = "start_at_login";	
		public static const ENABLE_FAVORITE:String = "enable_favorite";
		public static const ENABLE_IMPORTANT:String = "enable_important";
		public static const ENABLE_FUZZY:String = "enable_fuzzy";
		public static const ENABLE_CONVERT_LAED:String = "enable_convert_lead";
		public static const HIDE_TECH_USER:String = "hide_sso_tech_user";
		public static const ENABLE_FACEBOOK:String = "enable_facebook";
		public static const ENABLE_LINKEDIN:String = "enable_linkedin";
		
		public static const ENABLE_FEED:String = "enable_feed";
		public static const ENABLE_DAILY_AGENDA:String = "enable_daily_agenda";
		
		public static const FEED_URL:String = "feed_url";
		public static const FEED_PORT:String = "feed_port";
		public static const AUTHOR:String = "";
	    
		import gadget.util.TableFactory;
		
		public function PreferencesDAO(sqlConnection:SQLConnection) {
			
			// perhaps get this rid in favor of GadgetDAO?

			// NO, THIS IS NOT YET THE RIGHT THING
			// But this hack is needed to get the app started
			TableFactory.create(function (text:String, fn:Function, args:Object=null):void { fn(args); },
				sqlConnection, {
					table: "prefs",
					unique: [ 'key' ],
					columns: {
						key:"TEXT",
						value:"TEXT"
					}
				});
			
			stmtRead = new SQLStatement();
			stmtRead.sqlConnection = sqlConnection;
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			
			stmtGetAll = new SQLStatement();
			stmtGetAll.sqlConnection = sqlConnection;
			stmtGetAll.text = "SELECT * FROM prefs";
		}
		
		public var fieldsCrypt:Object = {
			"ms_password":"ms_password",
			"im_password":"im_password",
			"gmail_password":"gmail_password",
			"tech_password":"tech_password",
			"sodpass":"sodpass"
		}
		
		// CH 09.05.2011
		private var fields:Array = [
			"ms_exchange_enable",
			"ms_url", 
			"ms_user", 
			"ms_password", 
			"sodhost", 
			"sodlogin",
			"sodpass",
			"last_sync",
			"config_url",
			"interface_style",
			"sync_startup",
			"disable_gzip",
			"verbose", 
			"syn_interval",
			"im_room_url",
			"im_protocol",
			"im_user",
			"im_password",
			"im_auto_sing_in",
			"editableList",
			"showDebug",
			"netbreeze_tab",
			"log_files",
			"log_fileName",
			"use_sso", 
			"usegzip",
			"company_sso_id", 
			"pdf_Page_Size",
			"window_resize",
			"gmail_username",
			"gmail_password",
			"tech_username",
			"tech_password",
			"cvs_separator", 
			"tcs_closing_enable",
			"important_length",
			"recent_filter",
			ENABLE_FAVORITE,
			ENABLE_IMPORTANT,
			ENABLE_FUZZY,
		    HIDE_TECH_USER,
			ENABLE_CONVERT_LAED,
			ENABLE_HOME_TASK,
			ENABLE_CUSTOM_LAYOUT,
			ENABLE_LIST_LAYOUT,
			ENABLE_VIEW_LAYOUT,
			ENABLE_FILTER,
			ENABLE_CONNECTION_INFORMATION,
			ENABLE_TRANSACTION,
			ENABLE_USER_INTERFACE,
			ENABLE_OPTION,
			ENABLE_AUTO_CONFIGURATION,
			ENABLE_FACEBOOK,
			ENABLE_LINKEDIN,
			ENABLE_FEED,
			ENABLE_DASHBOARD,
			ENABLE_DAILY_AGENDA,
			FEED_URL,
			FEED_PORT,
			ENABLE_APPLICATION_UPDATE
		];
		
		public function update(preferences:Object):void
		{
			// CH 09.05.2011
			for each(var field:String in fields){
				setValue(field, preferences[field]);
			}
			setValue(BACKGROUND_COLOR, preferences.background_color);
			setValue(ENABLE_CHECK_CONFLICTS,preferences.enable_check_conflict);
			setValue(FRAME_RATE,preferences.frame_rate);
			
			setValue("enable_google_calendar",preferences.enable_google_calendar);
			setValue(START_AT_LOGIN,preferences.start_at_login);
			
			// CH 09.05.2011
			// bug sso
			if(preferences.enabled_technical_user){
				setValue("enabled_technical_user", preferences.enabled_technical_user);
			}else{
				setValue("enabled_technical_user", 1);
			}
			
			//setValue("parallel_processing",preferences.parallel_processing);
			//---------------------------
		}
		
		public function updateAcceptedLicense(accepted_license:Boolean):void
		{
			setValue("accepted_license", accepted_license);
		}
				
		public function read():Object
		{
			var object:Object = new Object();
			
			// CH 09.05.2011
			for each(var field:String in fields){
				object[field] = getValue(field);			
				
				
			}
			
			object.accepted_license = getValue("accepted_license");
			
			object.background_color = getValue(BACKGROUND_COLOR);
			
			//object.parallel_processing=getValue("parallel_processing");
			object.window_width=getValue("window_width");
			object.window_height=getValue("window_height");
			
			object.frame_rate = getValue(FRAME_RATE);
			object.enable_check_conflict=getValue(ENABLE_CHECK_CONFLICTS);
			
			object.google_calendar_tab = getValue("enable_google_calendar");
			object.start_at_login = getValue(START_AT_LOGIN);
			
			// CH 09.05.2011
			object.enabled_technical_user = getValue("enabled_technical_user", null);
			//---------------------------
			Utils.suppressWarning(new ArrayCollection([object]));
			return object;
		}
		
		public function getValue(key:String, defaultValue:Object=""):Object {
			
			var cache:CacheUtils = new CacheUtils("Preferences_DAO");
			var objectPref:Object = cache.get(key); 
			if(objectPref==null){
				stmtRead.text = "SELECT * FROM prefs WHERE key = :key";
				stmtRead.parameters[":key"] = key;
				exec(stmtRead);
				var result:SQLResult = stmtRead.getResult();
				if(result.data==null || result.data.length==0){
					return defaultValue;
				}
				objectPref = result.data[0].value ? result.data[0].value : defaultValue
				
				if(fieldsCrypt[key]!=null){
					try{
						objectPref = Utils.decryptPassword(objectPref.toString());
					}catch(e:Error){
						//ignore 
					}
					
				}	
					
					
				cache.set(key, objectPref);
			}
			return objectPref;
		}
		//VAHI added
		public function getStrValue(key:String, defaultValue:String=""):String {
			return getValue(key,defaultValue).toString();
		}
		//VAHI added
		public function getIntValue(key:String, defaultValue:int=0):int {
			return parseInt(getStrValue(key,defaultValue.toString()));
		}
		
		public function getBooleanValue(key:String, defaultValue:int=0):Boolean {
			if(getIntValue(key,defaultValue)==1) return true;
			return false;
		}
		
		
		public static function enableSyncSRStatus():Boolean{
			return Database.preferencesDao.getBooleanValue(ENABLE_SR_SYNC_ORDER_STATUS);
		}
		
		public function setValue(key:String, value:Object,isEncrypt:Boolean = true):void{
			//VAHI changed such that adding preferences using XML works
			var encryptValue:Object = value;
			if(fieldsCrypt[key]!=null ){
				try{
					if(isEncrypt){
						encryptValue = Utils.encryptPassword(value.toString());
					}else{
						value = Utils.decryptPassword(value.toString());
					}
					
				}catch(e:Error){
					//nothing to do
				}
				
			}
			
			
			stmtUpdate.text = "INSERT OR REPLACE INTO prefs ( key, value ) VALUES ( :key, :value )";
			stmtUpdate.parameters[":key"] = key;
			stmtUpdate.parameters[":value"] = encryptValue;
			exec(stmtUpdate);
			var cache:CacheUtils = new CacheUtils("Preferences_DAO");
			cache.set(key, value);
			
		}
		
		public function getCompanyName():String {
			return getStrValue("company_name", UserService.UNKNOWN);
		}
		
		public function isUsedSSO():Boolean{
			return getBooleanValue("use_sso");
		}
		public function getTechUserSignInId():String{
				return getStrValue("tech_username");
		}
		
		public function isEnableFavorite():Boolean{
			return getBooleanValue(ENABLE_FAVORITE);
		}
		
		public function isEanableImportant():Boolean{
			return getBooleanValue(ENABLE_IMPORTANT);
		}
		public function isEanableFuzzy():Boolean{
			return getBooleanValue(ENABLE_FUZZY);
		}
		public function isHideSSOTechUser():Boolean{
			return getBooleanValue(HIDE_TECH_USER);
		}
		public function isEanableConvertLead():Boolean{
			return getBooleanValue(ENABLE_CONVERT_LAED);
		}
		public function isEanableHomeTask():Boolean{
			return getBooleanValue(ENABLE_HOME_TASK);
		}
		public function getPrefs(isDecrypt:Boolean=true):ArrayCollection{
			exec(stmtGetAll);
			var result:ArrayCollection =new ArrayCollection(stmtGetAll.getResult().data); 
			if(isDecrypt){
				for each(var obj:Object in result){
					if(fieldsCrypt[obj.key]!=null){
						try{
							obj.value = Utils.decryptPassword(obj.value);
						}catch(e:Error){
							//nothing to do
						}
						
					}
				}		
			}			
			
			return result;
		}

	
	}
}
