package gadget.sync.incoming {
	import flash.events.IOErrorEvent;
	
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.sync.task.SyncTask;

//	import gadget.util.FieldUtils;
	
	public class AccessProfileService extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/odesabs/accessprofile/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/AccessProfile/Data");

		override protected function doRequest():void {
 			if ((getLastSync() != NO_LAST_SYNC_DATE) || (!Database.preferencesDao.getBooleanValue(PreferencesDAO.SYNC_ACCESS_PROFIL))){
				successHandler(null);
				return;
			} 
//			FieldUtils.reset();
			
			sendRequest("\"document/urn:crmondemand/ws/odesabs/accessprofile/:AccessProfileReadAll\"",
				<AccessProfileReadAll_Input xmlns={ns1}/>,
				"admin",
				"Services/cte/AccessProfileService"
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
			Database.accessProfileServiceDao.delete_all();
			
			for each (var ap:XML in result.ns2::ListOfAccessProfile[0].ns2::AccessProfile) {

				var apRec:Object = populate(ap, Database.accessProfileServiceDao.getColumns());
				Database.accessProfileServiceDao.insert(apRec);
				
				for each (var trans:XML in ap.ns2::ListOfAccessProfileTranslation[0].ns2::AccessProfileTranslation) {
					var transRec:Object = populate(trans, Database.accessProfileServiceTransDao.getColumns());
					transRec.AccessProfileServiceName = apRec.Name;
					Database.accessProfileServiceTransDao.insert(transRec);
				}
				for each (var entry:XML in ap.ns2::ListOfAccessProfileEntry[0].ns2::AccessProfileEntry) {
					var entryRec:Object = populate(entry, Database.accessProfileServiceEntryDao.getColumns());
					entryRec.AccessProfileServiceName = apRec.Name;
					Database.accessProfileServiceEntryDao.insert(entryRec);
				}

				cnt++;
			}
			Database.commit();
			
			nextPage(true);
			return cnt;
		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {

			// SINCE Oracle dont return any error code
			// we return true each time there is a faultstring
			/*
			
			<faultcode xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="urn:crmondemand/ws/odesabs/accessprofile/" xmlns:ns1="urn:/crmondemand/xml/AccessProfile/Query" xmlns:ns2="urn:/crmondemand/xml/AccessProfile/Data">
			SOAP:Server
			</faultcode>
			*/
			if (xml_list.length()<1 || xml_list[0].faultstring.length()!=1)
				return false;
			var str:String = xml_list[0].faultstring[0].toString();
			if (str=="")				
				return false;
			
			optWarn("AccessProfileService unsupported: "+str);
			nextPage(true);
			return true;
		}
		
		override public function getName():String {
			return "Getting AccessProfileService..."; 
		}
		
		override public function getEntityName():String {
			return "AccessProfileService"; 
		}
	}
}
