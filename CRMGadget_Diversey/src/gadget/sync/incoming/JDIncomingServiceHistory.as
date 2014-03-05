package gadget.sync.incoming
{
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.util.FieldUtils;
	import gadget.util.SodUtils;

	public class JDIncomingServiceHistory extends JDIncomingProduct
	{
		protected var finishFunc:Function;
		private var searchProductSpec:String='';
		public function JDIncomingServiceHistory(searchSpec:String,finishFunc:Function,entity:String='Service Request')
		{
			this.finishFunc = finishFunc;
			super(searchSpec,entity);
		}
		
		protected override function initXML(baseXML:XML):void{
			
			super.initXML(baseXML);
//			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);
//			//Add CO1 (Working Hours and Costs) and CO2 (Material Used) to query
//			for each (var sub:String in [Database.customObject1Dao.entity,Database.customObject2Dao.entity]) {
//				
//				var subName:String = sub;
//				subName	= SodUtils.transactionProperty(sub).sod_name;
//				subName	= subName.replace(/ /g,"");
//				var subDao:BaseDAO = Database.getDao(sub);
//				var tmp:XML = <{subName} xmlns={ns1}/>;
//				for each (var field:Object in FieldUtils.allFields(sub, true)) {
//					
//					if(subDao.getIncomingIgnoreFields().contains(field.element_name)){
//						continue;
//					}
//					var ws20name:String = WSProps.ws10to20(sub, field.element_name);
//					tmp.appendChild(new XML("<" + ws20name + "/>"));
//				}
//				
//				var listOfsubName:String = "ListOf"+subName;
//				stdXML.child(qlist)[0].child(qent)[0].appendChild(<{listOfsubName} xmlns={ns1}>{tmp}</{listOfsubName}>);
//			}
			
		}
		
		protected override function initBeforeSave(obj:Object):void{		
			if(entityIDour==Database.serviceDao.entity){
				var serviceId:String = obj[DAOUtils.getOracleId(entityIDour)];
				if(searchProductSpec.length>0){
					searchProductSpec=searchProductSpec+"OR";
				}
				searchProductSpec=searchProductSpec+" [ServiceRequestId] = \'"+serviceId+'\' ';
			}
		}
		
		protected override function getViewmode():String{
			return "Broadest";
		}
		
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if(finishFunc!=null){//retry by manual
				finishFunc();
			}
			return true;
		}
		
		protected override function nextPage(lastPage:Boolean):void {
			
			// As we finished a page, restore all hacks
			if (isLastPage) {
				isLastPage		= false;
				if (lastPage==false) {
					doSplit();
					return;
				}
				showCount();
				haveLastPage	= true;
				doRequest();	// Now fetch _page=0
				return;
			}
			showCount();
			if (lastPage == false) {
				_page ++;
				if (_page<SUCCESSFULLY_FAIL_UNFORCED_PAGES || param.force || isUnboundedTask) {
					doRequest();
					return;
				}
				if (!haveLastPage) {
					//VAHI This code should no more be reached, but be sure
					setFailed();		// failed success
				}
			}		
			if(searchProductSpec.length>0){
				var i:int=0;
				new JDIncomingServiceHistory(searchProductSpec,function():void{
					i++;
					if(i==2){
						if(finishFunc!=null){
							finishFunc();
						}
						
					}
				},Database.customObject1Dao.entity).start();
				new JDIncomingServiceHistory(searchProductSpec,function():void{
					i++;
					if(i==2){
						if(finishFunc!=null){
							finishFunc();
						}
						
					}
				},Database.customObject2Dao.entity).start();
					
					
			}else{				
				if(finishFunc!=null){
					finishFunc();
				}
			}
			
			
			
		}
		
	}
}