package gadget.sync.incoming {
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.util.ObjectUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingObjectPerId extends WebServiceIncoming {
		
		private var _ids:Array;
		
		public function IncomingObjectPerId(entity:String) {
			super(entity);
			if (entity == "Contact") {
				ignoreFields.push("CurrencyCode", "ContactFullName");
			}

		}

		override protected function getInfo(xml:XML, ob:Object):Object {
			if (entityIDour == "Contact") {
				ob.picture = null;
			}
			return {
				rowid:ob[DAOUtils.getOracleId(entityIDour)],
				name:ObjectUtils.joinFields(ob, DAOUtils.getNameColumns(entityIDour))
			};
		}
		
		override protected function tweak_vars():void {
			if (entityIDour == "User") {
				withFilters	= false;
			}
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + entityIDour;
		}
		
		override protected function doRequest():void {
			
			if (_page*pageSize>=_ids.length) {
				successHandler(null);
				return;
			}
			
			var subList:Array = _ids.slice(_page*pageSize, _page*pageSize+pageSize);			
			var searchSpec:String = "";
			for each (var id:String in subList) {
				if (searchSpec.length > 0) {
					searchSpec += " OR ";
				}
				searchSpec += "([Id] = '" + id + "')";
			}				
			
			trace("::::::: REQUEST_PER_ID ::::::::", getEntityName(), _page, isLastPage, haveLastPage, searchSpec);
//			Database.errorLoggingDao.add(null, {trace:[getEntityName(), _page, isLastPage, haveLastPage, searchSpec]});
			//VAHI another poor man's workaround for missing late binding in XML templates
			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, 0)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
		
		override protected function initOnce():void {
			initXML(stdXML);
			_ids = [];
			var idArray:ArrayCollection = Database.modificationTrackingDao.findAll(
				new ArrayCollection([{element_name:"ObjectId"}]),
				"ObjectName = '" + translateEntity(entityIDour) + "' AND processed IS NULL");
			for each (var record:Object in idArray) {
				if (_ids.indexOf(record.ObjectId) == -1) {
					_ids = _ids.concat(record.ObjectId);
				}
			}
		}
		
		public static function translateEntity(entity:String):String {
			if (entity == "Activity")  {
				return "Action";
			}
			return entity;
		}
	}
}
