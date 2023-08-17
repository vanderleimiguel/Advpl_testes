#include "protheus.ch"

/*/{Protheus.doc} M460MARK
Ponto de entrada para Validação de pedidos marcados 
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
	Local cPedido 		:= SC9->C9_PEDIDO
	Local cQuery    	:= ""
	Local nTotAFC		:= 0
	Local nValAFC		:= 0
	Local cAlias 		:= GetNextAlias()

	cQuery := " SELECT C6_NUM, C6_CLI, C6_XVLTAFC "
	cQuery += " FROM "+RetSqlName('SC6')+" SC6"
	cQuery += " WHERE C6_NUM = '"+cPedido+"'"
	cQuery += " AND C6_CLI = '"+cCliente+"'"
	cQuery += " AND SC6.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	(cAlias)->(DbGoTop())

	While (cAlias)->(!EOF())
		If (cAlias)->C6_XVLTAFC == NIL
			nValAFC := 0
		else
			nValAFC		:= (cAlias)->C6_XVLTAFC
		EndIf
		nTotAFC	:= nTotAFC + nValAFC
		(cAlias)->(DbSkip())
	EndDo

	If nTotAFC <> 0
		//Busca codigo do fornecedor, atraves do cliente
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek( xFilial("SA1") + cCliente + cCliLoja ))
			cCliCGC	:= SA1->A1_CGC
			SA2->(DbSetOrder(3))
			If !SA2->(DbSeek( xFilial("SA2") + cCliCGC ))
				MSGSTOP("Esse faturamento AFC. O cliente não está cadastrado como Fornecedor para que o título seja gerado.";
					+ " Para emissão da nota fiscal, esse cadastro precisa ser realizado. Favor verificar !!!", "Atenção !!!")
				lRet    := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return (lRet)
