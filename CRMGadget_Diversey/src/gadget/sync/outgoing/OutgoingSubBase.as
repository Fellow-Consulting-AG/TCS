package gadget.sync.outgoing
{
	
	
	import flash.utils.getQualifiedClassName;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.sync.task.ReferenceUpdater;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	
	import org.purepdf.pdf.forms.PushbuttonField;

	public class OutgoingSubBase extends OutgoingObject
	{
		protected var subIDour:String;
		protected var subIDsod:String;
		protected var subIDns:String;
		protected var subList:String;
		protected var subIDId:String;
		protected var subDao:SupportDAO;
		
		protected var deleted:Boolean=true;
		protected var oper:String = "";
		public function OutgoingSubBase(ID:String, subId:String)
		{
			super(ID);
			subIDour	= subId;
			subIDsod	= SodUtils.transactionProperty(subId).sod_name;
			if(ID == Database.opportunityDao.entity && subId == Database.productDao.entity){
				subIDsod = subIDsod + "Revenue";
				
			}else if(ID == Database.contactDao.entity  && subId == "Related"){
				subIDsod = subIDsod + ID;
			}
			subIDns		= subIDsod.replace(/ /g,"");
			
			subList		= "ListOf"+subIDns;
			
			
			subDao= SupportRegistry.getSupportDao(entity, subId);
		
			subIDId		=  DAOUtils.getOracleId(subDao.entity);;
			NameCols = DAOUtils.getNameColumns(subDao.entity);	
			
		}
		
		override protected function getDao():BaseDAO{
			return this.subDao;
		}
		
		override protected function doRequest():void{
			
			if(deleted){
				records = subDao.findDeleted(faulted,PAGE_SIZE);
			}else{
				if (updated) {
					records = subDao.findUpdated(faulted, PAGE_SIZE);
				} else {
					records = subDao.findCreated(faulted, PAGE_SIZE);
				}
			}
			
			if(deleted){				
				oper = "delete";
				
			}else{
				oper = updated ? 'update' : 'insert';
			}
			
			
			
			if (records.length == 0) {
				
				if(deleted){
					deleted = false;
					faulted = 0;
				}else{	
					if (updated) {
						successHandler(null);
						return;
					}
						updated = true;				
				}	
				faulted = 0;
				doRequest();
				return;
			}
			
			var WSTag:String = WSTagExe;
			var request:XML =
				<{WSTag} xmlns={ns1}>
					<{ListOfTag}/>
				</{WSTag}>;
			
			var xml:XML = <{EntityTag} xmlns={ns1} operation='skipnode'/>;
			var subXML:XML = <{subList} xmlns={ns1}/>;
			
			for(var i:int = 0; i < records.length; i++){
				var tmp:XML = <{subIDsod} operation={oper}/>;
				if(oper == "delete"){
					
					var pf:String = WSProps.ws10to20(entity,SodID);
					xml.appendChild(
						<{pf}>{StringUtils.unNull(records[i][SodID])}</{pf}>
					);
					
					tmp.appendChild(<{subIDId}>{StringUtils.unNull(records[i][subIDId])}</{subIDId}>);
					
				}else{
					for each (var name:String in subDao.getColsOutgoing()) {
						
						
						
						if (name=="DummySiebelRowId")
							continue;
						//if (obj[name] == null) continue;
						var val:String = StringUtils.unNull(records[i][name]);
						
						if (oper=='insert') {
							if (name==subIDId || val=='')
								continue;
							//warningHandler(_("trying to fix NULL value in {1} subrecord {2}", entity, sub), null);
						}
						if(SodID==name){
							var ws20field:String = WSProps.ws10to20(entity,SodID);
							xml.appendChild(
								<{ws20field}>{val}</{ws20field}>
							);
						}
						if(subDao.getOutgoingIgnoreFields().contains(name)) continue;
						
						tmp.appendChild(<{name}>{val}</{name}>);
					}
				}
				
				subXML.appendChild(tmp);
				
				xml.appendChild(subXML);
				request.child(Q1ListOf)[0].appendChild(xml);
			}
			
			
 			sendRequest(URNexe,request);

		}
		override protected function handleResponse(request:XML, result:XML):int{
			var i:int = 0;
			if(oper=="delete"){
				subDao.delete_(records[0]);
				i++;
			}else{
				for each (var data:XML in result.child(Q2ListOf)[0].child(Q2Entity)) {
					var xmllist:XMLList = data.child(new QName(ns2.uri,subList));
					if (xmllist.length()==0)
						return 0;
					
					for each (var subrec:XML in xmllist[0].child(new QName(ns2.uri,subIDns))) {
						
						var changed:Boolean = false;										
						
						var rec:Object = records[i];
						
						changed = subDao.fix_sync_outgoing(rec);
						
						for each (var col:String in subDao.getCols()) {
							
							var field:XMLList = subrec.child(new QName(ns2.uri,col));
							if (field.length()>0) {
								
								var upd:String = field[0].toString();
								var old:String = rec[col];
								
								//if (upd==old) continue;
								
								changed = true;
								if (col==subIDId) {
									ReferenceUpdater.updateReferences(subDao.entity, old, upd);
								}
								rec[col] = upd;
							}
						}
						i++;
						if (changed) {
							rec.deleted = false;
							rec.local_update = null;
							rec.error = false;
							subDao.update(rec);
						}
						
					}
				}
			}
			
			_nbItems += i;
			countHandler(_nbItems);
			doRequest();
			return i;
	}
		
		override public function getEntityName():String {
			return subDao.entity;
		}
		
		override public function getName():String {
			return i18n._("Sending {1} data to server...", subDao.entity); 
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + subDao.entity;
		}			
		
		
		
	}
}