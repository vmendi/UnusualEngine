/*******************************************************************
* MainService.as
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

    /***********************************************************************
    The generated code provides a simple mechanism for invoking methods
    on the SoccerServerV1.MainService class using WebORB. 
    You can add the code to your Flex Builder project and use the 
    class as shown below:

           import SoccerServerV1.MainService;
           import SoccerServerV1.MainServiceModel;

           [Bindable]
           var model:MainServiceModel = new MainServiceModel();
           var serviceProxy:MainService = new MainService( model );
           // make sure to substitute foo() with a method from the class
           serviceProxy.foo();
           
    Notice the model variable is shown in the example above as Bindable. 
    You can bind your UI components to the fields in the model object.
    ************************************************************************/
  
    package SoccerServerV1
    {
    import mx.rpc.remoting.RemoteObject;
    import mx.controls.Alert;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.AsyncToken;
    import mx.rpc.IResponder;
    import mx.collections.ArrayCollection;

    
    import SoccerServerV1.TransferModel.vo.*;
        
    public class MainService
    {
      private var remoteObject:RemoteObject;
      private var model:MainServiceModel; 

      public function MainService( model:MainServiceModel = null )
      {
        remoteObject  = new RemoteObject("GenericDestination");
        remoteObject.source = "SoccerServerV1.MainService";
        
        remoteObject.AssignSkillPoints.addEventListener("result",AssignSkillPointsHandler);
        
        remoteObject.ChangeFormation.addEventListener("result",ChangeFormationHandler);
        
        remoteObject.CreateTeam.addEventListener("result",CreateTeamHandler);
        
        remoteObject.HasTeam.addEventListener("result",HasTeamHandler);
        
        remoteObject.IsNameValid.addEventListener("result",IsNameValidHandler);
        
        remoteObject.OnError.addEventListener("result",OnErrorHandler);
        
        remoteObject.OnLiked.addEventListener("result",OnLikedHandler);
        
        remoteObject.RefreshMatchStatsForTeam.addEventListener("result",RefreshMatchStatsForTeamHandler);
        
        remoteObject.RefreshPredefinedTeams.addEventListener("result",RefreshPredefinedTeamsHandler);
        
        remoteObject.RefreshRankingPage.addEventListener("result",RefreshRankingPageHandler);
        
        remoteObject.RefreshRemainingSecondsForPendingTraining.addEventListener("result",RefreshRemainingSecondsForPendingTrainingHandler);
        
        remoteObject.RefreshSelfRankingPage.addEventListener("result",RefreshSelfRankingPageHandler);
        
        remoteObject.RefreshSelfTeamDetails.addEventListener("result",RefreshSelfTeamDetailsHandler);
        
        remoteObject.RefreshTeam.addEventListener("result",RefreshTeamHandler);
        
        remoteObject.RefreshTeamDetails.addEventListener("result",RefreshTeamDetailsHandler);
        
        remoteObject.RefreshTrainingDefinitions.addEventListener("result",RefreshTrainingDefinitionsHandler);
        
        remoteObject.SwapFormationPosition.addEventListener("result",SwapFormationPositionHandler);
        
        remoteObject.Train.addEventListener("result",TrainHandler);
        
        remoteObject.TrainSpecial.addEventListener("result",TrainSpecialHandler);
        
        remoteObject.addEventListener("fault", onFault);
        
        if( model == null )
            model = new MainServiceModel();
    
        this.model = model;

      }
      
      public function setCredentials( userid:String, password:String ):void
      {
        remoteObject.setCredentials( userid, password );
      }

      public function GetModel():MainServiceModel
      {
        return this.model;
      }


    
      public function AssignSkillPoints(soccerPlayerID:int,weight:int,sliding:int,power:int, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.AssignSkillPoints(soccerPlayerID,weight,sliding,power);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function ChangeFormation(newFormationName:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.ChangeFormation(newFormationName);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function CreateTeam(name:String,predefinedTeamID:int, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.CreateTeam(name,predefinedTeamID);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function HasTeam( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.HasTeam();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function IsNameValid(name:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.IsNameValid(name);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function OnError(msg:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.OnError(msg);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function OnLiked( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.OnLiked();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshMatchStatsForTeam(facebookID:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshMatchStatsForTeam(facebookID);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshPredefinedTeams( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshPredefinedTeams();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshRankingPage(pageIndex:int, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshRankingPage(pageIndex);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshRemainingSecondsForPendingTraining( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshRemainingSecondsForPendingTraining();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshSelfRankingPage( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshSelfRankingPage();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshSelfTeamDetails( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshSelfTeamDetails();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshTeam( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshTeam();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshTeamDetails(facebookID:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshTeamDetails(facebookID);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function RefreshTrainingDefinitions( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.RefreshTrainingDefinitions();
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function SwapFormationPosition(firstSoccerPlayerID:int,secondSoccerPlayerID:int, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.SwapFormationPosition(firstSoccerPlayerID,secondSoccerPlayerID);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function Train(trainingName:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Train(trainingName);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
    
      public function TrainSpecial(specialTrainingDefinitionID:int, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.TrainSpecial(specialTrainingDefinitionID);
        
        if( responder != null )
            asyncToken.addResponder( responder );

      }
         
      public virtual function AssignSkillPointsHandler(event:ResultEvent):void
      {
        
      }
         
      public virtual function ChangeFormationHandler(event:ResultEvent):void
      {
        
      }
         
      public virtual function CreateTeamHandler(event:ResultEvent):void
      {
        
          var returnValue:Boolean = event.result as Boolean;
          model.CreateTeamResult = returnValue;
        
      }
         
      public virtual function HasTeamHandler(event:ResultEvent):void
      {
        
          var returnValue:Boolean = event.result as Boolean;
          model.HasTeamResult = returnValue;
        
      }
         
      public virtual function IsNameValidHandler(event:ResultEvent):void
      {
        
          var returnValue:String = event.result as String;
          model.IsNameValidResult = returnValue;
        
      }
         
      public virtual function OnErrorHandler(event:ResultEvent):void
      {
        
      }
         
      public virtual function OnLikedHandler(event:ResultEvent):void
      {
        
          var returnValue:int = event.result as int;
          model.OnLikedResult = returnValue;
        
      }
         
      public virtual function RefreshMatchStatsForTeamHandler(event:ResultEvent):void
      {
        
          var returnValue:TeamMatchStats = event.result as TeamMatchStats;
          model.RefreshMatchStatsForTeamResult = returnValue;
        
      }
         
      public virtual function RefreshPredefinedTeamsHandler(event:ResultEvent):void
      {
        
          var returnValue:ArrayCollection = event.result as ArrayCollection;
          model.RefreshPredefinedTeamsResult = returnValue;
        
      }
         
      public virtual function RefreshRankingPageHandler(event:ResultEvent):void
      {
        
          var returnValue:RankingPage = event.result as RankingPage;
          model.RefreshRankingPageResult = returnValue;
        
      }
         
      public virtual function RefreshRemainingSecondsForPendingTrainingHandler(event:ResultEvent):void
      {
        
          var returnValue:int = event.result as int;
          model.RefreshRemainingSecondsForPendingTrainingResult = returnValue;
        
      }
         
      public virtual function RefreshSelfRankingPageHandler(event:ResultEvent):void
      {
        
          var returnValue:RankingPage = event.result as RankingPage;
          model.RefreshSelfRankingPageResult = returnValue;
        
      }
         
      public virtual function RefreshSelfTeamDetailsHandler(event:ResultEvent):void
      {
        
          var returnValue:TeamDetails = event.result as TeamDetails;
          model.RefreshSelfTeamDetailsResult = returnValue;
        
      }
         
      public virtual function RefreshTeamHandler(event:ResultEvent):void
      {
        
          var returnValue:Team = event.result as Team;
          model.RefreshTeamResult = returnValue;
        
      }
         
      public virtual function RefreshTeamDetailsHandler(event:ResultEvent):void
      {
        
          var returnValue:TeamDetails = event.result as TeamDetails;
          model.RefreshTeamDetailsResult = returnValue;
        
      }
         
      public virtual function RefreshTrainingDefinitionsHandler(event:ResultEvent):void
      {
        
          var returnValue:ArrayCollection = event.result as ArrayCollection;
          model.RefreshTrainingDefinitionsResult = returnValue;
        
      }
         
      public virtual function SwapFormationPositionHandler(event:ResultEvent):void
      {
        
      }
         
      public virtual function TrainHandler(event:ResultEvent):void
      {
        
          var returnValue:PendingTraining = event.result as PendingTraining;
          model.TrainResult = returnValue;
        
      }
         
      public virtual function TrainSpecialHandler(event:ResultEvent):void
      {
        
      }
    
      public function onFault (event:FaultEvent):void
      {
        Alert.show(event.fault.faultString, "Error");
      }
    }
  } 
  