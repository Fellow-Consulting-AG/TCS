package gadget.dao {
	
	import flash.data.SQLConnection;
	
	import gadget.service.LocaleService;
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	
	public class LayoutDAO extends SimpleTable {		
		public function LayoutDAO(sqlConnection:SQLConnection, work:Function) {
			super(sqlConnection, work, {
				table: 'detail_layout',
				index: ["entity", "subtype"],
				unique : ["entity, subtype, col, row"],
				columns: { 'TEXT' : textColumns, "INTEGER": integerColumns, "BOOLEAN" : booleanColumns, 'TEXT' : "max_chars"}
			});
		}
		
		private var textColumns:Array = [
			"entity", 
			"column_name", 
			"custom" // ,
			// "max_chars"
			
		];
		
		private var integerColumns:Array = [
			"subtype",
			"col", 
			"row"
		];
		
		private var booleanColumns:Array = [
			"readonly", 
			"mandatory"
		];
		
		private var vars:String = "entity, subtype, col, row, column_name, custom, readonly, mandatory,max_chars";
		
		public function selectLayout(entity:String, subtype:int):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity, subtype:subtype}));
			var languageCode:String = LocaleService.getLanguageInfo().LanguageCode;
			for each(var obj:Object in list){
				var col_name:String = obj.column_name;
				if (col_name.indexOf(CustomLayout.CALCULATED_CODE) > -1 || col_name.indexOf("#") > -1){
					// if(col_name.indexOf("#") > -1) col_name += "_" + obj.col;
					var objCustomField:Object = Database.customFieldDao.selectCustomFieldWithSubType(obj.entity, col_name,subtype,languageCode);
					obj["customField"] = objCustomField;
				}if (obj.column_name.indexOf(CustomLayout.SQLLIST_CODE) > -1){
					var criterias:ArrayCollection = Database.sqlListDAO._select(obj.entity, obj.column_name);
					obj["criterias"] = criterias;
				}
			}
			return list;
		}
		
		public function selectCustomFields(entity:String):ArrayCollection {
			var list:ArrayCollection = new ArrayCollection(select(vars, null, {entity:entity}));
			var customFieldlist:ArrayCollection = new ArrayCollection();
			for each(var obj:Object in list){
				if (obj.column_name.indexOf(CustomLayout.CUSTOMFIELD_CODE) > -1){
					// var objCustomField:Object = Database.customFieldDao.selectCustomField(obj.entity,obj.column_name);
					var customFieldInfo:Object = FieldUtils.getField(obj.entity, obj.column_name,true);
					if(customFieldInfo){
						customFieldlist.addItem(customFieldInfo);
					} 
				}
			}
			return customFieldlist;
		}
		
		public function deleteLayout(entity:String, subtype:int):void{
			Database.customFieldDao.deleteLayout(entity, subtype);
			Database.sqlListDAO.delete_({entity_src: entity});
			delete_({entity:entity, subtype:subtype});
		}
		
		
		/*public function selectAll(entity:String):ArrayCollection {
			return new ArrayCollection(select_order(vars, "", {entity: entity}, "col, row", null));
		}
	
		public function updateLayout(detailLayout:Object):void {
			update(detailLayout, "", {entity:detailLayout.entity, subtype:detailLayout.subtype}); 
		}*/
		
	}
}