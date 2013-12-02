package weave.visualization.tools
{
	import weave.Weave;
	import weave.api.WeaveAPI;
	import weave.api.data.ColumnMetadata;
	import weave.api.data.IAttributeColumn;
	import weave.api.data.IKeySet;
	import weave.api.data.IQualifiedKey;
	import weave.api.linkBindableProperty;
	import weave.api.registerLinkableChild;
	import weave.api.newLinkableChild;
	import weave.api.ui.IVisTool;
	import weave.core.LinkableNumber;
	import weave.core.LinkableString;
	import weave.core.LinkableBoolean;
	import weave.core.LinkableDynamicObject;
	import weave.core.LinkableVariable;
	import weave.core.SessionManager;
	import weave.data.AttributeColumns.DynamicColumn;
	import weave.data.KeySets.FilteredKeySet;
	import weave.data.KeySets.KeyFilter;
	import weave.data.KeySets.KeySet;
	import flash.external.ExternalInterface;

	public class ExternalTool extends LinkableDynamicObject
	{
		private var _toolName:String;
		private var _toolReady:Boolean = false;
		public const toolState:LinkableVariable = newLinkableChild(this, LinkableVariable, sendStateChange);
		public function ExternalTool(toolName:String, toolUrl:String)
		{
			_toolName = WeaveAPI.CSVParser.createCSVRow((WeaveAPI.SessionManager as SessionManager).getPath(WeaveAPI.globalHashMap, this));
		}
		public function launch(url:String):void
		{
			var windowFeatures:String = "menubar=no,status=no,toolbar=no";
			ExternalInterface.call(
				"function (weaveID, toolname, url, features) {\
				 var weave = weaveID ? document.getElementById(weaveID) : document;\
				 if (weave.external_tools == undefined) weave.external_tools = {};\
				 weave.external_tools[toolname] = window.open(url, toolname, features);\
				}", ExternalInterface.objectID, _toolName, url, windowFeatures);
		}


		public function callMethod(methodname:String, parameters:Array):void
		{
			if (!_toolReady) weaveTrace("ExternalTool " + _toolName + " was accessed, but was not ready yet.");
			ExternalInterface.call(
					"function (weaveID, toolname, methodname, parameters) {\
						var weave = weaveID ? document.getElementById(weaveID) : document;\
						weave.external_tools[toolname][methodname].apply(this, parameters);\
						}", ExternalInterface.objectID, _toolName, methodname, parameters);
		}
		public function focus():void
		{
			callMethod("focus", null);
			return;
		}
		public function probe(qkeys:Array):void
		{
			callMethod("probe",  qkeys);
			return;
		}
		public function select(qkeys:Array):void
		{
			callMethod("select", qkeys);
			return;
		}
		public function subset(qkeys:Array):void
		{
			callMethod("subset", qkeys);
			return;
		}
		public function ready(qkeys:Array):void
		{
			weaveTrace("ExternalTool " + _toolName + " ready.");
			_toolReady = true;
			return;
		}
		public function error(message:String):void
		{
			weaveTrace("ExternalTool error from " + _toolName + ": " + message);
			return;
		}
		public function sendStateChange():void
		{
			callMethod("update_state", [this.toolState.getSessionState()]);
			return;
		}
		public function update_state(obj:Object):void
		{
			this.toolState.setSessionState(obj);
			return;
		}
	}
}