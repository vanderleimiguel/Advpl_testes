#include "protheus.ch"

/*/{Protheus.doc} M460MARK
Ponto de entrada para Valida��o de pedidos marcados 
@author Wagner Neves
@since 15/08/2023
@version 1.0
@type function
/*/
User Function M460MARK()
	Local aArea 	    := GetArea()
	Local lRet          := .T.
	Local cCliente		:= SC9->C9_CLIENTE
	Local cCliLoja    	:= SC9->C9_LOJA

	//Busca codigo do fornecedor, atraves do cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	If SA1->(DbSeek( xFilial("SA1") + cCliente + cCliLoja ))
		cCliCGC	:= SA1->A1_CGC
		DbselectArea("SA2")
		DbSetOrder(3)
		If SA2->(DbSeek( xFilial("SA2") + cCliCGC ))
			cForCod 	:= SA2->A2_COD
			cForLoja	:= SA2->A2_LOJA
		else
			MSGSTOP("Esse faturamento AFC. O cliente n�o est� cadastrado como Fornecedor para que o t�tulo seja gerado.";
				+ " Para emiss�o da nota fiscal, esse cadastro precisa ser realizado. Favor verificar !!!", "Aten��o !!!")
			lRet    := .F.
		EndIf
		SA2->(DbCloseArea())
	else
		MSGSTOP( "N�o foi encontrado cliente na base de dados", "Aten��o" )
		lRet    := .F.
	EndIf
	SA1->(DbCloseArea())

	RestArea(aArea)
Return (lRet)
