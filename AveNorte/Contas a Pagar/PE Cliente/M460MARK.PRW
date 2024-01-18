#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ`ÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460MARK  ºAutor  ³Totvs Cascavel      º Data ³  27/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada executado na marcação de cargas\pedidos de º±±
±±º          ³venda para faturamento junto as rotinas de faturamento.     º±±
±±º          ³Utilizado para validações adicionais em torno do faturamentoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Avenorte                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M460MARK()

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local cMarca		:= PARAMIXB[1]
	Local cCliente		:= SC9->C9_CLIENTE
	Local cCliLoja    	:= SC9->C9_LOJA
	Local cPedido 		:= SC9->C9_PEDIDO
	Local cQuery    	:= ""
	Local nTotAFC		:= 0
	Local nValAFC		:= 0
	Local cAlias 		:= GetNextAlias()

//                                            ^
//                                            |
/*Implemente o ponto de entrada antes da chamada do Bloco de Função do Gestão de Cereais....*/
//************************************************************************************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Específico para ser utilizado pelo Gestão de Cereais 																						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If lRet .AND. ExistBlock("xM460MARKB")
		lRet := ExecBlock("xM460MARKB", .F., .F., cMarca)
	EndIf

//************************************************************************************************************************************
	//Verifica se possui RAPEL
	cQuery := " SELECT C6_NUM, C6_CLI, C6_XVLTAFC "
	cQuery += " FROM "+RetSqlName('SC6')+" SC6 "
	cQuery += " WHERE C6_NUM = '"+cPedido+"'"
	cQuery += " AND C6_CLI = '"+cCliente+"'"
	cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
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

Return lRet
