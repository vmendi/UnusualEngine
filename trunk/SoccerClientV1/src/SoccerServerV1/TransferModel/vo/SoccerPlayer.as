/*******************************************************************
* SoccerPlayer.as
* Copyright (C) 2006-2010 Midnight Coders, Inc.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
* WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
********************************************************************/

package SoccerServerV1.TransferModel.vo
{
	import flash.utils.ByteArray;
	import mx.collections.ArrayCollection;
        
	[Bindable]
	[RemoteClass(alias="SoccerServerV1.TransferModel.SoccerPlayer")]
	public class SoccerPlayer
	{
		public function SoccerPlayer(){}
	
		public var SoccerPlayerID:int;
		public var Name:String;
		public var Number:int;
		public var Type:int;
		public var FieldPosition:int;
		public var Weight:int;
		public var Sliding:int;
		public var Power:int;
		public var IsInjured:Boolean;
	}
}
