package gadget.sync
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	import gadget.dao.ErrorLoggingDAO;
	import gadget.service.LocaleService;
	import gadget.service.UserService;
	import gadget.sync.group.IncomingParallelTaskGroup;
	import gadget.sync.group.TaskGroupBase;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.JDIncomingObject;
	import gadget.sync.incoming.JDIncomingPlant;
	import gadget.sync.incoming.JDIncomingServiceRequest;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.sync.outgoing.JDUpdateServiceRequest;
	import gadget.sync.outgoing.OutgoingAttachment;
	import gadget.sync.outgoing.OutgoingGCalendarDelete;
	import gadget.sync.outgoing.OutgoingGCalendarUpdate;
	import gadget.sync.task.WebServiceBase;
	import gadget.sync.tasklists.DeletionTasks;
	import gadget.sync.tasklists.IncomingPerIdTasks;
	import gadget.sync.tasklists.IncomingSubObjTasks;
	import gadget.sync.tasklists.IncomingTasks;
	import gadget.sync.tasklists.InitializationTasks;
	import gadget.sync.tasklists.JDIncomingChangeOwnerTasks;
	import gadget.sync.tasklists.OutgoingSubTasks;
	import gadget.sync.tasklists.OutgoingTasks;
	import gadget.util.DateUtils;
	import gadget.util.SilentOOPS;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;
	
	public class SyncProcess {
		
		private var _full:Boolean;
		private var _metaSyn:Boolean;
		private var _logInfo:Function;
		private var _logProgress:Function;
		private var _eventHandler:Function;
		private var _fieldComplete:Function;
		
		private var _hasErrors:Boolean;
		private var _hasWarnings:Boolean;
		private var _progress:int;
		private var _finished:Boolean;
		private var _showFinishMsg:Boolean=true;
		private var _logs:ArrayCollection;
		
		private var _groups:ArrayCollection;		// WS1.0 firstrun
		private var _end:Array;
		private var isFieldChange:Boolean;
		private var _isStopped:Boolean;
		
		
		public function SyncProcess(full:Boolean,metaSyn:Boolean,isParalleProcessing:Boolean=false,isSRSynNow:Boolean=false,records:Array=null,checkConflicts:Array=null) {
			_full = full;	
			_metaSyn = metaSyn;
			_hasErrors = false;
			_hasWarnings = false;
			_isStopped = false;
			_progress = 0;
			_logs = new ArrayCollection();
			_groups = new ArrayCollection();
			if(!isSRSynNow){
				
				if(checkConflicts!=null){
					_showFinishMsg=false;
					_groups.addItem(new TaskGroupBase(
						this,
						checkConflicts,	
						_full
						,_metaSyn
					));
				}else{								
					_groups.addItem(new TaskGroupBase(
						this,
						InitializationTasks(_metaSyn,_full),
						_full // true,  // VAHI changed this to always do it, which is better but incorrect as well
						,_metaSyn
					));					
					if(_metaSyn){  // Sync only Metadata. get only a full sync on the meta data(field management,Picklist,)
						return;
					}	
					
					//add check owner change
					addSeriaTask(JDIncomingChangeOwnerTasks(),TaskGroupBase);
					
					//get car stock from odd before update to ood(replace from ood if has any update)
					addSeriaTask([new IncomingObject(Database.customObject9Dao.entity)],IncomingParallelTaskGroup);
					
					//Deleted items to google calendar
					if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0)
						_groups.addItem(new OutgoingGCalendarDelete());
			
					_groups.addItem(new TaskGroupBase(
						this,
						DeletionTasks(),
						_full
						,_metaSyn
					));
			
					
					
					//Update items to google calendar
					if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0){
						_groups.addItem(new OutgoingGCalendarUpdate());
					}
					//bug #6570
					_groups.addItem(new TaskGroupBase(	
						this,
						[new OutgoingAttachment(Database.serviceDao.entity)],
						_full
						,_metaSyn
					));

					_groups.addItem(new TaskGroupBase(	//VAHI Parallel with OutgoingTaskGroup, but it cannot run parallely
						this,
						OutgoingTasks(),
						_full
						,_metaSyn
					));
						
					var outAtts:Array = OutgoingSubTasks();
					if(outAtts.length>0){
						_groups.addItem(new TaskGroupBase(	
							this,
							outAtts,
							_full
							,_metaSyn
						));
					}

					_groups.addItem(new IncomingParallelTaskGroup( // Modification tracking
						this,
						[new ModificationTracking(),new IncomingObject(Database.bookDao.entity)],
						_full
						,_metaSyn,true
					));
						//for jd user only
					addProductAndPlantTask();
					addCO1CO2AndServiceRequest(); //6790 cRO get CO1 & CO2 by service request 
					
					
					
		//				var task:Class;
					if(!isParalleProcessing){
		//				task=IncomingParallelTaskGroup;
						addSeriaTask(IncomingTasks(),IncomingParallelTaskGroup);						
						addSeriaTask(IncomingPerIdTasks(),IncomingParallelTaskGroup);
						addSeriaTask(IncomingSubObjTasks(_full),IncomingParallelTaskGroup);
							
					}else{
						
						addParallelTask(IncomingTasks());						
						addParallelTask(IncomingPerIdTasks());
						addParallelTask(IncomingSubObjTasks(_full));					
					}					

				}
				
			}else{
				
				//bug#1969
				addSeriaTask([new JDIncomingObject(Database.serviceDao.entity,new ArrayCollection(records))],TaskGroupBase);
				_groups.addItem(new TaskGroupBase(
					this,
					[new JDUpdateServiceRequest(records)],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
					_full
					,_metaSyn
				));
			}
			
		}
		
		private function addSeriaTask(listTask:Array, cls:Class):void{
			if(listTask==null || listTask.length<1){
				return;
			}
			for each(var incomingTask:WebServiceIncoming in listTask){
				if(cls == IncomingParallelTaskGroup){
					_groups.addItem(new cls(
						this,
						[incomingTask],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,false
					));
				}else{
					_groups.addItem(new cls(
						this,
						[incomingTask],	
						_full
						,_metaSyn
					));
				}
				
			}
		}
		//6790 cRO
		private function addCO1CO2AndServiceRequest():void{
			//add imcoming product task and plant
			if(UserService.DIVERSEY==UserService.getCustomerId()){
				var transaction:Object = Database.transactionDao.find(Database.serviceDao.entity);
				if(transaction.enabled == 1){
					_groups.addItem(new IncomingParallelTaskGroup(
						this,
						[new JDIncomingServiceRequest(Database.serviceDao.entity)],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,true
					));					
				}
				
			}
		}
		
		private function addProductAndPlantTask():void{
			//add imcoming product task and plant
			if(UserService.DIVERSEY==UserService.getCustomerId()){
				var transaction:Object = Database.transactionDao.find(Database.productDao.entity);
				if(transaction.enabled == 1){
					_groups.addItem(new IncomingParallelTaskGroup(
						this,
						[new JDIncomingPlant(Database.customObject3Dao.entity)],	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,true
					));					
				}
				
			}
		}
		private function addParallelTask(listTask:Array):void{
			
			if(listTask==null || listTask.length<1){
				return;
			}
			var i:int=1;
			var limitTask:Array=new Array();
			for each(var incomingTask:WebServiceIncoming in listTask){
				if(i==3){
					limitTask.push(incomingTask);
					_groups.addItem(new IncomingParallelTaskGroup(
						this,
						limitTask,	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
						_full
						,_metaSyn,true
					));
					limitTask=new Array();
					i=1;
					
				}else{
					limitTask.push(incomingTask);
					i++;
				}
				
			}
			if(listTask.length>1){
				_groups.addItem(new IncomingParallelTaskGroup(
					this,
					limitTask,	// fetch the list of objects to sync, they are automatically not processed in GroupB (bisect) below
					_full
					,_metaSyn,true
				));
			}
		}
	
		
		public function bindFunctions(logInfo:Function, logProgress:Function, logCount:Function, eventHandler:Function, end:Array, fieldComplete:Function):void {
			_logInfo = logInfo;
			_logProgress = logProgress;
			_end = end;
			_fieldComplete = fieldComplete;

			for (var i:int = 0; i < _groups.length; i++) {
				_groups[i].bindFunctions(doLog, doLogProgress, logCount, eventHandler, nextGroup);
			}
		}

		public function start():void {
			Database.errorLoggingDao.delete_all();
			if(_metaSyn){
				Database.lastsyncDao.unsync("gadget.sync.incoming::AccessProfileService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::FieldManagementService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::CustomRecordTypeService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::IncomingSalesProcess");
				Database.lastsyncDao.unsync("gadget.sync.incoming::RoleService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::GetFields");
				Database.lastsyncDao.unsync("gadget.sync.incoming::ReadPicklist");
				Database.lastsyncDao.unsync("gadget.sync.incoming::PicklistService");
				Database.lastsyncDao.unsync("gadget.sync.incoming::ReadCascadingPicklists");
			}else if (_full) {
				// Clear out old records which perhaps disturb the GUI
				Database.lastsyncDao.unsync_all();
			}
			_groups[0].start();
 		}
 		
 		public function stop():void {
 			_isStopped = true;
			_hasErrors	= false;	//VAHI Will be set again within .stop()

			for each (var _group:Object in _groups) {
				//when user click stop ==> error for my task
				_group.stop();
			}

			if (!_hasErrors)	//VAHI always tell user about the abort
				doLog(new LogEvent(LogEvent.ERROR, "Sync aborted by user"));
			//_hasErrors always is true now
 		}
 		
		private function nextGroup(finished:Object):void {
			var index:int = _groups.getItemIndex(finished);			
			if (index == 0) {
				_fieldComplete();
			}
			if(!_isStopped && index+1 < _groups.length) {
				_groups[index+1].start();
			} else {
				groupEnd();
			}
		}
 		private function groupEnd():void {
			LocaleService.reset();
			if(Database.preferencesDao.getValue("log_files")=="1"){
				
				var fileName:String =Database.preferencesDao.getValue("log_fileName") as String;				
				if(fileName =="" || fileName==null){
					fileName = "log_" + DateUtils.getCurrentDateAsSerial();
				}
				//-- V M -- write log file to  db directory
				var byteArr:ByteArray = new ByteArray();
				byteArr.writeUTFBytes(unescape(Database.errorLoggingDao.dumpOnlyError().substr(0,5000)));
				var file:File = File.userDirectory.resolvePath(fileName +".txt");				
				var newFile:FileStream = new FileStream();
				newFile.open( file, FileMode.WRITE );
				newFile.writeBytes(byteArr);
				newFile.close();
				
			}
			if(_showFinishMsg){
				if (_isStopped || _hasErrors) {
					doLog(new LogEvent(LogEvent.ERROR, "There had been errors"));
				} else if (_hasWarnings) {
					doLog(new LogEvent(LogEvent.WARNING, "Synchronization was successful. There had been warnings"));
				} else {
					doLog(new LogEvent(LogEvent.SUCCESS, "Synchronization was successful"));
				}
				if(isFieldChange){
					doLog(new LogEvent(LogEvent.INFO, "Translation changes will take effect when you restart the application"));
				}
				saveSyncLogs();
			}			
			_finished = true;
			for each (var f:Function in _end) {
				f();
			}
		}
		//#563 CRO
 		private function saveSyncLogs():void{
			var strLogs:String="";
			
			for each(var l:Object in _logs){
				
				strLogs += DateUtils.format(l.date, "DD.MM.YYYY JJ:NN:SS") + " - [" +LogEvent.LOGTYPE[l.type] +"] - "+ l.text + "\n";
				
			}
  			Database.errorLoggingDao.add(null,{"Synchronize logs":strLogs});
		}
		private function doLog(log:LogEvent):void {
			SilentOOPS('=log',log.date.toUTCString(),log.type,log.text,StringUtils.toString(log.event));
			if (log.type == LogEvent.FATAL) {
				_hasErrors = true;
			} else if (log.type == LogEvent.ERROR) {
				_hasErrors = true;
			} else if (log.type == LogEvent.WARNING) {
				_hasWarnings = true;
			}
			_logs.addItem(log);
			if (_logInfo != null) {
				_logInfo(log);
			}
			if (log.type == LogEvent.FATAL) {
				stop();
			}
		}
		
		private function doLogProgress():void {
			_progress = 0;
			for each (var _group:Object in _groups) {
				if(_group is OutgoingGCalendarUpdate || _group is OutgoingGCalendarDelete)
					_progress += 100;
				else
					_progress += _group.progress;
			}
			_progress /= _groups.length;
			if (_logProgress != null) {
				_logProgress();
			}
		}
		
		
		public function setIsFieldChange(_isFieldChange:Boolean):void{
			if(!isFieldChange){
				this.isFieldChange = _isFieldChange;
			}			
		}
		public function get progress():int {
			return _progress;
		}
		
		public function get finished():Boolean {
			return _finished;
		}
		public function get isStopped():Boolean{
			return _isStopped;
		}
		public function get hasErrors():Boolean {
			return _hasErrors;
		}
		
		
		public function get logs():ArrayCollection {
			return _logs;
		}
		
	
	}

}
