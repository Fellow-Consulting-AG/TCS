package gadget.util {

	import com.adobe.utils.StringUtil;
	
	import flash.display.DisplayObject;
	
	import flashx.textLayout.operations.PasteOperation;
	
	import gadget.control.AutoComplete;
	import gadget.control.GoogleLocalSearchAddress;
	import gadget.control.ImageTextInput;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.i18n.i18n;
	import gadget.service.LocaleService;
	import gadget.service.SupportService;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.DateField;
	import mx.controls.TextInput;
	import mx.formatters.DateFormatter;
	import mx.validators.EmailValidator;
	import mx.validators.NumberValidator;
	import mx.validators.StringValidator;
	import mx.validators.Validator;
	
	public class FieldUtils {
		
		private static var _cache:CacheUtils = new CacheUtils("field");
		private static var _cache_customField:CacheUtils = new CacheUtils("customField");
		
		private static const MILLIS_PER_DAY:int = 1000*60*60*24;
		
		// entity is the CG internal transaction name (e. h. AllUsers)
		// If you use this, be sure to NOT to alter the returned object!
		public static function allFields(entity:String, alwaysRead:Boolean = false, customField:Boolean = false):ArrayCollection {
			// hardcoded for Modification Tracking
			if (entity == "ModificationTracking") {
				return new ArrayCollection([
					{element_name:"ChildId"},
					{element_name:"ChildName"},
					{element_name:"CreatedBy"},
					{element_name:"CreatedByAlias"},
					{element_name:"CreatedByEMailAddr"},
					{element_name:"CreatedByExternalSystemId"},
					{element_name:"CreatedByFirstName"},
					{element_name:"CreatedByFullName"},
					{element_name:"CreatedById"},
					{element_name:"CreatedByIntegrationId"},
					{element_name:"CreatedByLastName"},
					{element_name:"CreatedByUserSignInId"},
					{element_name:"CreatedDate"},
					{element_name:"EventName"},
					{element_name:"ExternalSystemId"},
					{element_name:"Id"},
					{element_name:"ModId"},
					{element_name:"ModificationNumber"},
					{element_name:"ModifiedBy"},
					{element_name:"ModifiedById"},
					{element_name:"ModifiedDate"},
					{element_name:"ObjectId"},
					{element_name:"ObjectName"},
					{element_name:"UpdatedByAlias"},
					{element_name:"UpdatedByEMailAddr"},
					{element_name:"UpdatedByExternalSystemId"},
					{element_name:"UpdatedByFirstName"},
					{element_name:"UpdatedByFullName"},
					{element_name:"UpdatedByIntegrationId"},
					{element_name:"UpdatedByLastName"},
					{element_name:"UpdatedByUserSignInId"}
				]);
			}else if (entity == "Address") {
					return new ArrayCollection([
						{element_name:"Id"},
						{element_name:"ModifiedBy"},
						{element_name:"ExternalSystemId"},
						{element_name:"CreatedBy"},
						{element_name:"CreatedDate"},
						{element_name:"ModId"},
						{element_name:"City"},
						{element_name:"Country"},
						{element_name:"County"},
						{element_name:"Description"},
						{element_name:"IntegrationId"},
						{element_name:"ZipCode"},
						{element_name:"Province"},
						{element_name:"StateProvince"},
						{element_name:"Address"},
						{element_name:"StreetAddress2"},
						{element_name:"StreetAddress3"},
						{element_name:"ModifiedById"},
						{element_name:"CreatedById"}
					]);
				
			}
			if(StringUtils.isEmpty(entity))
				return new ArrayCollection();
			if (alwaysRead) {
				_cache.unset(entity);
			}
			var fields:ArrayCollection = _cache.get(entity) as ArrayCollection;
			if (fields == null) {
				if (entity.indexOf(".")>0) {
					fields = SupportService.getFields(entity);
				} else {
					
					//-- VM -- error when type select table not found 
					var sod:SodUtilsTAO = SodUtils.transactionProperty(entity);
					if(sod != null)
						var entityName:String = sod.sod_name;
						if(sod.our_name==Database.medEdDao.entity){
							entityName=sod.our_name;
						}		
						fields = Database.fieldDao.listFields(entityName);
				}
				
					
				if (fields != null && fields.length > 2) {
					_cache.put(entity, fields);
				}
			}
			
			
			// include custom field
			if(customField){
				var customFields:ArrayCollection = _cache_customField.get(entity) as ArrayCollection;
				if(customFields==null){
					customFields = new ArrayCollection();
					customFields.addAll(fields);
					var customfieldList:ArrayCollection = Database.customFieldDao.selectCustomFields(entity);
					if(customfieldList.length>0)
						customFields.addAll(customfieldList);
					if (customFields != null && customFields.length > 2) {
						_cache_customField.put(entity, customFields);
					}
				}
				return customFields;
			}
			
			return fields; 
		}
		
		public static function getIndexFieldItemRenderer(layoutObject:Object):int{
			var fieldInfo:Object = FieldUtils.getField(layoutObject.entity, layoutObject.column_name);
			if(fieldInfo==null){
				return 6;
			}
			switch (fieldInfo.data_type) {
				case "Text (Short)":
				case "Text (Long)":
				case "Phone":
				case "Number":
				case "Currency":
				case "Integer": 
					return 1
				case "Date/Time":
					return 2;
				case 'Picklist': return 3;
				case 'Checkbox': return 4;
				case 'Picture':
				case '{GOOGLEMAP}': return 5;
				case 'Percent': return 12;
			}
			return 6;
		}
		
		
		public static function reset():void {
			_cache.clear();
		}
 
		public static const ACTIVITY_DEFAULT_DAILY_AGENDA:ArrayCollection = new ArrayCollection([
			{element_name:"StartTime", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_STARTTIME)},
			{element_name:"EndTime", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_ENDTIME)},
			{element_name:"Location", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_LOCATION)},
			{element_name:"Description", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_NOTE)}
		]);
		
		public static const ACCOUNT_DEFAULT_DAILY_AGENDA:ArrayCollection = new ArrayCollection([
			{element_name:"AccountName", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_ACCOUNT_NAME)},
			{element_name:"AccountType", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_ACCOUNT_TYPE)},
			{element_name:"AnnualRevenues", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_ANNUAL_REVENUES)},
			{element_name:"Location", display_name:i18n._(DailyAgenda.DAILYAGENDA_LABEL_LOCATION)},
			{element_name:"IndexedShortText1", display_name:i18n._('Account Number')},
			{element_name:"PrimaryBillToStreetAddress", display_name:i18n._('Main Address')},
			{element_name:"PrimaryBillToCity", display_name:i18n._('Main City')}
		]);
		
		public static const CONTACT_DEFAULT_DAILY_AGENDA:ArrayCollection = new ArrayCollection([
			{element_name:"ContactLastName", display_name:i18n._('GLOBAL_FIRST_NAME')},
			{element_name:"ContactFirstName", display_name:i18n._('GLOBAL_LAST_NAME')},
			{element_name:"CellularPhone", display_name:i18n._('Mobile Phone #')}		
		]);
		
		public static const DEFAULT_MAP_FIELD_CONTACT:ArrayCollection = new ArrayCollection([
			{element_name:"ContactFirstName"},
			{element_name:"ContactLastName"}
			]);
		
		private static const DEFAULT_ACCOUNT:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"}, 
			{col:0, row:1, column_name:"AccountName"}, 
			{col:0, row:2, column_name:"MainPhone"}, 
			{col:0, row:3, column_name:"MainFax"}, 
			{col:0, row:4, column_name:"WebSite"}, 
			{col:0, row:5, column_name:"OwnerFullName"}, 
			{col:1, row:0, column_name:"#1", custom:"Sales Information"}, 
			{col:1, row:1, column_name:"AccountType"}, 
			{col:1, row:2, column_name:"Priority"}, 
			{col:1, row:3, column_name:"Industry"}, 
			{col:1, row:4, column_name:"PublicCompany"}, 
			{col:1, row:5, column_name:"AnnualRevenues"}, 
			{col:1, row:6, column_name:"NumberEmployees"}, 
			{col:1, row:7, column_name:"PrimaryContactFullName"},
			{col:0, row:6, column_name:"#2", custom:"Address Information"}, 
			{col:0, row:7, column_name:"PrimaryBillToStreetAddress"}, 
			{col:0, row:8, column_name:"PrimaryBillToPostalCode"}, 
			{col:0, row:9, column_name:"PrimaryBillToCity"}, 
			{col:0, row:10, column_name:"PrimaryBillToCountry"}]; 

  
			
		private static const DEFAULT_CONTACT:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"ContactFirstName"}, 
			{col:0, row:2, column_name:"MiddleName"}, 
			{col:0, row:3, column_name:"ContactLastName"}, 
			{col:0, row:4, column_name:"AccountName"}, 
			{col:0, row:5, column_name:"JobTitle"}, 
			{col:0, row:6, column_name:"WorkPhone"}, 
			{col:0, row:7, column_name:"WorkFax"}, 
			{col:0, row:8, column_name:"ContactEmail"},
			{col:0, row:9, column_name:"OwnerFullName"},
			{col:0, row:10, column_name:"#1", custom:"Detail Information"},
			{col:0, row:11, column_name:"ContactType"}, 
			{col:0, row:12, column_name:"Department"}, 
			{col:0, row:13, column_name:"Manager"}, 
			{col:0, row:14, column_name:"LeadSource"},
			{col:0, row:15, column_name:"CurrencyCode"},
			{col:0, row:16, column_name:"AssistantName"},
			{col:1, row:0, column_name:"#2", custom:"Photo"},
			{col:1, row:1, column_name:"picture"},
			{col:1, row:2, column_name:"#3", custom:"Address Information"},
			{col:1, row:3, column_name:"AlternateAddress1"},
			{col:1, row:4, column_name:"AlternateZipCode"},
			{col:1, row:5, column_name:"AlternateCity"},
			{col:1, row:6, column_name:"AlternateCountry"}
			];



		
		private static const DEFAULT_ACTIVITY:Array = [
			// subtype 0 : task
			{col:0, row:0, subtype:0, column_name:"Subject"}, 
			{col:0, row:1, subtype:0, column_name:"Priority"}, 
			{col:0, row:2, subtype:0, column_name:"DueDate"}, 
			{col:0, row:3, subtype:0, column_name:"Type"}, 
			{col:0, row:4, subtype:0, column_name:"Status"}, 
			{col:0, row:5, subtype:0, column_name:"Private"}, 
			{col:0, row:6, subtype:0, column_name:"Description"},
			// subtype 1 : appointment
			{col:0, row:0, subtype:1, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, subtype:1, column_name:"Subject"},
			{col:0, row:2, subtype:1, column_name:"Type"}, 
			{col:0, row:3, subtype:1, column_name:"StartTime"},
			{col:0, row:4, subtype:1, column_name:"EndTime"},
			{col:0, row:5, subtype:1, column_name:"Location"},
			{col:0, row:6, subtype:1, column_name:"Private"}, 
			{col:0, row:7, subtype:1, column_name:"Description"},
			{col:1, row:0, subtype:1, column_name:"#1", custom:"Related Items"},
			{col:1, row:1, subtype:1, column_name:"AccountName"},
			{col:1, row:2, subtype:1, column_name:"PrimaryContact"},
			{col:1, row:3, subtype:1, column_name:"OpportunityName"},
			{col:1, row:4, subtype:1, column_name:"Lead"},
			{col:1, row:5, subtype:1, column_name:"CampaignName"},
			{col:1, row:6, subtype:1, column_name:"ServiceRequestNumber"},
			// subtype 2 : call
			{col:0, row:0, subtype:2, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, subtype:2, column_name:"Subject"},
			{col:0, row:2, subtype:2, column_name:"PrimaryContact"},
			{col:0, row:3, subtype:2, column_name:"AccountName"},
			{col:0, row:4, subtype:2, column_name:"SmartCall"},
			{col:0, row:5, subtype:2, column_name:"Status"},
			{col:0, row:6, subtype:2, column_name:"CurrencyCode"},
			{col:0, row:7, subtype:2, column_name:"Objective"},
			{col:0, row:8, subtype:2, column_name:"StartTime"},
			{col:0, row:9, subtype:2, column_name:"Duration"},
			{col:0, row:10, subtype:2, column_name:"EndTime"},
			{col:1, row:0, subtype:2, column_name:"#1", custom:"Additional Information"},
			{col:1, row:1, subtype:2, column_name:"PaperSign"},
			{col:1, row:2, subtype:2, column_name:"Private"},
			{col:1, row:3, subtype:2, column_name:"Description"},
			{col:1, row:4, subtype:2, column_name:"NextCall"},
			{col:1, row:5, subtype:2, column_name:"#2", custom:"Product"}
			
		];
		



		private static const DEFAULT_OPPORTUNITY:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"OpportunityName"},
			{col:0, row:2, column_name:"AccountName"},  
			{col:0, row:3, column_name:"CloseDate"}, 
			{col:0, row:4, column_name:"Revenue"}, 
			{col:0, row:5, column_name:"SalesStage"}, 
			{col:0, row:6, column_name:"Forecast"},
			{col:0, row:7, column_name:"NextStep"},
			{col:0, row:8, column_name:"CurrencyCode"},
			{col:0, row:9, column_name:"OwnerFullName"},
			{col:1, row:0, column_name:"#1", custom:"Sales information"},
			{col:1, row:1, column_name:"Status"},
			{col:1, row:2, column_name:"Priority"},
			{col:1, row:3, column_name:"LeadSource"},
			{col:1, row:4, column_name:"Probability"},
			{col:1, row:5, column_name:"ReasonWonLost"},
			{col:1, row:6, column_name:"OpportunityType"}
		];
		
		
		private static const DEFAULT_PRODUCT:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"ProductType"}, 
			{col:0, row:3, column_name:"ProductCategory"}, 
			{col:0, row:4, column_name:"ProductCurrency"}, 
			{col:0, row:5, column_name:"Status"},
			{col:0, row:6, column_name:"PartNumber"},
			{col:1, row:0, column_name:"#1", custom:"Sales information"},
			{col:1, row:1, column_name:"PriceType"},
			{col:1, row:2, column_name:"Model"},
			{col:1, row:3, column_name:"Orderable"},
			{col:1, row:4, column_name:"Make"},
			{col:1, row:5, column_name:"Description"}
		];
		
		
		private static const DEFAULT_SERVICE:Array = [
			{col:0, row:0, column_name:"#0", custom:"Contact Information"},
			{col:0, row:1, column_name:"SRNumber"},
			{col:0, row:2, column_name:"AccountName"},   
			{col:0, row:3, column_name:"WorkPhone"}, 
			{col:0, row:4, column_name:"#1", custom:"Service Detail Information:"},
			{col:0, row:5, column_name:"Area"},
			{col:0, row:6, column_name:"Cause"},
			{col:0, row:7, column_name:"Type"},
			{col:0, row:8, column_name:"Source"},
			{col:0, row:9, column_name:"Priority"},
			{col:0, row:10, column_name:"Status"},
			{col:0, row:11, column_name:"OpenedTime"},
			{col:1, row:0, column_name:"#1", custom:"Additional Information"},
			{col:1, row:1, column_name:"Subject"},
			{col:1, row:2, column_name:"Description"}
		];
		
		private static const DEFAULT_CAMPAIGN:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"SourceCode"}, 
			{col:0, row:2, column_name:"CampaignName"}, 
			{col:0, row:3, column_name:"CampaignType"},
			{col:0, row:4, column_name:"Objective"},
			{col:0, row:5, column_name:"Audience"},
			{col:0, row:6, column_name:"Offer"},
			{col:0, row:7, column_name:"Status"},
			{col:0, row:8, column_name:"StartDate"},
			{col:0, row:9, column_name:"EndDate"},
			{col:1, row:0, column_name:"#1", custom:"Campaign Plan Information"},
			{col:1, row:1, column_name:"RevenueTarget"},
			{col:1, row:2, column_name:"BudgetedCost"},
			{col:1, row:3, column_name:"ActualCost"},
			{col:2, row:0, column_name:"#2", custom:"Additional Information"},
			{col:2, row:1, column_name:"Description"}
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_1:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_LEAD:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"MrMrs"}, 
			{col:0, row:2, column_name:"LeadFirstName"}, 
			{col:0, row:3, column_name:"LeadLastName"}, 
			{col:0, row:4, column_name:"Company"}, 
			{col:0, row:5, column_name:"JobTitle"}, 
			{col:0, row:6, column_name:"PrimaryPhone"}, 
			{col:0, row:7, column_name:"CellularPhone"}, 
			{col:0, row:8, column_name:"FaxPhone"},
			{col:0, row:9, column_name:"LeadEmail"},
			{col:0, row:10, column_name:"NeverEmail"}
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_2:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		private static const DEFAULT_CUSTOM_OBJECT_3:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		private static const DEFAULT_CUSTOM_OBJECT_7:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];

		private static const DEFAULT_CUSTOM_OBJECT_14:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_4:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_5:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_6:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_8:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_9:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_CUSTOM_OBJECT_10:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_ASSET:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Product"},
			{col:0, row:2, column_name:"PurchaseDate"},
			{col:0, row:3, column_name:"PurchasePrice"},
			{col:0, row:4, column_name:"Quantity"},
			{col:0, row:5, column_name:"ShipDate"},
			{col:0, row:6, column_name:"ProductCategory"},
			{col:0, row:7, column_name:"Type"},
			{col:0, row:8, column_name:"Status"},
			{col:0, row:9, column_name:"Warranty"},
			{col:0, row:10, column_name:"Contract"}
		];
		private static const DEFAULT_TERRITORY:Array = [
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"TerritoryName"}, 
			{col:0, row:2, column_name:"Description"} 
		];
		
		private static const DEFAULT_NOTE:Array =[
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Subject"}, 
			{col:0, row:2, column_name:"Note"} 
		];
		
		private static const DEFAULT_MEDED:Array =[
			{col:0, row:0, column_name:"#0", custom:"Key Information"},
			{col:0, row:1, column_name:"Name"}, 
			{col:0, row:2, column_name:"Location"}, 
			{col:0, row:3, column_name:"StartDate"},
			{col:0, row:4, column_name:"EndDate"},
			{col:0, row:5, column_name:"Objective"}
		];
		// Entity is the CG internal transaction name
		public static function getField(entity:String, column_name:String,changeElementName:Boolean=false,sqlCustomField:Boolean=false):Object {

			var field:Object = null;
			if (column_name == 'picture') {
				field = new Object();
				field.entity = entity;
				field.element_name = 'picture';
				field.display_name = 'Picture';
				field.data_type = 'Picture';
				return field;
			}else if(column_name == '{' + CustomLayout.GOOGLEMAP_CODE + '}'){
				field = new Object();
				field.entity = entity;
				field.element_name = '{' + CustomLayout.GOOGLEMAP_CODE + '}';
				field.display_name = 'Google Map';
				field.data_type = '{' + CustomLayout.GOOGLEMAP_CODE + '}';
				return field;	
			}else {
				var fields:ArrayCollection = null;
				var isCustomField:Boolean = false;
				if(sqlCustomField || column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
					fields = Database.customFieldDao.customField(entity,LocaleService.getLanguageInfo().LanguageCode);
					isCustomField = true;
				}else{
					fields = allFields(entity);
				}
				if (fields != null) {
					for each (var tmp:Object in fields) {
						var elementName:String = isCustomField?tmp.column_name:tmp.element_name;
						if(sqlCustomField) elementName = tmp.fieldName;
						if (elementName == column_name){ // || (sqlCustomField && column_name == tmp.fieldName)) {
							// we must create a new object and not modify the value in the cache
							field = new Object();
							field.entity = tmp.entity;
							field.element_name = changeElementName?tmp.fieldName:elementName;
							field.display_name = isCustomField?tmp.displayName:tmp.display_name;
							field.data_type = isCustomField?tmp.fieldType:tmp.data_type;
							field.data_type = (field.data_type as String).replace("Related Picklist","Picklist");
							var isFormulaImage:Boolean = false;
							if(tmp.hasOwnProperty("value")) isFormulaImage = (tmp.value != null && (tmp.value as String).indexOf("Image(")) > -1 ? true : false;
							if(isFormulaImage) field.fieldImage = field.element_name;							
							break;
						} 
					}
				}
			}
			// set required fields
			if (field != null) {
				if( getDefaultMandatory(entity,column_name) ){
					field.required = true;
				}
			} 
			return field;
		}		
		
		public static function getDefaultMandatory(entity:String, column_name:String):Boolean {
			if ((entity == 'Account' && column_name == 'AccountName')
				|| (entity == 'Contact' && (column_name == 'ContactFirstName' || column_name == 'ContactLastName'))
				|| (entity == 'Opportunity' && (column_name == 'OpportunityName' || column_name == 'SalesStage' || column_name == 'CloseDate'))
				|| (entity == 'Activity' && (column_name == 'Subject' || column_name == 'DueDate' || column_name == 'Priority'))
				|| (entity == 'Product' && column_name== 'Name')
				|| (entity == 'Campaign' && (column_name == 'SourceCode' || column_name == 'CampaignName'))
				|| (entity == 'Service Request' && column_name == 'SRNumber')
				|| (entity == 'Lead' && (column_name == 'LeadFirstName' || column_name == 'LeadLastName'))
				|| (entity == 'Custom Object 1' && column_name == 'Name')
				|| (entity == 'Custom Object 2' && column_name == 'Name')
				|| (entity == 'Custom Object 3' && column_name == 'Name')
				|| (entity == 'CustomObject14' && column_name == 'Name')
				|| (entity == 'CustomObject7' && column_name == 'Name')
				|| (entity == 'Asset' && column_name == 'Product')
				|| (entity == 'Territory' && column_name == 'TerritoryName')
				|| (entity == 'Note' && column_name == 'Subject') 
				|| (entity == 'MedEdEvent' && (column_name == 'Name' || column_name == 'StartDate' || column_name == 'EndDate' || column_name == 'Objective'))
			)  return true;
			
			if(entity.indexOf(".") != -1) {
				var results:Array = Database.fieldManagementServiceDao.getDefaultFieldValue(
					DAOUtils.getRecordType(entity),
					column_name);
				if (results && results[0].Required == "true") return true;
			}
			
			return false;
		}
		
		public static function getDefaultFields(entity:String):Array {
			switch (entity) {
				case 'Account' : return DEFAULT_ACCOUNT; 
				case 'Contact' : return DEFAULT_CONTACT;
				case 'Activity' : return DEFAULT_ACTIVITY;
				case 'Opportunity' : return DEFAULT_OPPORTUNITY;
				case 'Product': return DEFAULT_PRODUCT;
				case 'Service Request' : return DEFAULT_SERVICE;
				case 'Campaign' : return DEFAULT_CAMPAIGN;
				case 'Custom Object 1' : return DEFAULT_CUSTOM_OBJECT_1;
				case 'Lead': return DEFAULT_LEAD;
				case 'Custom Object 2' : return DEFAULT_CUSTOM_OBJECT_2;
				case 'Custom Object 3' : return DEFAULT_CUSTOM_OBJECT_3;
				case 'CustomObject7' : return DEFAULT_CUSTOM_OBJECT_7;
				case 'CustomObject14' : return DEFAULT_CUSTOM_OBJECT_14;
				case 'CustomObject4' : return DEFAULT_CUSTOM_OBJECT_4;	
				case 'CustomObject5' : return DEFAULT_CUSTOM_OBJECT_5;	
				case 'CustomObject6' : return DEFAULT_CUSTOM_OBJECT_6;	
				case 'CustomObject8' : return DEFAULT_CUSTOM_OBJECT_8;
				case 'CustomObject9' : return DEFAULT_CUSTOM_OBJECT_9;
				case 'CustomObject10' : return DEFAULT_CUSTOM_OBJECT_10;	
				case 'Asset' : return DEFAULT_ASSET;
				case 'Territory' : return DEFAULT_TERRITORY;
				case 'Note' : return DEFAULT_NOTE;
				case 'MedEdEvent' : return DEFAULT_MEDED;	
			}
			return null;
		}
	
		//private static var defaultFieldAccount:ArrayCollection = new ArrayCollection(["AccountName","PrimaryBillToCity","PrimaryBillToCountry"]);
		//private static var defaultFieldContact:ArrayCollection = new ArrayCollection(["ContactFirstName","ContactLastName","WorkPhone", "ContactEmail"]);
		//private static var defaultFieldOpportunity:ArrayCollection = new ArrayCollection(["OpportunityName", "AccountName", "CloseDate","Revenue", "SalesStage"]);
		//private static var defaultFieldService:ArrayCollection = new ArrayCollection(["SRNumber","OpenedTime","Subject"]);
		private static var defaultFieldAccount:ArrayCollection = new ArrayCollection(["AccountName","Location","Priority","AccountType","Reference","Owner"]);
		private static var defaultFieldContact:ArrayCollection = new ArrayCollection(["ContactFirstName","ContactLastName","AccountName","WorkPhone","CellularPhone", "ContactEmail","Owner","Department"]);
		private static var defaultFieldOpportunity:ArrayCollection = new ArrayCollection(["OpportunityName", "AccountName", "CloseDate","Revenue", "SalesStage","Forecast","Owner"]);
		private static var defaultFieldService:ArrayCollection = new ArrayCollection(["SRNumber","Subject","Priority","Status","OpenedTime","ContactFullName","AccountName","Owner"]);
		
		private static var defaultFieldActivity:ArrayCollection = new ArrayCollection(["Subject", "Activity", "Status", "Priority","DueDate"]);
		private static var defaultFieldProduct:ArrayCollection = new ArrayCollection(["Name","ProductType","Status"]);
		private static var defaultFieldCampaign:ArrayCollection = new ArrayCollection(["SourceCode","CampaignName","Status", "StartDate", "EndDate", "RevenueTarget"]);
		private static var defaultFieldCustomObject1:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldLead:ArrayCollection = new ArrayCollection(["LeadFirstName","LeadLastName","PrimaryPhone"]);
		private static var defaultFieldCustomObject2:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject3:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject7:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject14:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject4:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject5:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject6:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject8:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject9:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldCustomObject10:ArrayCollection = new ArrayCollection(["Name","Description"]);
		private static var defaultFieldAsset:ArrayCollection = new ArrayCollection(["Product","Status","Type"]);
		private static var defaultFieldTerritory:ArrayCollection = new ArrayCollection(["TerritoryName","Description"]);
		private static var defaultFieldNote:ArrayCollection = new ArrayCollection(["Subject","Note"]);
		private static var defaultFieldMedEd:ArrayCollection = new ArrayCollection(["Name","Location","StartDate","EndDate","Objective"]);
		
		public static function getDefaultFieldsObject(entity:String):ArrayCollection {
			switch (entity) {
				case 'Account' : return defaultFieldAccount; 
				case 'Contact' : return defaultFieldContact;
				case 'Activity' : return defaultFieldActivity;
				case 'Opportunity' : return defaultFieldOpportunity;
				case 'Product' : return defaultFieldProduct;
				case 'Service Request' : return defaultFieldService;
				case 'Campaign' : return defaultFieldCampaign;
				case 'Custom Object 1': return defaultFieldCustomObject1;
				case 'Lead' : return defaultFieldLead;
				case 'Custom Object 2': return defaultFieldCustomObject2;
				case 'Custom Object 3': return defaultFieldCustomObject3;
				case 'CustomObject7': return defaultFieldCustomObject7;
				case 'CustomObject14': return defaultFieldCustomObject14;
				case 'CustomObject4': return defaultFieldCustomObject4;	
				case 'CustomObject5': return defaultFieldCustomObject5;	
				case 'CustomObject6': return defaultFieldCustomObject6;
				case 'CustomObject8': return defaultFieldCustomObject8;
				case 'CustomObject9': return defaultFieldCustomObject9;
				case 'CustomObject10': return defaultFieldCustomObject10;	
				case 'Asset': return defaultFieldAsset;
				case 'Territory': return defaultFieldTerritory;
				case 'Note': return defaultFieldNote;
				case 'MedEdEvent': return defaultFieldMedEd;	
			}
			return null;
		}
		
		public static function getFieldsDetail(entity:String):Array{
			switch (entity) {
				case 'Account' : return ["PrimaryBillToStreetAddress|PrimaryBillToPostalCode|PrimaryBillToCity|PrimaryBillToCountry", "MainPhone", "MainFax"]; 
				case 'Contact' : return ["JobTitle", "AlternateAddress1|AlternateZipCode|AlternateCity|AlternateCountry", "WorkPhone", "ContactEmail"];
				case 'Activity' : return ["Priority", "DueDate", "Type", "Status"];
				case 'Opportunity' : return ["CloseDate", "Revenue"];
				case 'Product' : return ["Body", "Category", "Class", "Controlled"];
				case 'Service Request' : return ["Area", "AssetName", "AssignmentStatus", "Cause"];
				case 'Campaign' : return ["SourceCode","Status","RevenueTarget"];
				case 'Custom Object 1' : return ["Description"];
				case 'Lead' : return ["Company","JobTitle","ZipCode","LeadEmail"];
				case 'Custom Object 2' : return ["Description"];
				case 'Custom Object 3' : return ["Description"];
				case 'CustomObject7' : return ["Description"];
				case 'CustomObject14' : return ["Description"];
				case 'CustomObject4' : return ["Description"];	
				case 'CustomObject5' : return ["Description"];
				case 'CustomObject6' : return ["Description"];
				case 'CustomObject8' : return ["Description"];
				case 'CustomObject9' : return ["Description"];
				case 'CustomObject10' : return ["Description"];	
				case 'Asset' : return ["Product","Status","Type"];
				case 'Territory' : return ["TerritoryName","Description"];
				case 'Note' : return ["Subject","Note"];
				case 'MedEdEvent' : return ["Name","Location","StartDate","EndDate","Objective"];	
			}
			return null;
		}
		
		public static function getFieldsDetailAsList(entity:String):ArrayCollection {
			var ret:ArrayCollection = new ArrayCollection();
			var fields:Array = getFieldsDetail(entity);
			for each (var tmp:String in fields) {
				var tmpArray:Array = tmp.split('|');
				for each (var field:String in tmpArray) {
					ret.addItem(field);
				}
			}
			return ret;
		}


		public static function linkableEntities(srcEntity:String):ArrayCollection {
			var transactions:ArrayCollection = Database.transactionDao.listTransaction();
			var linkable:ArrayCollection = Relation.getLinkable(srcEntity);
			var entities:ArrayCollection = new ArrayCollection();
			for each (var transaction:Object in transactions) {
				if (transaction.enabled && linkable.contains(transaction.entity)) {
					entities.addItem(transaction.entity);
				}
			} 			
			return entities;
		}
		
		
		public static function computeFilter(filter:Object):String {
			if (filter != null) {
				switch(filter.type) {	
					case 0 : {
						return "";
					}
					case -1 : {
						if (filter.entity == "Product" || filter.entity == "Asset" || filter.entity == "Territory") {
							return "";
						}
						return "OwnerId = (select id from user)";
					} 
					case -2 : {
						var dateFormatter:DateFormatter = new DateFormatter();
						dateFormatter.formatString = "YYYYMMDD";
						var today:Date = new Date();
						var day:int = 30;
						var num:String = Database.preferencesDao.getValue('recent_filter',"").toString();
						if(!StringUtils.isEmpty(num)){
							day = parseInt(num);
						}
						var todayMinusOneMonth:Date = new Date(today.getTime() - MILLIS_PER_DAY*day);
						var todayMinusOneMonthFormat:String = dateFormatter.format(todayMinusOneMonth);		
						if (filter.entity == "Product"){
							return "substr(ModifiedByDate, 1, 4) || substr(ModifiedByDate, 6, 2) || substr(ModifiedByDate, 9, 2) >= '" + todayMinusOneMonthFormat + "'";
						}
						return "substr(ModifiedDate, 1, 4) || substr(ModifiedDate, 6, 2) || substr(ModifiedDate, 9, 2) >= '" + todayMinusOneMonthFormat + "'";
					} 
					case -3 : {
						switch(filter.entity){
							case "Account" :
								return "AccountType='Customer'";
							case "Opportunity" :
								return "StageStatus='Lost'";
							case "Activity" :
								return "Status!='Completed'";
							case "Service Request":
								return "sync_number=" + Database.syncNumberDao.getSyncNumber() + " AND local_update is null"; 
						}
					} 
					case -4 : {
						switch (filter.entity){
							case "Account" :
								return "AccountType='Competitor'";
							case "Opportunity" :
								return "StageStatus='Open'";
							case "Activity" :
								return "Status='Completed'";
						}
					} 
					case -5 : { //Probability: High (80% +)
						switch (filter.entity){
							case "Opportunity" :
								return "CAST(Probability AS int) >= 80";
							case "Activity" :
								return "Activity = 'Appointment' AND CallType != 'Account Call'";
						}	
					} 
					case -6 : { //Probability: Low (20% -)
						switch (filter.entity){
							case "Opportunity" :
								return "CAST(Probability AS int) <= 20 OR Probability IS NULL";
							case "Activity" :
								return "Activity='Task'";
						}
					} 
					case -7 : {
						switch (filter.entity){
							case "Activity" :
								return "Activity = 'Appointment' AND CallType = 'Account Call'";
						}	
					}	
					default : {
						var query:String = "";
						var conjunction:String = "";
						for (var i:Number = 1; i <= 4; i++) {
							var criteria:Object = Database.criteriaDao.find(filter.id, "" + i);
							//CRO #1254 'SalesStage' 
							var param:String ="";
							if(criteria.column_name != null){
								param = criteria.column_name == 'SalesStage' ? criteria.param :Utils.doEvaluateForFilter(criteria,filter.entity).toLowerCase();//criteria.param.toLowerCase();
							}
							if (criteria.column_name != null && criteria.column_name != ""
								&& criteria.operator != null && criteria.operator != ""
								&& (criteria.operator == "is null" || 
									criteria.operator == "is not null" ? true : param != null && param != "") ) {
							
								if (criteria.operator == 'LIKE') { // contains  Bug fixing 588 like to LIKE
									param = '%' + param + "%";
								}else if(criteria.operator == 'LIKE%'){ // begins with    Bug fixing 588 like to LIKE
									criteria.operator = 'LIKE';
									param =  param + '%';
								}
								//query += "LOWER(" + criteria.column_name + ") " + criteria.operator + " '" + param + "'";
								var fieldInfo:Object = FieldUtils.getField(filter.entity, criteria.column_name);
								if (fieldInfo && (fieldInfo.data_type == "Number" || fieldInfo.data_type == "Integer" || criteria.column_name == 'Age' || fieldInfo.data_type == 'Currency')){ //CRO #1253 fieldInfo.data_type == 'Currency'
									//query += "CAST(LOWER(" + criteria.column_name + ") AS int) " + criteria.operator +  ( StringUtils.startsWith(criteria.operator, "is") ? " " : " '" + param + "'" );
									if(criteria.column_name == 'Age'){ 
										if(criteria.operator == "is null"){
											query += "age = '0'";
										}else if(criteria.operator == "is not null"){
											query += "age != '0'";
										}else{									
											query += "CAST(LOWER(" + criteria.column_name + ") AS int) " + criteria.operator +  ( StringUtils.startsWith(criteria.operator, "is") ? " " : " '" + param + "'" );
										}
									}else {
										query += "CAST(LOWER(" + criteria.column_name + ") AS int) " + criteria.operator +  ( StringUtils.startsWith(criteria.operator, "is") ? " " : " '" + param + "'" );
									}
								}else if(fieldInfo && (fieldInfo.data_type == "Date/Time" || fieldInfo.data_type == "Date")) { // DateTime / Date
									if(param.indexOf("{#}") != -1) { // Formula ThisYear, ThisMonth, ThisWeek
										var datepart:Array = param.split("{#}");
										var v1:String = DateUtils.format(DateUtils.guessAndParse(datepart[0]), DateUtils.DATABASE_DATE_FORMAT);
										var v2:String = DateUtils.format(DateUtils.guessAndParse(datepart[1]), DateUtils.DATABASE_DATE_FORMAT);
										if(criteria.operator == "=") {
											query += "(LOWER(" + criteria.column_name + ") > '" + v1 + "' AND LOWER(" + criteria.column_name + ") < '" + v2 + "')";
										}else if(criteria.operator == "!=") {
											query += "(LOWER(" + criteria.column_name + ") < '" + v1 + "' OR LOWER(" + criteria.column_name + ") > '" + v2 + "')";
										}else if(criteria.operator == ">") {
											// ---------------------v1---ThisWeek---v2--------------------------
											query += "LOWER(" + criteria.column_name + ") " + criteria.operator + " '" + v2 + "'";
										}else if(criteria.operator == "<") {
											// ---------------------v1---ThisWeek---v2--------------------------
											query += "LOWER(" + criteria.column_name + ") " + criteria.operator + " '" + v1 + "'";
										}
									}else {
										// Formula LastYear, NextYear, LastMonth, NextMonth, LastWeek, NextWeek										
										// query += "LOWER(" + criteria.column_name + ") " + criteria.operator + " '" + param + "'";
										query += "LOWER(" + criteria.column_name + ") " + criteria.operator + " '" + DateUtils.format(DateUtils.guessAndParse(param), DateUtils.DATABASE_DATE_FORMAT) + "'";
									}
								}else{
									if(criteria.operator == "is null"){
										query += "(LOWER(" + criteria.column_name + ") " + criteria.operator + " or LOWER(" + criteria.column_name + ") = '')";
									}else if(criteria.operator == "is not null"){
										query += "(LOWER(" + criteria.column_name + ") " + criteria.operator + " and LOWER(" + criteria.column_name + ") != '')";
									}else if (criteria.operator == "!="){ //get data different param also null CRO
										query += "(LOWER(" + criteria.column_name + ") " + criteria.operator + " LOWER('" + param + "') or " + "LOWER(" + criteria.column_name + ") is null)" ;
									}else{
										query += "LOWER(" + criteria.column_name + ") " + criteria.operator + " LOWER('" + param + "')";
									}
								}
								query += " " + criteria.conjunction + " ";
								conjunction = " " + criteria.conjunction + " ";
							}
						}
						if(query.length != conjunction.length){
							query = "(" + query.substring(0,query.length - conjunction.length) + ")";
						}else{
							query = "";
						}
						return query;
					}
				}
			}
			return "";
		}

		
		public static function getValidators(fieldInfo:Object, childObj:DisplayObject):Array {
			var validators:Array = [];
			// add validators
			if (fieldInfo.required) {
				var stringValidator:StringValidator = new StringValidator();
				if(childObj is GoogleLocalSearchAddress){
					stringValidator.property = "addressText";
					stringValidator.source = (childObj as GoogleLocalSearchAddress);
				}else{
					stringValidator.property = "text";
					if (childObj is HBox && (fieldInfo.data_type == 'Date' || fieldInfo.data_type == 'Date/Time')){
						stringValidator.source = (childObj as HBox).getChildAt(0);
					} else {
						stringValidator.source = childObj;
					}
				}
				validators.push(stringValidator);	
			}
			if (fieldInfo.data_type == "Number" || fieldInfo.data_type == "Integer" || fieldInfo.data_type == "Currency" || fieldInfo.element_name == "Age") {
				var validator:NumberValidator = new NumberValidator(); 
				if (fieldInfo.data_type == "Number" || fieldInfo.data_type == "Currency")
					validator.domain = "real";
				else
					validator.domain = "int";
				validator.minValue = 0;
				if (StringUtils.endsWith(fieldInfo.display_name, "%")) {
					validator.maxValue = 100;
				}
				validator.property = "text";
				validator.source = childObj;	
				validator.required = false;
				validators.push(validator);
			}
			
			if (fieldInfo.element_name == "LeadEmail" || fieldInfo.element_name == "ContactEmail" || fieldInfo.element_name == "Email"){
				var emailValidator:EmailValidator = new EmailValidator();
				emailValidator.property = "text";
				emailValidator.source = ((childObj as HBox).getChildAt(0) as TextInput);
				emailValidator.required = false;
				validators.push(emailValidator);
			}
			return validators;
		}
		
		public static function readValidationRule(validatorErrorArray:Array, field:Object, entity:String):void {
			//field: entity, column_name, row, col, custom, component
			//validationRule.field, validationRule.operator, validationRule.value, validationRule.message
			for each(var validationRule:Object in Database.validationDao.selectEntity(entity)){
				if(field.component!=null && field.column_name == validationRule.field){
					var componentValue:String;
					var isAddError:Boolean;
					var isTypeNumber:Boolean;
					
					var fieldInfo:Object = getField(entity, field.column_name);
					if (fieldInfo.data_type == "Number" || fieldInfo.data_type == "Integer") isTypeNumber = true;
					
					if(field.component is TextInput){
						componentValue = (field.component as TextInput).text;
					}else if(field.component is AutoComplete){
						componentValue = (field.component as AutoComplete).typedText;
					}else if(field.component is ComboBox){
						componentValue = (field.component as ComboBox).selectedItem.data;
					}else if(field.component is CheckBox){
						componentValue = (field.component as CheckBox).selected ? "Y" : "N"
					}else if(field.component is HBox && fieldInfo.data_type == 'Date'){
						componentValue = ((field.component as HBox).getChildAt(0) as DateField).text;
					}
					switch(validationRule.operator){
						case "=" :
							if(componentValue == validationRule.value) isAddError = true;
							break;
						case "!=" :
							if(componentValue != validationRule.value) isAddError = true;
							break;
						case "like":
							if(componentValue.indexOf(validationRule.value) != -1) isAddError = true;
							break;
						case "<":
							if(isTypeNumber){
								if(parseInt(componentValue) < parseInt(validationRule.value)) isAddError = true;
								break;
							}
							if(componentValue < validationRule.value) isAddError = true;
							break;
						case ">":
							if(isTypeNumber){
								if(parseInt(componentValue) > parseInt(validationRule.value)) isAddError = true;
								break;
							}								
							if(componentValue > validationRule.value) isAddError = true;
							break;
						case "is not null":
							if( componentValue != null && componentValue != '' ) isAddError = true;
							break;
						case "is null":
							if( componentValue == null || componentValue == '' ) isAddError = true;
							break;
					}
					if(isAddError){
						addValidationRuleError(validatorErrorArray,validationRule.message);
					}
				}
			}
		}
		public static function getFieldDisplayName(entity:String,element_name:String):String{
			
			var obj:Object = getField(entity,element_name);
			if(obj==null){
				obj = getField(entity,element_name,false,true);
			}
			
			if(obj!=null){
				var display:String = obj.display_name;
				if(StringUtils.startsWith(display,'[') && StringUtils.endsWith(display,']')){
					display = display.substring(1,display.length-1);	
				}
				
				return display;
			}
			
			return element_name;
			
		}
		private static function addValidationRuleError(validatorErrorArray:Array, errMsg:String):void {
			var error:Object = new Object();
			error.message = errMsg;
			validatorErrorArray.push(error);
		}
		
		public static function isValidPrintServiceRequest(srItem:Object):Boolean {
			//entity			element_name		display_name			data_type
			//-----------------------------------------------------------------------
			//Service Request	CustomObject1Name	Working Hours and Costs	Picklist
			//Service Request	CustomPickList12	Solution Code			Picklist
			//Service Request	CustomPickList7		Cause Code				Picklist
			var data:ArrayCollection = Database.customObject1Dao.getWorkingHoursAndCost(srItem);
			var val:Boolean = !StringUtils.isEmpty(srItem.CustomPickList7) && !StringUtils.isEmpty(srItem.CustomPickList12) && data.length > 0;
			val = val && !(srItem.CustomPickList10 != 'SUSP' && srItem.CustomPickList10 != 'AWPT' && srItem.CustomPickList11 != 'TECO');
			return val;
		}
		
	}
}