/*******************************************************************
* PendingTraining.as
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
import SoccerServerV1.TransferModel.vo.TrainingDefinition;        
	[Bindable]
	[RemoteClass(alias="SoccerServerV1.TransferModel.PendingTraining")]
	public class PendingTraining
	{
		public function PendingTraining(){}
	
		public var TrainingDefinition:SoccerServerV1.TransferModel.vo.TrainingDefinition;
		public var TimeStart:Date;
		public var TimeEnd:Date;
	}
}
