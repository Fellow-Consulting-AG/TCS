package gadget.sync.incoming {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.sync.task.SyncTask;
	import gadget.util.FieldUtils;
	import gadget.util.OOPS;
	import gadget.util.OOPSthrow;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	public class GetFields extends SyncTask {
		
		private var ns1:Namespace = new Namespace("urn:crmondemand/ws/mapping/");
		private var ns2:Namespace = new Namespace("urn:/crmondemand/xml/mappingservice");

		private var currentEntity:int = 0;
		private var allEntities:Array;
		private var tao:SodUtilsTAO;
		
		
		private const GETFIELDS_VERSION:int = 8;	// Increment to force FULL SYNC on older clients
		
		override protected function doRequest():void {
 			if (getLastSync(GETFIELDS_VERSION, SodUtils.fixFieldsHash) != NO_LAST_SYNC_DATE){
 				updateLastSync(GETFIELDS_VERSION, SodUtils.fixFieldsHash);
				return;
			} 
			FieldUtils.reset();
			Database.incomingSyncDao.unsync_one("gadget.sync.task::ReadPicklist");
			
			if (allEntities==null){
				
				allEntities = SodUtils.transactionsTAOif("top_level");
				for each(var transaction:Object in allEntities){
					for each (var sub:String in SupportRegistry.getSubObjects(transaction.our_name)) {
						var subDao:SupportDAO = SupportRegistry.getSupportDao(transaction.our_name, sub)
						var subentity:String=DAOUtils.getRecordType(subDao.entity);
						
						if(subDao.isGetField){			
							var sodTao:SodUtilsTAO = new SodUtilsTAO();
							sodTao.our_name = subDao.entity;							
							sodTao.sod_name = subentity;
							allEntities.push(sodTao);
						}
						
					}
				}
				
			}
				

			tao = allEntities[currentEntity];	
			var entity:String = tao.sod_name;
			if(tao.our_name==Database.medEdDao.entity){
				entity = "MedEdEvent";
			}
			
			var request:XML =
					<MappingWS_GetMapping_Input xmlns='urn:crmondemand/ws/mapping/'>
						<ObjectName>{entity}</ObjectName>
					</MappingWS_GetMapping_Input>
			sendRequest("\"document/urn:crmondemand/ws/mapping/:GetMapping\"", request);

		}
		
		override protected function handleResponse(request:XML, result:XML):int {
			if (getFailed()) {
				return 0;
			}
			var cnt:int = 0;
			var fields:ArrayCollection = new ArrayCollection();
			var entity:String = result.ns1::ObjectName[0].toString();
//			if (entity!=tao.sod_name) {
//				OOPSthrow("unrequested entity", " got="+entity, "want="+tao.sod_name);
//			}

			trace("WS response for",entity,"as",tao.our_name);
			//CRO 15-06-2011 release table size
			//Database.errorLoggingDao.add(null, {getField:entity,xml:result});

			// Fetch the fields from records got
			var tmpFieldsList:Object = {};
			for each (var field:XML in result.ns2::ListOfField[0].ns2::Field) {
				var elementName:String = field.ns2::ElementName[0].toString();

				tmpFieldsList[elementName] = {
					entity: entity,
					element_name: elementName.replace(/-/g,"_"),
					display_name: field.ns2::DisplayName[0].toString(),
						data_type: field.ns2::DataType[0].toString()
						};
				cnt++;
				_nbItems++;
			}
			
			// Apply fixes to the data
			for each (var ob:Object in SodUtils.fixFields(entity)) {
				var store:Object = tmpFieldsList[ob.name];
				function fieldSet(repl:String, src:String, def:String=""):String {
					if (store!=null && src in store && store[src]!=null && store[src]!="")
						return store[src];
					if (repl!=null && repl!="")
						return repl;
					return def;
				}
				function fieldOvr(ovr:String, orig:String):String {
					if (ovr!=null && ovr!="")
						return ovr;
					return orig;
				}
				tmpFieldsList[ob.name] = {
					entity: entity,
					element_name: fieldOvr(ob.rename, fieldSet(ob.name, "element_name")),
					display_name: fieldSet(ob.display, "display_name", ob.name),
					data_type:    fieldSet(ob.type, "data_type", "Text (Long)")
				};
			}

			// Store Result into fieldDao
			FieldUtils.reset();
			Database.begin();
			Database.fieldDao.delete_fields(entity);
			
			for each (var tmp:Object in tmpFieldsList) {
				if (Database.checkField(tao.our_name, tmp.element_name)) {
					Database.fieldDao.insert(tmp);
				}
			}
			if(entity=="Activity") Database.ycheckMissingField(); // add missing field (Owner, Address) into Activity
			Database.commit();
			
			isFielChange = true;
			nextOne();
			return cnt;
		}

		private function nextOne():void {
			currentEntity++;
			nextPage(currentEntity >= allEntities.length, GETFIELDS_VERSION, SodUtils.fixFieldsHash);
		}

		override protected function handleRequestFault(soapAction:String, request:XML, response:XML, faultString:String, xml_list:XMLList, event:IOErrorEvent):Boolean {
			var oops:String;
			if (faultString.indexOf("(SBL-ODS-00187)")>=0) {
				oops ="no fields for entity {1}: {2}";
			} else {
				OOPS("=unhandled",faultString);
				return false;
			}
			trace("no", allEntities[currentEntity].sod_name, xml_list[0].faultstring[0]);
			//optWarn(i18n._(oops, allEntities[currentEntity].sod_name, xml_list[0].faultstring[0]), null);
			nextOne();
			return true;
		}
		
		override public function getName():String {
			return "Getting fields..."; 
		}
		
		override public function getEntityName():String {
			return "Field records"; 
		}
	}
}
