#include 'protheus.ch'

/*/{Protheus.doc} MA080VLD
Ponto de entrada Validar os dados do TES antes que sejam gravados.
@author Wagner Neves
@since 29/08/2023
@version 1.0
@type function
/*/
User Function MA080VLD()
	Local lRet      := .T.
	Local cBenef    := M->F4_XCBENEF
	Local cCodAju   := M->F4_XCODAJU
	Local cCodRef   := M->F4_XCODREF

	//Verifica se possui a flag Relacionamento TES
	If cBenef   == "S"
		If Empty(cCodAju) .OR. Empty(cCodRef)
			MSGSTOP( "TES com Relacionamento TES x Val.Declaratórios selecionado, necessario preencher campos Cod. Reflexo e Cod. Val. Decl", "Bloqueio" )
			lRet := .F.
		EndIf
	EndIf

Return lRet
