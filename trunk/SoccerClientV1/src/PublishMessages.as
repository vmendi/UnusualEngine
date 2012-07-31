package
{
	import flash.external.ExternalInterface;

	public final class PublishMessages
	{
		static public const PUBLISH_MESSAGE_EXAMPLE : Object =
			{
				daUserEditableMessage: "Mahou Liga Chapas: el juego definitivo de fútbol",
				daName: "Mahou Liga Chapas (Name)",
				daDescription: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." +
							   "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/Logo100x100.png",
				daUserMessagePrompt: ""
			}

		static public const PUBLISH_MESSAGE_PARTIDOGANADO : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Victoria!",
				daDescription: "Acabo de ganar a CONTRARIO por RESULTADO. Entra ahora en Mahou Liga Chapas y tú también podrás competir en los partidos de fútbol online más emocionantes.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeVictoria.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}

		static public const PUBLISH_MESSAGE_ABANDONO : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Victoria!",
				daDescription: "CONTRARIO no ha podido soportar la tensión y ha abandonado el partido que estábamos jugando en Mahou Liga Chapas. Entra ahora y tú también podrás competir en los partidos de fútbol online más emocionantes.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeVictoria.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_SUPERPOTENCIA : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡SUPERPOTENCIA!",
				daDescription: "Con esta habilidad puede realizarse un tiro superpotente.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadSuperpotencia.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}			

		static public const PUBLISH_MESSAGE_FURIAROJA : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡FURIA ROJA!",
				daDescription: "Con esta habilidad mejora la capacidad de ataque de todos mis jugadores.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadFuriaRoja.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_CATENACCIO : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡CATENACCIO!",
				daDescription: "Con esta habilidad mejora la capacidad de defensa de todos mis jugadores.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadCatenaccio.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_TIROAGOL : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡TIRO A GOL!",
				daDescription: "Con esta habilidad llegan a gol los tiros realizados desde el campo propio.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadTiroAGol.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_TIEMPOEXTRA : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡TIEMPO EXTRA!",
				daDescription: "¡Básico! Con esta habilidad se dispone de más tiempo en los turnos.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadTiempoExtra.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_TIROEXTRA : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡TIRO EXTRA!",
				daDescription: "Con esta habilidad dispongo de un tiro extra en mi turno: esencial en los partidos igualados.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadTiroExtra.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_5ESTRELLAS : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡5 ESTRELLAS!",
				daDescription: "Gracias a esta habilidad todos mis jugadores son mucho más precisos. Una gran ventaja.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidad5Estrellas.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_VERAREAS : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡VER ÁREAS!",
				daDescription: "Con esta habilidad puedo descubrir el área de influencia de los jugadores del equipo contrario. Una gran ventaja frente a tu oponente.",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadVerAreas.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public const PUBLISH_MESSAGE_MANODEDIOS : Object =
			{
				daUserEditableMessage: "",
				daName: "¡Nueva habilidad conseguida: ¡MANO DE DIOS!",
				daDescription: "Gracias a esta habilidad será mucho más fácil marcar goles a mis oponentes ¿te atreves a comprobarlo?",
				daImgSrc: "http://mahouligachapas.unusualwonder.com/SoccerClientV1/Imgs/MensajeHabilidadManoDeDios.jpg",
				daUserMessagePrompt: "Mahou Liga Chapas: el juego definitivo de fútbol"
			}
			
		static public function Publish(publishMessage : Object) : void
		{
			ExternalInterface.call("streamPublish", publishMessage.daUserEditableMessage, 
													publishMessage.daName, 
													publishMessage.daDescription, 
													publishMessage.daImgSrc, 
													publishMessage.daUserMessagePrompt);
		}		
	}
}