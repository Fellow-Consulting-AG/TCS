package gadget.sync.incoming
{
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.util.Hack;
	import gadget.util.ObjectUtils;

	public class IncomingSubActivity extends IncomingSubobjects {
		
		public function IncomingSubActivity(entity:String,subid:String = "Activity") {
//			noPreSplit = true;
//			linearTask = true;
//			if (linearTask)	Hack("linearTask still true, perhaps make it false?");
			super(entity, subid);
			ignoreQueryFields.push("Owner");
		}

		override protected function getInfo(xml:XML, ob:Object):Object {
			
			
			return { rowid:ob[DAOUtils.getOracleId(subIDour)], name:ObjectUtils.joinFields(ob, DAOUtils.getNameColumns(subIDour)) }
			
		}
		
		override protected function initXMLsub(baseXML:XML, qapp:XML):void {
			var qsublist:QName=new QName(ns1.uri,subList), qsub:QName=new QName(ns1.uri,subIDns);
			qapp = qapp.child(qsublist)[0].child(qsub)[0];			
			for each (var field:Object in Database.fieldDao.listFields(subIDsod)) {
				if (ignoreQueryFields.indexOf(field.element_name)<0) {
					qapp.appendChild(new XML("<" + WSProps.ws10to20(subIDsod, field.element_name) + "/>"));
				}
			}
		}
	}
}
