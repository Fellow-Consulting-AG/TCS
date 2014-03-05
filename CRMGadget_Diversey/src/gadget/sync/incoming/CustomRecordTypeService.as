package gadget.sync.incoming {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import gadget.dao.Database;
	import gadget.lists.List;
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import gadget.sync.task.SyncTask;
	
	public class CustomRecordTypeService extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/customrecordtype/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/customrecordtype/data");

		override protected function doRequest():void {
 			if (getLastSync() != NO_LAST_SYNC_DATE){
				successHandler(null);
				return;
			}
			
			sendRequest("\"document/urn:crmondemand/ws/odesabs/CustomRecordType/:CustomRecordTypeReadAll\"",
				<CustomRecordTypeReadAll_Input xmlns="urn:crmondemand/ws/odesabs/customrecordtype/"/>,
				"admin",
				"Services/cte/CustomRecordTypeService"
			);

		}
		
		private function getDataStr(field:XML, col:String):String {
			var tmp:XMLList = field.child(new QName(ns2.uri,col));
			return tmp.length()==0 ? "" : tmp[0].toString();
		}
		
		private function populate(field:XML, cols:Array):Object {
			var tmpOb:Object = {};
			for each (var col:String in cols) {
				tmpOb[col] = getDataStr(field,col);
			}
			return tmpOb;
		}

		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}

			var cnt:int = 0;
			
			Database.begin();
			Database.customRecordTypeServiceDao.delete_all();
			for each (var rec:XML in result.ns2::ListOfCustomRecordType[0].ns2::CustomRecordType) {

				var fieldRec:Object = populate(rec, Database.customRecordTypeServiceDao.getColumns());
				Database.customRecordTypeServiceDao.replace(fieldRec);

				for each (var trans:XML in rec.ns2::ListOfCustomRecordTypeTranslations[0].ns2::CustomRecordTypeTranslation) {
					var transRec:Object = populate(trans, Database.customRecordTypeTranslationsDao.getColumns());
					transRec.CustomRecordTypeServiceName = fieldRec.Name;
					Database.customRecordTypeTranslationsDao.replace(transRec);
				}
				cnt++;
			}
			Database.commit();
			
			nextPage(true);
			return cnt;
		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			//VAHI we do not have an error code here.
			// So all we can do is to check for the exact string.
			// I honestly vomit.
			
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			//VAHI perhaps it would be better to check for error type SOAP:Server????
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=="")
				return false;
			trace("no CustomRecordTypeService in this login");
			nextPage(true);
			return true;
		}
		
		override public function getName():String {
			return "Getting translations from custom record type service..."; 
		}
		
		override public function getEntityName():String {
			return "CustomRecordTypeService"; 
		}
	}
}
