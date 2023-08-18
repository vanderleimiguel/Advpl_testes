#include "protheus.ch"

/*/{Protheus.doc} M460FIM
Ponto de entrada para gravar dados após a gravação da nota fiscal 
@author Wagner Neves
@since 15/08/2023
@version 1.0
@type function
/*/
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
			EndIf
		EndIf

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
    cQuery += " FROM "+RetSqlName('SC6')+" SC6"
    cQuery += " WHERE C6_NOTA = '"+_cNFiscal+"'"
    cQuery += " AND C6_SERIE = '"+_cSerie+"'"
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
		_nTotAFC	:= _nTotAFC + nValAFC
		(cAlias)->(DbSkip())
	EndDo

	RestArea(aArea)
Return (_nTotAFC)
