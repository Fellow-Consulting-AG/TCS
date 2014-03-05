package gadget.sync.incoming {

	import flash.events.IOErrorEvent;
	import gadget.i18n.i18n;
	
	public class ModificationTracking extends WebServiceIncoming {
		
		public function ModificationTracking() {
			super("ModificationTracking");
		}
		
		override protected function getInfo(xml:XML, ob:Object):Object {
			
			
			return { rowid:ob.Id, name:ob.Id }
			
		}

		private var once:Boolean=true;
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, xml_list:XMLList):Boolean {
			if (!mess)
				return false;
			if (mess.indexOf("(SBL-DAT-00553)")>=0) {
				if (once)
					optWarn(i18n._("Advanced Sync not supported in this environment"));
				once = false;
				nextPage(true);
				return true;
			}
			return false;
		}
	}
}
