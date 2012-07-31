/*******************************************************************
* SpecialTraining.as
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
import SoccerServerV1.TransferModel.vo.SpecialTrainingDefinition;        
	[Bindable]
	[RemoteClass(alias="SoccerServerV1.TransferModel.SpecialTraining")]
	public class SpecialTraining
	{
		public function SpecialTraining(){}
	
		public var SpecialTrainingDefinition:SoccerServerV1.TransferModel.vo.SpecialTrainingDefinition;
		public var EnergyCurrent:int;
		public var IsCompleted:Boolean;
	}
}
