package gadget.service
{
	import flashx.textLayout.operations.PasteOperation;
	
	import gadget.control.CalculatedField;
	import gadget.dao.CascadingPicklistDAO;
	import gadget.dao.CustomFieldDAO;
	import gadget.dao.CustomPicklistValueDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.util.CacheUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;

	/**
	 * That class handle picklist stuff.
	 */
	public class PicklistService
	{
		public function PicklistService()
		{
		}
		
		/**
		 * Returns a picklist for field. We try to fetch data from 1) picklistserviceDao then 2) picklistDao.
		 * @param entity Entity.
		 * @param field Field.
		 * @return Picklist.
		 * 
		 */
		public static function getPicklist(entity:String, field:String,emptyValue:Boolean=true,bindPicklist:Boolean=true,resetPicklist:Boolean=false):ArrayCollection {
			
			if(field==null){ return new ArrayCollection(); }
			
			// get user's locale
			var langCode:String = LocaleService.getLanguageInfo().LanguageCode;
			
			if(field.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
				return Database.customFieldDao.getPicklistValue(entity,field,langCode);
			}
			
			var cache:CacheUtils = new CacheUtils("picklist");		
			if(resetPicklist) cache.del(entity + "/" + field);		
			var picklist:ArrayCollection = cache.get(entity + "/" + field) as ArrayCollection;			
			if (picklist != null) {				
				return new ArrayCollection(picklist.source);
			}
			
			picklist = getPicklist_crmod(entity, field,langCode);
			if(bindPicklist){
				picklist.addAll(Database.customFieldDao.getBindPicklistValue(entity,field,langCode,true));
				// CustomFieldDAO.checkBindPicklist(picklist);
				picklist = CustomFieldDAO.checkBindPicklist(entity,field,picklist);
			} 
			
			if(emptyValue) picklist.addItemAt({data:'',label:''},0);
			cache.put(entity+ "/" + field, picklist);
			
			return picklist;
		}
		
		public static function getMultiPicklistByLanguage(entity:String, field:String,langCode:String,emptyValue:Boolean=true,bindPicklist:Boolean=true,resetPicklist:Boolean=false):ArrayCollection {
			
			if(field==null){ return new ArrayCollection(); }
			
			// get user's locale
			//var langCode:String = LocaleService.getLanguageInfo().LanguageCode;
			
			if(field.indexOf(CustomLayout.CUSTOMFIELD_CODE)>-1){
				return Database.customFieldDao.getPicklistValue(entity,field,langCode);
			}
			
			
			
			var crmodEntity:String = DAOUtils.getRecordType(entity);
			
			var picklist:ArrayCollection = Database.picklistServiceDao.getPicklists(getPicklistFieldName(field), crmodEntity, langCode);
			
			
			if (picklist.length == 0) {				
				
					picklist = Database.picklistDao.select(field, crmodEntity);
				}
				
				
				
				if(emptyValue) picklist.addItemAt({data:'',label:''},0);
				//cache.put(entity+ "/" + field, picklist);
				
				return picklist;
			}
		
		
		
		public static function getBindPicklist(entity:String, field:String,emptyValue:Boolean=true,resetPicklist:Boolean=false):ArrayCollection {	
			if(field==null){ return new ArrayCollection();  }			
			// get user's locale
			var langCode:String = LocaleService.getLanguageInfo().LanguageCode;
			// if(defaultLanguageCode==true) langCode = "ENU";
			
			var cache:CacheUtils = new CacheUtils("picklist_ood");
			if(resetPicklist) cache.del(entity + "/" + field);	
			var picklist:ArrayCollection = cache.get(entity + "/" + field) as ArrayCollection;
			if (picklist != null) {				
				return new ArrayCollection(picklist.source);
			}
			
			picklist = getPicklist_crmod(entity, field,langCode);
			if(picklist.length<=0) picklist = getPicklist_crmod(entity, field,"ENU");
		 	// 
			picklist.addAll(Database.customFieldDao.getBindPicklistValue(entity,field,langCode,true));
			
			if(emptyValue) picklist.addItemAt({data:'',label:''},0);
			cache.put(entity+ "/" + field, picklist);
			return picklist;
		}
		
		public static function getPicklist_crmod(entity:String, field:String,langCode:String):ArrayCollection {	
			var picklist:ArrayCollection;
			var crmodEntity:String = DAOUtils.getRecordType(entity);
			var picklist2:ArrayCollection = Database.picklistServiceDao.getPicklists(field, crmodEntity, langCode);
			// if there are some value missing, we add them from the ENU picklist (english-us)
			var picklistUs:ArrayCollection = Database.picklistServiceDao.getPicklists(field, crmodEntity, "ENU");
			for each (var itemUs:Object in picklistUs) {
				var found:Boolean = false;
				// we check if the US item is already present in the picklist
				for each (var tmp:Object in picklist2) {
					if (itemUs.data == tmp.data) {
						found = true;
						break;
					}
				}
				if (found == false) {
					// item not found => we add it in the picklist
					picklist2.addItem(itemUs);
				}
			}
			if (picklist2.length > 0) {				
				picklist = picklist2;
			} else {
				picklist = Database.picklistDao.select(field, crmodEntity);
			}
			return picklist;
		}
		
		
		public static function getPicklistByLanguage(entity:String, field:String, code:String, item:Object=null, langCode:String="ENU"):String{
			
			if(StringUtils.isEmpty(code)){
				return "";
			} 
			
			var custField:Object = Database.customFieldTranslatorDao.selectByFieldName(entity,field,langCode);
			var displayVal:String="";
			
			if(custField!=null && item!=null){
				
				var parentPickList:String = Database.cascadingPicklistDAO.selectParentColumn(entity,field);
				var customPicklistValue:Object = Database.customPicklistValueDAO.selectByFieldName(entity,field,item.gadget_id);				
				if(customPicklistValue!=null){
					code = customPicklistValue.crmCode;
					if(code.indexOf('$$')<0) code = code.replace("/","$$");					
				} 
				var bindValue:ArrayCollection  = Database.customFieldDao.getBindPicklistValue(entity,field,langCode,true,code);
				
				
				if(bindValue!=null && bindValue.length>0){
					if(parentPickList!=null){
						var pVal:String = item[parentPickList];//Database.picklistServiceDao.getPicklistsValue(parentPickList,entity,item[parentPickList],langCode);
						for each(var obj:Object in bindValue){
							if(obj.parent == pVal){
								displayVal = obj.label;
								break;
							}
						}
					}else{
						displayVal = bindValue.getItemAt(0).label;
					}
					
				}
			}
			
			
			
			if(StringUtils.isEmpty(displayVal)){
				displayVal = Database.picklistServiceDao.getPicklistsValue(field,entity,code,langCode);
				
				if(StringUtils.isEmpty(displayVal)){
					displayVal = Database.picklistServiceDao.getPicklistsValue(field,entity,code);
				}
			}
			
			return displayVal;
			
//			var picklist:ArrayCollection = Database.picklistServiceDao.getPicklists(field, entity,langCode);
//			if(picklist.length == 0) picklist = Database.picklistDao.select(field, entity);
//			
//			picklist.addAll(Database.customFieldDao.getBindPicklistValue(entity,field,langCode,true));
//			picklist = CustomFieldDAO.checkBindPicklist(entity,field,picklist);
//			
//			if(item){ //  && !StringUtils.isEmpty(item[parentField])){
//				// find local picklist code.
//				var customPicklistValue:Object = Database.customPicklistValueDAO.selectByFieldName(entity,field,item.gadget_id);
//				if(customPicklistValue){
//					code = customPicklistValue.crmCode;
//					if(code.indexOf('$$')<0) code = code.replace("/","$$");
//				} 
//				
////				if(Database.customFieldTranslatorDao.selectField(entity,field,langCode)){
////					picklist.addAll(Database.customFieldDao.getBindPicklistValue(entity,field,langCode,true));
////					picklist = CustomFieldDAO.checkBindPicklist(entity,field,picklist);
////				}
//
//			}
//			
//			for each (var tmp:Object in picklist) {
//				if (tmp.data == code ) {
//					return tmp.label;
//				}
//			}
//			return null;
		}
		
		// ID => value
		public static function getValue(entity:String, field:String, code:String,item:Object=null):String {
			var cache_child_value:CacheUtils = new CacheUtils("cascading_child_values");
			var cache_parent_field:CacheUtils = new CacheUtils("cascading_parent_field");
			var parentField:String = Utils.checkNullValue(cache_parent_field.get(entity + "/" + field));
			var key:String = "";
			if(item!=null){
				key = entity + "/" + field + "/" + code + "/" + item[parentField];				
			}
				
			var value:String = Utils.checkNullValue(cache_child_value.get(key));
			var tempCode:String = code;
			if(item && !StringUtils.isEmpty(item[parentField])){				
				var customPicklistValue:Object = Database.customPicklistValueDAO.selectByFieldName(entity,field,item.gadget_id);				
				if(customPicklistValue){
					tempCode = customPicklistValue.crmCode;
					if(tempCode.indexOf('$$')<0) tempCode = tempCode.replace("/","$$");
					key = entity + "/" + field + "/" + tempCode + "/" + item[parentField];
				}
				
				// find local picklist code.
				if(!StringUtils.isEmpty(value)){
					
					
						
						value = Utils.checkNullValue(cache_child_value.get(key));
						if(StringUtils.isEmpty(value) || value==CascadingPicklistDAO.CUSTOM_FIELD_TYPE){						
							value  =  getPicklistByLanguage(entity,field,code,item,LocaleService.getLanguageInfo().LanguageCode);
							cache_child_value.put(key,value);
						}
						
						
					
					var temVal:String = Utils.checkNullValue(cache_child_value.get(key)); 
					
					if(!StringUtils.isEmpty(temVal)){
						value = temVal;	
					}
					
					return value;
				} 
			}
			if(item!=null && !StringUtils.isEmpty(item[parentField])){
				key = entity + "/" + field + "/" + tempCode + "/" + item[parentField];
				value = Utils.checkNullValue(cache_child_value.get(key));
				if(StringUtils.isEmpty(value)){						
					value  =  getPicklistByLanguage(entity,field,code,item,LocaleService.getLanguageInfo().LanguageCode);
					cache_child_value.put(key,value);
				}
				return value;
			}else{
				var list:ArrayCollection = getPicklist(entity, field);
				for each (var tmp:Object in list) {
					if (tmp.data == code) return tmp.label;
				}
//				return PicklistService.getValueOOD(entity,field,code,LocaleService.getLanguageInfo().LanguageCode);
			}			
			
			return null;
		}

		// Value => ID
		public static function getId(entity:String, field:String, label:String,LanguageCode:String="ENU"):String {
			//#977 CRO
			var picklist:ArrayCollection = Database.picklistServiceDao.getPicklists(Utils.convertFldAccTypeToType(entity,field), entity, LanguageCode);
			for each (var tmp:Object in picklist) {
				if (tmp.label == label) {
					return tmp.data;
				}
			}
			return null;
//			return Database.picklistServiceDao.getPicklistsId(Utils.convertFldAccTypeToType(entity,field),entity,label,LanguageCode);
		}
		
		// Value => Value OOD only
		public static function getValueOOD(entity:String, field:String, code:String,LanguageCode:String="ENU"):String {
			var picklist:ArrayCollection = Database.picklistServiceDao.getPicklists(Utils.convertFldAccTypeToType(entity,field), entity, LanguageCode);
			for each (var tmp:Object in picklist) {
				if (tmp.data == code) {
					return tmp.label;
				}
			}
//			return Database.picklistServiceDao.getPicklistsValue(Utils.convertFldAccTypeToType(entity,field),entity,code,LanguageCode);
			return null;
		}
		
		public static function getPicklistOOD(entity:String, field:String, label:String,LanguageCode:String="ENU"):Object {
			var picklist:ArrayCollection = Database.picklistServiceDao.getPicklists(Utils.convertFldAccTypeToType(entity,field), entity, LanguageCode);
			for each (var tmp:Object in picklist) {
				if (tmp.label == label) {
					return tmp;
				}
			}
//			return  Database.picklistServiceDao.getPicklistsObjectByValue(Utils.convertFldAccTypeToType(entity,field),entity,label,LanguageCode);
			return null;
		}
		
		// Change Request #460
		public static function getMultiSelectPicklist(entity:String, item:Object, field:String):Object {
			var availableItems:ArrayCollection = new ArrayCollection();
			var selectedItems:ArrayCollection = new ArrayCollection();
			for each(var multipicklist:Object in getPicklist(entity, field)) {
				if(multipicklist.label) {
					if(item[field]) {
						var str_split:String = item[field].toString().indexOf(";") !=-1 ? ";" : ",";
						for each(var data:String in item[field].toString().split(str_split)) {
							if(multipicklist.data == StringUtil.trim(data)) 
								selectedItems.addItem({data:multipicklist.data, label:multipicklist.label});
						}
					}
					if(!StringUtils.isEmpty(StringUtil.trim(multipicklist.data))){
						availableItems.addItem({data:multipicklist.data, label:multipicklist.label});
					}
				}
			}
			return {availableItems: availableItems, selectedItems: selectedItems};
		}
		public static function getPicklistFieldName(fieldName:String):String{
			//CustomMultiSelectPickList0 is the field in Picklist table
			//MSCustomPickList0 is the field in PicklistService table
			//CustomMultiSelectPickList0 => MSCustomPickList0
			return fieldName.replace("CustomMultiSelectPickList","MSCustomPickList");
		}
	}
}