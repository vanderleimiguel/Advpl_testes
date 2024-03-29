#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������`���������������������������ͻ��
���Programa  �M460MARK  �Autor  �Totvs Cascavel      � Data �  27/02/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada executado na marca��o de cargas\pedidos de ���
���          �venda para faturamento junto as rotinas de faturamento.     ���
���          �Utilizado para valida��es adicionais em torno do faturamento���
�������������������������������������������������������������������������͹��
���Uso       �Especifico Avenorte                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
/*Implemente o ponto de entrada antes da chamada do Bloco de Fun��o do Gest�o de Cereais....*/
//************************************************************************************************************************************
//������������������������������������������������������������������������������������������������������������������������������������
//� Espec�fico para ser utilizado pelo Gest�o de Cereais 																						�
//������������������������������������������������������������������������������������������������������������������������������������
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
				MSGSTOP("Esse faturamento AFC. O cliente n�o est� cadastrado como Fornecedor para que o t�tulo seja gerado.";
					+ " Para emiss�o da nota fiscal, esse cadastro precisa ser realizado. Favor verificar !!!", "Aten��o !!!")
				lRet    := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
