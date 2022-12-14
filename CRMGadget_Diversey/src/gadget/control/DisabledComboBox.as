package gadget.control
	
{
	import mx.controls.ComboBox;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	
	
	public class DisabledComboBox extends ComboBox
	{
		
		/** constructor **/
		public function DisabledComboBox()
		{
			super();
			this.dropdownFactory = new ClassFactory(DisabledList);
			this.itemRenderer = new ClassFactory(DisabledListItemRenderer);
		} 
		
		override public function set dataProvider(value:Object):void
		{        
			super.dataProvider = value;
			moveToEnable();
		}
		
		private function moveToEnable():void 
		{
			var i:int = -1;  
			
			for each (var obj:Object in dataProvider) 
			{
				i++;
				if (this.selectedIndex == -1) 
				{
					this.selectedIndex = 0;
				}
				
				if (i < this.selectedIndex) 
				{
					continue;
				}
				
				if (obj != null && ((obj is XML && obj.@enabled == 'false') || obj.enabled==false || obj.enabled=='false'))
				{                       
					if(i == this.selectedIndex)
					{
						this.selectedIndex++;
					}
				}
			}
			
			if (this.selectedIndex > i) 
			{
				this.selectedIndex = 0;
			}
		}
		
		override public function initialize():void
		{
			this.toolTip = this.text;    
			
			if (initialized) 
			{
				return;
			}
			
			createChildren();
			
			super.initialize();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.toolTip = this.text;
		}
		
		private function textInput_valueCommitHandler(event:FlexEvent):void 
		{
			super.text = textInput.text;
			dispatchEvent(event);
		}
		
		private function textInput_enterHandler(event:FlexEvent):void
		{
			dispatchEvent(event);
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}     
	}
}