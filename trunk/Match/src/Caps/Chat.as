package Caps
{
	import Embedded.Assets;
	
	import Net.Server;
	
	import com.greensock.TweenMax;
	import com.greensock.data.TweenMaxVars;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.MovieClipMouseDisabler;

	public final class Chat extends Sprite
	{
		private const MAX_CHARS : int = 75;
		private const MAX_LINES : int = 3;
		private const LINE_HEIGHT : int = 20;
		private const TIME_BEFORE_FADEOUT : int = 5;
		private const TIME_FADEOUT : int = 1;
		
		private var mcChat : DisplayObject = null;
		private var mcOutput : DisplayObjectContainer = null;
		private var mcInput : DisplayObjectContainer = null;
		private var ctInput : TextField = null;
		
		private var mLines : Array = new Array();
		
		public function Chat()
		{
			mcChat = new Assets.ChatClass() as DisplayObject;
			addChild(mcChat);
						
			mcChat.x = 52;
			mcChat.y = 387;
			
			mcOutput = mcChat["mcOutput"];
			mcInput = mcChat["mcInput"];
			ctInput = mcChat["mcInput"]["ctInput"];
									
			ctInput.maxChars = MAX_CHARS;
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
		}
		
		private function OnAddedToStage(e:Event) : void
		{			
			removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, OnRemovedFromStage);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, OnStageKeyDown);
			
			MovieClipMouseDisabler.DisableMouse(this, true);
			mcInput.visible = false;
			
			ctInput.mouseEnabled = true;
		}

		private function OnRemovedFromStage(e:Event) : void
		{	
			removeEventListener(Event.REMOVED_FROM_STAGE, OnRemovedFromStage);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, OnStageKeyDown);
			
			for each(var line : Object in mLines)
				TweenMax.killTweensOf(line.TheTextField);
				
			mLines = null;
		}
		
		private function OnStageKeyDown(e:KeyboardEvent) : void
		{
			if (e.charCode == 13)
			{
				if (!mcInput.visible)
				{
					mcInput.visible = true;
					stage.focus = ctInput;
				}
				else
				{
					PostMessage(ctInput.text);
					mcInput.visible = false;
					ctInput.text = "";
				}
			}
			else
			if (e.charCode == 27)
			{
				if (mcInput.visible)
				{
					mcInput.visible = false;
					ctInput.text = "";
				}
			}
		}
		
		private function PostMessage(msg : String) : void
		{
			if (msg != "")
			{
				msg = Match.Ref.Game.LocalUserTeam.UserName + "> " + msg;
				Server.Ref.Connection.Invoke("OnMsgToChatAdded", null, msg);
			}
		}
		
		public function AddLine(msg:String) : void
		{
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 14;
			myFormat.bold = true;
			myFormat.font = "HelveticaNeue LT 77 BdCn"; 

			var text : TextField = new TextField();
			text.selectable = false;
			text.mouseEnabled = false;
			text.embedFonts = true;
			text.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			text.defaultTextFormat = myFormat;
			text.textColor = 0xFFFF00;
			text.text = msg;
			text.width = 800;
			
			if (mcOutput.numChildren > MAX_LINES)
			{
				TweenMax.killTweensOf(mLines[0].TheTextField);
				mcOutput.removeChild(mLines[0].TheTextField);
				mLines.shift();
			}
			
			for(var c:int=0; c < mcOutput.numChildren; ++c)
			{
				mLines[c].TheTextField.y -= LINE_HEIGHT;
			}
			
			mLines.push({ TheTextField: text });
			mcOutput.addChild(text);
			
			TweenMax.to(text, TIME_BEFORE_FADEOUT, { alpha: 1, onComplete: OnBeginFadeOut, onCompleteParams: [text] });
		}
		
		private function OnBeginFadeOut(text : DisplayObject) : void
		{
			TweenMax.to(text, TIME_FADEOUT, { alpha: 0, onComplete: OnFadeOutCompleted, onCompleteParams: [text] });
		}
		
		private function OnFadeOutCompleted(text : DisplayObject) : void
		{
			mcOutput.removeChild(text);
			
			for (var c:int=0; c < mLines.length; ++c)
			{
				if (mLines[c].TheTextField == text)
				{
					mLines.splice(c, 1);
					break;
				}
			}
		}
	}
}