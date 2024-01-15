#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} TRWRREC1
Função Relatorio de Reclassificacao
@author Wagner Neves
@since 05/01/2024
@version 1.0
@type function
/*/
User Function TRWTESTE()
	Local aArea := GetArea()

	Private cAliasCT2   := GetNextAlias()
    Private cAliasZZ1   := GetNextAlias()
	Private nTotCT2     := 0
    Private nTotZZ1     := 0
    Private cArqGera    := ""

	//Define parametros
	If !Pergunte("TRWRREC1")
		Return
	EndIf

    //Local de gravacao do arquivo csv
    cArqGera    := tFileDialog( "All Text files (*.csv) ",'Salvar Como...',,, .T., GETF_MULTISELECT ) 

    If !Empty(cArqGera)
	    //Busca dados na CT2
	    BuscaCT2()

	    //Verifica se encontrou dados na Busca
	    If nTotCT2 > 0
		    //Grava dados da query na tabela customizada
            Processa({|| nTotCT2 := GravTab()}, "")
	        //Grava dados da tabela customizada no arquivo csv
            BuscaZZ1()
            Processa({|| nTotZZ1 := GravCSV()}, "")
	    else
		    MSGSTOP( "Nao foram encontrados dados com estes parametros", "Dados nao encontrados" )
	    EndIf
    EndIf

	RestArea(aArea)

Return

/*---------------------------------------------------------------------*
 | Func:  GravTab                                                      |
 | Desc:  Funcao para gravar dados na tabela customizada ZZ1           |
 *---------------------------------------------------------------------*/
Static Function GravTab()
    Local cComCod   := ""
    Local cRefNum   := ""
    Local cGlAcco   := ""
    Local nDebAmo   := 0
    Local nCreAmo   := 0
    Local cTaxCod   := ""
    Local cCosCen   := ""
    Local cProCen   := ""
    Local cCosCod   := ""
    Local nAtual    := 0

    ProcRegua(nTotCT2)
    (cAliasCT2)->(DbGoTop())
	While !(cAliasCT2)->(EoF())
    	nAtual++
		IncProc("Copiando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotCT2) + "...")

        //Zera variaveis
        cComCod   := ""
        cRefNum   := ""
        cGlAcco   := ""
        nDebAmo   := 0
        nCreAmo   := 0
        cTaxCod   := ""
        cCosCen   := ""
        cProCen   := ""
        cCosCod   := ""

        //Procura dados de acordo com filial
        Do Case
            Case (cAliasCT2)->CT2_FILIAL = "01"
                cComCod    := "BR14"
                cProCen    := "SAO1"
            Case (cAliasCT2)->CT2_FILIAL = "02"
                cComCod    := "BR13"
                cProCen    := "RIO1"
            Case (cAliasCT2)->CT2_FILIAL = "03"
                cComCod    := "BR11"
                cProCen    := "BSB1"
            Case (cAliasCT2)->CT2_FILIAL = "04"
                cComCod    := "BR12"
                cProCen    := "POA1"
        EndCase

        //Procura dados especificos debito ou credito
        If (cAliasCT2)->CT2_DC = "1" .OR. (cAliasCT2)->CT2_DC = "3"
            cRefNum     := (cAliasCT2)->CT2_AT01DB
            nDebAmo     := (cAliasCT2)->CT2_VALOR
            cCosCod     := (cAliasCT2)->CT2_CCD
            cGlAcco     := (cAliasCT2)->CT2_DEBITO
        ElseIf (cAliasCT2)->CT2_DC = "2"
            cRefNum     := (cAliasCT2)->CT2_AT01CR
            nCreAmo     := (cAliasCT2)->CT2_VALOR
            cCosCod     := (cAliasCT2)->CT2_CCC
            cGlAcco     := (cAliasCT2)->CT2_CREDIT
        EndIf

        //Busca Conta na CT1
        CT1->(DbSetOrder(1))
        If CT1->(DbSeek(xFilial("CT1") + cGlAcco))
            cGlAcco := CT1->CT1_TKSMTT
            //Verifica Tax Code
            If SUBSTR( cGlAcco, 1, 1) = "6"
             cTaxCod    := "V0"
            EndIf
        EndIf

        //Busca Codigo SAP na CTT
        CTT->(DbSetOrder(1))
        If CTT->(DbSeek(xFilial("CTT") + cCosCod))
            cCosCen := CTT->CTT_CODSAP
        EndIf
        
        //Grava dados na ZZ1
        DbSelectArea("ZZ1")
        ZZ1->(DbGoTop())
        RecLock("ZZ1", .T.)	

        ZZ1->ZZ1_FILIAL     := (cAliasCT2)->CT2_FILIAL
	    ZZ1->ZZ1_RECIDE     := "1"
	    ZZ1->ZZ1_HEAGRO     := "100" 
	    ZZ1->ZZ1_COMCOD     := cComCod 
	    ZZ1->ZZ1_DOCDAT     := CTOD((cAliasCT2)->CT2_DATA)
	    ZZ1->ZZ1_POSDAT     := dDataBase  
	    ZZ1->ZZ1_REFNUM     := "TRANSF" + cRefNum  
	    ZZ1->ZZ1_DOCTYP     := "SA"
        ZZ1->ZZ1_CURREN     := "BRL" 
        ZZ1->ZZ1_HEATEX     := "Matter transferring"
        ZZ1->ZZ1_LEDGRO     := ""
    	ZZ1->ZZ1_RECID2     := "2"
    	ZZ1->ZZ1_LINITE     := "100"    
    	ZZ1->ZZ1_GLACCO     := cGlAcco 
    	ZZ1->ZZ1_DEBAMO     := nDebAmo
    	ZZ1->ZZ1_CREAMO     := nCreAmo  
    	ZZ1->ZZ1_TAXCOD     := cTaxCod  
    	ZZ1->ZZ1_LINTEX     := (cAliasCT2)->CT2_HIST
        ZZ1->ZZ1_ASSNUM     := ""
        ZZ1->ZZ1_COSCEN     := cCosCen
        ZZ1->ZZ1_MATNUM     := (cAliasCT2)->CT2_XMATTE
    	ZZ1->ZZ1_PROCEN     := cProCen
        ZZ1->ZZ1_COSCOD     := cCosCod     
        ZZ1->ZZ1_INTORD     := ""  
        ZZ1->ZZ1_OFFCOD     := cProCen
        ZZ1->ZZ1_TIMNUM     := "" 
        ZZ1->ZZ1_VALDAT     := CTOD("  /  /  ")  
        ZZ1->ZZ1_REFKE1     := "" 
        ZZ1->ZZ1_REFKE2     := "" 
        ZZ1->ZZ1_REFKE3     := "" 
        ZZ1->ZZ1_ACTCOD     := ""
        ZZ1->ZZ1_DTRECL     := STOD((cAliasCT2)->CT2_XDRECL)
        ZZ1->ZZ1_ENVCSV     := ""
    
        ZZ1->(MsUnLock()) 

        //Grava na CT2 que ja foi reclassificado
        CT2->( DbGoto( (cAliasCT2)->RECNO))
        RecLock("CT2", .F.)
        CT2->CT2_XRECLA := "X"
        CT2->(MsUnLock()) 

	    (cAliasCT2)->(DbSkip())
	EndDo

Return

/*---------------------------------------------------------------------*
 | Func:  GravCSV                                                      |
 | Desc:  Funcao para gravar dados no arquivo CSV                      |
 *---------------------------------------------------------------------*/
Static Function GravCSV()
    Local aHeaderCSV := {}
    Local aBodyCSV   := {}
    Local lQuebr     := .T.
    Local cTextoAux  := ""
    Local nAtual     := 0
   
    ProcRegua(nTotZZ1)
    (cAliasZZ1)->(DbGoTop())
    If (cAliasZZ1)->(!EOF())
        //Monta header do arquivo csv
        aHeaderCSV  := HeaderCSV()
        If !Empty(aHeaderCSV)
            zArrToCSV(aHeaderCSV, lQuebr, cArqGera, @cTextoAux)
            //Montar Body do CSV
            While (cAliasZZ1)->(!EOF())
                nAtual++
		        IncProc("Gravando CSV, registro " + cValToChar(nAtual) + " de " + cValToChar(nTotZZ1) + "...")
                
                aBodyCSV    := BodyCSV()
                zArrToCSV(aBodyCSV, lQuebr, cArqGera, @cTextoAux)

                //Grava na ZZ1 que ja foi reclassificado
                ZZ1->( DbGoto( (cAliasZZ1)->RECNO))
                RecLock("ZZ1", .F.)
                ZZ1->ZZ1_ENVCSV := "X"
                ZZ1->(MsUnLock()) 

                (cAliasZZ1)->(DbSkip())
            EndDo
        EndIf
        //Gera arquivo CSV
        If !Empty(cArqGera)
            MemoWrite(cArqGera, cTextoAux)
            MsgAlert("Arquivo Gerado com Sucesso!", "Gerar Relatorio")
        EndIf
    EndIf
Return

/*-------------------------------------------------------------------------------*
 | Func:  HeaderCSV                                                              |
 | Desc:  agrupa dados do header                                                 |
 *-------------------------------------------------------------------------------*/
Static Function HeaderCSV()
    Local aHeaderCSV  := {}
    Local cOrdem1, cOrdem2, cOrdem3, cOrdem4, cOrdem5, cOrdem6, cOrdem7, cOrdem8, cOrdem9, cOrdem10  := ""
    Local cOrdem11, cOrdem12, cOrdem13, cOrdem14, cOrdem15, cOrdem16, cOrdem17, cOrdem18, cOrdem19, cOrdem20  := ""
    Local cOrdem21, cOrdem22, cOrdem23, cOrdem24, cOrdem25, cOrdem26, cOrdem27, cOrdem28, cOrdem29, cOrdem30 := ""
    Local cDivisor	:= ";"

    cOrdem1     := "RECORD IDENTIFIER 01"
    cOrdem2     := "HEADER GROUP"
    cOrdem3     := "COMPANY CODE"
    cOrdem4     := "DOCUMENT DATE"
    cOrdem5     := "POSTING DATE"
    cOrdem6     := "REFERENCE NUMBER"
    cOrdem7     := "DOCUMENT TYPE"
    cOrdem8     := "CURRENCY"
    cOrdem9     := "HEADER TEXT"
    cOrdem10    := "LEDGER GROUP" 
    cOrdem11    := "RECORD IDENTIFIER 02"
    cOrdem12    := "LINE ITEM GROUP"
    cOrdem13    := "GL ACCOUNT"
    cOrdem14    := "DEBIT AMOUNT"
    cOrdem15    := "CREDIT AMOUNT"
    cOrdem16    := "TAX CODE"
    cOrdem17    := "LINE ITEM TEXT"
    cOrdem18    := "ASSIGNMENT NUMBER"
    cOrdem19    := "COST CENTER"
    cOrdem20    := "MATTER NUMBER" 
    cOrdem21    := "PROFIT CENTER"
    cOrdem22    := "COST CODE"
    cOrdem23    := "INTERNAL ORDER"
    cOrdem24    := "OFFICE CODE"
    cOrdem25    := "TIMEKEEPER NUMBER"
    cOrdem26    := "VALUE DATE"
    cOrdem27    := "REFERENCE KEY1"
    cOrdem28    := "REFERENCE KEY2"
    cOrdem29    := "REFERENCE KEY3"
    cOrdem30    := "ACTIVITY CODE"

    AAdd( aHeaderCSV, {cOrdem1 +cDivisor+ cOrdem2 +cDivisor+ cOrdem3 +cDivisor+ cOrdem4 +cDivisor+ cOrdem5 +cDivisor+ cOrdem6 +cDivisor+;
                    cOrdem7 +cDivisor+ cOrdem8 +cDivisor+ cOrdem9 +cDivisor+ cOrdem10 +cDivisor+ cOrdem11 +cDivisor+ cOrdem12 +cDivisor+;
                    cOrdem13 +cDivisor+ cOrdem14 +cDivisor+ cOrdem15 +cDivisor+ cOrdem16 +cDivisor+ cOrdem17 +cDivisor+ cOrdem18 +cDivisor+;
                    cOrdem19 +cDivisor+ cOrdem20 +cDivisor+ cOrdem21 +cDivisor+ cOrdem22 +cDivisor+ cOrdem23 +cDivisor+ cOrdem24 +cDivisor+;
                    cOrdem25 +cDivisor+ cOrdem26 +cDivisor+ cOrdem27 +cDivisor+ cOrdem28 +cDivisor+ cOrdem29 +cDivisor+ cOrdem30})

Return(aHeaderCSV)

/*-------------------------------------------------------------------------------*
 | Func:  BodyCSV                                                                |
 | Desc:  agrupa dados do body                                                   |
 *-------------------------------------------------------------------------------*/
Static Function BodyCSV()
    Local aBodyCSV  := {}
    Local cOrdem1, cOrdem2, cOrdem3, cOrdem4, cOrdem5, cOrdem6, cOrdem7, cOrdem8, cOrdem9, cOrdem10  := ""
    Local cOrdem11, cOrdem12, cOrdem13, cOrdem14, cOrdem15, cOrdem16, cOrdem17, cOrdem18, cOrdem19, cOrdem20  := ""
    Local cOrdem21, cOrdem22, cOrdem23, cOrdem24, cOrdem25, cOrdem26, cOrdem27, cOrdem28, cOrdem29, cOrdem30  := ""
    Local cDivisor	:= ";"

    cOrdem1     := (cAliasZZ1)->ZZ1_RECIDE
    cOrdem2     := (cAliasZZ1)->ZZ1_HEAGRO
    cOrdem3     := (cAliasZZ1)->ZZ1_COMCOD
    cOrdem4     := (cAliasZZ1)->ZZ1_DOCDAT2
    cOrdem5     := (cAliasZZ1)->ZZ1_POSDAT2
    cOrdem6     := (cAliasZZ1)->ZZ1_REFNUM
    cOrdem7     := (cAliasZZ1)->ZZ1_DOCTYP
    cOrdem8     := (cAliasZZ1)->ZZ1_CURREN
    cOrdem9     := (cAliasZZ1)->ZZ1_HEATEX
    cOrdem10    := (cAliasZZ1)->ZZ1_LEDGRO
    cOrdem11    := (cAliasZZ1)->ZZ1_RECID2
    cOrdem12    := (cAliasZZ1)->ZZ1_LINITE
    cOrdem13    := (cAliasZZ1)->ZZ1_GLACCO
    cOrdem14    := Alltrim(Transform((cAliasZZ1)->ZZ1_DEBAMO, "@E 999,999,999.99"))
    cOrdem15    := Alltrim(Transform((cAliasZZ1)->ZZ1_CREAMO, "@E 999,999,999.99"))
    cOrdem16    := (cAliasZZ1)->ZZ1_TAXCOD
    cOrdem17    := (cAliasZZ1)->ZZ1_LINTEX
    cOrdem18    := (cAliasZZ1)->ZZ1_ASSNUM
    cOrdem19    := (cAliasZZ1)->ZZ1_COSCEN
    cOrdem20    := (cAliasZZ1)->ZZ1_MATNUM
    cOrdem21    := (cAliasZZ1)->ZZ1_PROCEN
    cOrdem22    := (cAliasZZ1)->ZZ1_COSCOD
    cOrdem23    := (cAliasZZ1)->ZZ1_INTORD
    cOrdem24    := (cAliasZZ1)->ZZ1_OFFCOD
    cOrdem25    := (cAliasZZ1)->ZZ1_TIMNUM
    cOrdem26    := (cAliasZZ1)->ZZ1_VALDAT
    cOrdem27    := (cAliasZZ1)->ZZ1_REFKE1
    cOrdem28    := (cAliasZZ1)->ZZ1_REFKE2
    cOrdem29    := (cAliasZZ1)->ZZ1_REFKE3
    cOrdem30    := (cAliasZZ1)->ZZ1_ACTCOD

    AAdd( aBodyCSV, {cOrdem1 +cDivisor+ cOrdem2 +cDivisor+ cOrdem3 +cDivisor+ cOrdem4 +cDivisor+ cOrdem5 +cDivisor+ cOrdem6 +cDivisor+;
                    cOrdem7 +cDivisor+ cOrdem8 +cDivisor+ cOrdem9 +cDivisor+ cOrdem10 +cDivisor+ cOrdem11 +cDivisor+ cOrdem12 +cDivisor+;
                    cOrdem13 +cDivisor+ cOrdem14 +cDivisor+ cOrdem15 +cDivisor+ cOrdem16 +cDivisor+ cOrdem17 +cDivisor+ cOrdem18 +cDivisor+;
                    cOrdem19 +cDivisor+ cOrdem20 +cDivisor+ cOrdem21 +cDivisor+ cOrdem22 +cDivisor+ cOrdem23 +cDivisor+ cOrdem24 +cDivisor+;
                    cOrdem25 +cDivisor+ cOrdem26 +cDivisor+ cOrdem27 +cDivisor+ cOrdem28 +cDivisor+ cOrdem29 +cDivisor+ cOrdem30})

Return(aBodyCSV)

/*-------------------------------------------------------------------------------*
 | Func:  zArrToCSV                                                              |
 | Desc:  Função transforma o array em csv                                       |
 *-------------------------------------------------------------------------------*/
Static Function zArrToCSV(aAuxiliar, lQuebr, cArqGera, cTextoAux)
    Local nLimite       := 63000 //Forçando o tamanho máximo a 63.000 bytes
    Local nNivel        := 0
    Local cEspac        := Space(nNivel)
     
    //Se tiver linhas para serem processadas
    If Len(aAuxiliar) > 0 .AND. Len(cTextoAux) < nLimite
     
        cTextoAux += cEspac+Alltrim(aAuxiliar[1][1]) + Iif(lQuebr, STR_PULA, '')
    EndIf

Return cTextoAux

/*---------------------------------------------------------------------*
 | Func:  BuscaCT2                                                    |
 | Desc:  Funcao para buscar dados na CT2                              |
 *---------------------------------------------------------------------*/
Static Function BuscaCT2()
    Local dDtRecDe  := MV_PAR01
    Local dDtRecAte := MV_PAR02
    Local cQuery    := ""
    Local aParam    := {}

    //Parametros
    AADD( aParam, dDtRecDe )
    AADD( aParam, dDtRecAte )

	//Busca itens 
	cQuery := " SELECT DISTINCT CT2_FILIAL, CT2_DC, CT2_VALOR, CT2_HIST, CT2_CCC, CT2_CCD, CT2_XDRECL, CT2_XMATTE, "
    cQuery += " CT2_XRECLA, CT2_DEBITO, CT2_CREDIT, CT2_FILORI, CT2_AT01DB, CT2_AT01CR, R_E_C_N_O_ RECNO, "
    cQuery += " CONVERT(VARCHAR(20), CAST(CT2_DATA AS DATETIME),103) 'CT2_DATA' "
    cQuery += " FROM " + RetSQLname("CT2") + " CT2 "
	cQuery += " WHERE CT2_XDRECL >= ? AND CT2_XDRECL <= ? "
	cQuery += " AND CT2_HIST LIKE 'RECL%' AND CT2_XRECLA = ' ' "
    cQuery += " AND CT2.D_E_L_E_T_ = ' ' "

    cAliasCT2   := GtQuer( cQuery, aParam, cAliasCT2 )

	DbSelectArea(cAliasCT2)
	(cAliasCT2)->(DbGoTop())

    Count To nTotCT2

Return

/*---------------------------------------------------------------------*
 | Func:  BuscaZZ1                                                     |
 | Desc:  Funcao para buscar dados na ZZ1                              |
 *---------------------------------------------------------------------*/
Static Function BuscaZZ1()
    Local dDtRecDe  := MV_PAR01
    Local dDtRecAte := MV_PAR02
    Local cQuery    := ""
    Local aParam    := {}

    //Parametros
    AADD( aParam, dDtRecDe )
    AADD( aParam, dDtRecAte )

	//Busca itens 
	cQuery := " SELECT DISTINCT *, R_E_C_N_O_ RECNO,  "
    cQuery += " CONVERT(VARCHAR(20), CAST(ZZ1_DOCDAT AS DATETIME),103) 'ZZ1_DOCDAT2', "
    cQuery += " CONVERT(VARCHAR(20), CAST(ZZ1_POSDAT AS DATETIME),103) 'ZZ1_POSDAT2' "
    cQuery += " FROM " + RetSQLname("ZZ1") + " ZZ1 "
	cQuery += " WHERE ZZ1_DTRECL >= ? AND ZZ1_DTRECL <= ? "
	cQuery += " AND ZZ1_ENVCSV = ' ' "
    cQuery += " AND ZZ1.D_E_L_E_T_ = ' ' "

    cAliasZZ1   := GtQuer( cQuery, aParam, cAliasZZ1 )

	DbSelectArea(cAliasZZ1)
	(cAliasZZ1)->(DbGoTop())

    Count To nTotZZ1

Return

Static Function GtQuer( _cQuery, _aParam, _cAlias)
    Local oSt
    Local cFinalQur := ""
    Local nI

    oSt := FWPreparedStatement():New()

    //Define a consulta e os parâmetros
    oSt:SetQuery(_cQuery)

    for nI := 1 to len( _aParam )
        do case
            case ValType( _aParam[nI] ) == 'C'
                oSt:SetString( nI, _aParam[nI] )

            case ValType( _aParam[nI] ) == 'N'
                oSt:setNumeric( nI, _aParam[nI] )

            case ValType( _aParam[nI] ) == 'D'
                oSt:SetDate( nI, _aParam[nI] )

            case ValType( _aParam[nI] ) == 'L'
                oSt:SetBoolean( nI, _aParam[nI] )

            case ValType( _aParam[nI] ) == 'A'
                oSt:setIn( nI, _aParam[nI] )
        endcase
    next

    //Recupera a consulta já com os parâmetros injetados
    cFinalQur := oSt:GetFixQuery()

    _cAlias := MpSysOpenQuery( cFinalQur, _cAlias )
    if (Select( _cAlias ) == 0)
        UserException('Erro ao processar a query: ' + alltrim(cFinalQur) + ".")
    endif
    fwFreeVar( @oSt )

Return _cAlias
