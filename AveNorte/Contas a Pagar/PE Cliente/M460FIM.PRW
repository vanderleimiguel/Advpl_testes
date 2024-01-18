#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM  º Autor ³ Totvs Cascavel      º Data ³  27/02/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada ao finalizar inclusão da NFS              º±±
±±º          ³ Selecionando portador para amarraçao SE1, impress. Boleto  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Avenorte                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M460FIM()
	Local aArea     	:= GetArea()
	Local cCliente		:= SF2->F2_CLIENTE
	Local cNFiscal		:= SF2->F2_DOC
	Local cSerie		:= SF2->F2_SERIE
	Local cCliLoja    	:= SF2->F2_LOJA
	Local cEmissao      := SF2->F2_EMISSAO
	Local cFil  		:= SF2->F2_FILIAL
	Local cForCod		:= ""
	Local cForLoja      := ""
	Local cForNome      := ""
	Local cCliCGC       := ""
	Local cPrefixo      := "AFC"
	Local nTotAFC       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Gravação do % RAPEL Desconto a ser concedido até o vencimento ³
//³de acordo com o Cadastro do Cliente.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if ISINCALLSTACK("MATA410") .or. ISINCALLSTACK("MATA460A") .or. ISINCALLSTACK("MATA460B") .or. ISINCALLSTACK("MAPVLNFS")
		if SF2->F2_TIPO == 'N' .and. !empty(SA1->A1_X_RAP)

			dbselectarea("SE1")
			SE1->(dbSetOrder(2))
			SE1->(dbgotop())
			if dbseek(xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DOC)
				while SE1->(!eof()) .and. SE1->E1_FILIAL == SF2->F2_FILIAL .and. SE1->E1_CLIENTE == SF2->F2_CLIENTE;
						.and. SE1->E1_PREFIXO == SF2->F2_PREFIXO .and. SE1->E1_NUM == SF2->F2_DOC
					reclock("SE1", .F. )
					SE1->E1_X_RAP 	 := SA1->A1_X_RAP
					SE1->E1_DESCFIN  := SA1->A1_X_RAP
					SE1->E1_DIADESC  := 0
					SE1->E1_TIPODES  := '1' //Fixo
					SE1->(msunlock())

					SE1->(dbskip())
				enddo
			endif
		elseif SC5->C5_TIPO == 'B' .and. !empty(SC5->C5_X_LOTE)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³ Remessas Mtech                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if ExistBlock("MTECHXPE")
				U_MTECHXPE("M460FIM",SC5->C5_X_LOTE)
			endif
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Função verificando se o pedido foi faturado parcialmente para ajuste de legenda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		xFatParc(SF2->F2_DOC, SF2->F2_SERIE)

	endif
//                                            ^
//                                            |
/*Implemente o ponto de entrada antes da chamada do Bloco de Função do ADD-ON de CNAB Receber */
//************************************************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Específico para ser utilizado pelo ADD-ON de CNAB Receber                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ExistBlock("P003A01")
		If !(SC5->C5_TIPO $ 'D/B') .AND. SC5->C5_TIPOCLI <> 'X'
			U_P003A01('M460FIM',SF2->F2_DOC,SF2->F2_SERIE)
		EndIf
	EndIf


//                                            ^
//                                            |
/*Implemente o ponto de entrada antes da chamada do Bloco de Função do Gestão de Cereais....*/
//************************************************************************************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Específico para ser utilizado pelo Gestão de Cereais 																			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ExistBlock("xM460FIM")
		ExecBlock("xM460FIM", .F., .F.)
	EndIf

//************************************************************************************************************************************
	//Geracao de RAPEL
	//Busca Valor Total AFC
	nTotAFC	:= TotalAFC(cNFiscal, cSerie)

	If nTotAFC <> 0
		//Busca codigo do fornecedor, atraves do cliente
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek( xFilial("SA1") + cCliente + cCliLoja ))
			cCliCGC	:= SA1->A1_CGC
			SA2->(DbSetOrder(3))
			If SA2->(DbSeek( xFilial("SA2") + cCliCGC ))
				cForCod 	:= SA2->A2_COD
				cForLoja	:= SA2->A2_LOJA
				cForNome    := SA2->A2_NREDUZ

				//Grava Contas a Pagar
				GravSE2(cFil, cNFiscal, cSerie, cEmissao, nTotAFC, cForCod, cPrefixo, cForLoja, cForNome)

				//Grava Flag de confirmação de geração do contas a pagar
				SE2->(DbSetOrder(6))
				If SE2->(DbSeek( cFil + cForCod + cForLoja + cPrefixo + cNFiscal ))//FORNECEDOR E LOJA
					DbSelectArea("SF2")
					RecLock("SF2", .F.)
					SF2->F2_XFLGAFC	:=  "AFC" + cNFiscal
					SF2->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return

Static Function xFatParc(cNota, cSerie)
	Local aArea 	:= GetArea()
	Local cQuery 	:= ""
	Local cPedid	:= Posicione("SD2", 3, xFilial("SD2") + cNota + cSerie, "D2_PEDIDO")

	cQuery := "SELECT C6_NUM, C6_ITEM, C6_QTDVEN, C6_QTDENT, "
	cQuery += "C6_NOTA, C6_SERIE, (C6_QTDVEN - C6_QTDENT) ENTRG "
	cQuery += "FROM "+RetSqlName("SC6") + " C6 "
	cQuery += "WHERE C6.D_E_L_E_T_=' ' "
	cQuery += "AND C6_NUM='" + cPedid + "'"

	If (Select("XFATPARC") <> 0)
		dbSelectArea("XFATPARC")
		dbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "XFATPARC"

	dbSelectArea("XFATPARC")
	XFATPARC->(dbGoTop())

	While XFATPARC->(!EOF())

		If XFATPARC->ENTRG <> 0
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))

			If SC5->(dbSeek(xFilial("SC5") + XFATPARC->C6_NUM))
				RecLock("SC5",.F.)
				SC5->C5_BLQ := '9'
				SC5->(MsUnLock())
				Exit
			EndIf

		EndIf
		XFATPARC->(dbSkip())

	EndDo
	RestArea(aArea)
Return


/*---------------------------------------------------------------------*
 | Func:  GravSE2                                                      |
 | Desc:  Função que grava Dados na SE2                                |
 *---------------------------------------------------------------------*/
Static Function GravSE2(_cFil, _cNFiscal, _cSerie, _cEmissao, _nTotAFC, _cForCod, _cPrefixo, _cForLoja, _cForNome)
	
	DbSelectArea("SE2")
    RecLock("SE2", .T.)	

	SE2->E2_FILIAL      := _cFil
	SE2->E2_PREFIXO		:= _cPrefixo
	SE2->E2_NUM         := _cNFiscal	
	SE2->E2_TIPO		:= "AFC"
	SE2->E2_NATUREZ		:= "21020315"
	SE2->E2_FORNECE		:= _cForCod
	SE2->E2_LOJA		:= _cForLoja
	SE2->E2_NOMFOR      := _cForNome
	SE2->E2_EMISSAO		:= _cEmissao
	SE2->E2_VENCTO		:= _cEmissao
	SE2->E2_VENCREA		:= _cEmissao
	SE2->E2_VALOR		:= _nTotAFC
	SE2->E2_DATALIB     := CTOD("  /  /  ")
	SE2->E2_EMIS1       := _cEmissao
	SE2->E2_HIST       	:= "ACORDO COML. REF NF " + AllTrim(_cNFiscal) + "-" + AllTrim(_cSerie)	
	SE2->E2_SALDO       := _nTotAFC
	SE2->E2_VENCORI     := _cEmissao
	SE2->E2_MOEDA		:= 1
	SE2->E2_RATEIO      := "N"
	SE2->E2_VLCRUZ		:= _nTotAFC	
	SE2->E2_OCORREN     := "01"
	SE2->E2_ORIGEM     := "MATA460"
	SE2->E2_FLUXO       := "S"
	SE2->E2_DESDOBR     := "N"
	SE2->E2_MULTNAT     := "2"
	SE2->E2_PROJPMS     := "2"
	SE2->E2_DIRF        := "2"
	SE2->E2_MODSPB      := "1"
	SE2->E2_FILORIG     := _cFil
	SE2->E2_PRETPIS     := "1"
	SE2->E2_PRETCOF     := "1"
	SE2->E2_PRETCSL     := "1"
	SE2->E2_BASEPIS     := _nTotAFC
	SE2->E2_BASECSL     := _nTotAFC
	SE2->E2_MDRTISS     := "1" 
	SE2->E2_FRETISS 	:= "1" 
	SE2->E2_APLVLMN     := "1" 
	SE2->E2_TRETISS 	:= "2" 
	SE2->E2_BASEISS     := _nTotAFC
	SE2->E2_TEMDOCS 	:= "2" 
	SE2->E2_DATAAGE     := _cEmissao
	SE2->E2_BASEIRF 	:= _nTotAFC
	SE2->E2_BASECOF     := _nTotAFC
	SE2->E2_STATLIB     := "01"
	SE2->E2_BASEINS     := _nTotAFC 
	SE2->E2_TPDESC      := "C" 

	SE2->(MsUnLock())

Return

/*---------------------------------------------------------------------*
 | Func:  TotalAFC                                                     |
 | Desc:  Função que Soma dados do campo AFC                           |
 *---------------------------------------------------------------------*/
Static Function TotalAFC(_cNFiscal, _cSerie)
	Local aArea 	:= GetArea()
	Local cQuery    := ""
	Local _nTotAFC	:= 0
	Local nValAFC	:= 0
	Local cAlias 	:= GetNextAlias()
    
	cQuery := " SELECT C6_NOTA, C6_SERIE, C6_XVLTAFC "
    cQuery += " FROM "+RetSqlName('SC6')+" SC6 "
    cQuery += " WHERE C6_NOTA = '"+_cNFiscal+"'"
    cQuery += " AND C6_SERIE = '"+_cSerie+"'"
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
		_nTotAFC	:= _nTotAFC + nValAFC
		(cAlias)->(DbSkip())
	EndDo

	RestArea(aArea)
Return (_nTotAFC)



