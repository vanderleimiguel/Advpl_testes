#Include "TOTVS.ch"
#INCLUDE "Protheus.CH"
#include "rwmake.ch"
#include "TBICONN.ch"

/*/{Protheus.doc} TECREPA1
TecnoTextil - Replicar Ativo
Função que replica ativo
@author Wagner Neves
@since 13/12/2023
@version 1.0
@type function
/*/
User Function TECREPA1()
	Local oSay1, oSay2, oSay3, oSay4
	Local oTGet1
	Local btnOut
	Local btnGrv
	Local cBase  	:= SN1->N1_CBASE
	Local cItem     := SN1->N1_ITEM
	Local cDescr    := SN1->N1_DESCRIC
	Local nQuant    := SN1->N1_QUANTD
	Local cReplic   := SN1->N1_XREPATV
	Local nQDig     := 0
	Local lValid    := .F.
	Local cTpMov    := ""
	Private oDlg1

	//Fontes
	Private cFontUti    := "Tahoma"
	Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
	Private oFontSub    := TFont():New(cFontUti, , -20)
	Private oFontBtn    := TFont():New(cFontUti, , -14)

	//Verifica movimentação
	SN4->(DbSetOrder(1))
	If SN4->(DbSeek(FwxFilial("SN4") + cBase + cItem  ))
		cTpMov  := SN4->N4_OCORR
	EndIf

	//Verifica se possui movimentação
	If cTpMov = "05" .AND. cReplic <> "X"

		//Tela para digitar quantidade
		DEFINE MsDialog oDlg1 TITLE "Replicar Ativos" STYLE DS_MODALFRAME FROM 0,0 TO 300,600 PIXEL

		@ 10,10 SAY oSay1 PROMPT 'Replicar Ativos' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL
		@ 25,10 SAY oSay2 PROMPT 'Selecionado: Bem: ' + AllTrim(cBase) + ' - ' + AllTrim(cDescr)    SIZE 290,40 COLORS CLR_BLACK FONT oFontSub OF oDlg1 PIXEL
		@ 40,70 SAY oSay3 PROMPT 'Item: ' + AllTrim(cItem) + ', Quantidade: ' + cValToChar(nQuant)  SIZE 290,40 COLORS CLR_BLACK FONT oFontSub OF oDlg1 PIXEL
		@ 80,10 SAY oSay4 PROMPT 'Quantidade a replicar: ' SIZE 120,20 COLORS CLR_BLACK FONT oFontSub OF oDlg1 PIXEL

		oTGet1:= TGet():New(80, 130,bSetGet( nQDig ), oDlg1, 20, 10,"@E 999",{||lValid := VldQtd(nQuant, nQDig),}, /*nClrFore*/, /*nClrBack*/, /*oFontPadrao*/, , , .T., /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*bChange*/, .F., /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, .F.)

		@ 130,090 BUTTON btnGrv PROMPT "Replicar"   SIZE 100, 017 FONT oFontBtn ACTION IIf(lValid,ReplcMod(nQuant, nQDig),MSGSTOP( "Quantidade digitada nao é valida!", "Validacao Quantidade!" )) OF oDlg1  PIXEL
		@ 130,195 BUTTON btnOut PROMPT "Sair" 	    SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End()) OF oDlg1  PIXEL

		ACTIVATE DIALOG oDlg1 CENTERED

	ElseIf cTpMov <> "05"
		MSGSTOP( "Ativo selecionado ja possui movimentacao e não pode ser replicado!", "Bloqueio" )
	ElseIf cReplic = "X"
		MSGSTOP( "Ativo ja foi replicado e não poder ser replicado novamente!", "Bloqueio" )
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  ReplcMod                                                     |
 | Desc:  Funcao para Mostra tela com configuração do Replicar         |
 *---------------------------------------------------------------------*/
Static Function ReplcMod(_nQuant, _nQDig)
    Local nX
    Local aQtd      := {}
    Local nTamQtd   := 0
	Local oSay1, oSay2, oSay3
	Local btnOut
	Local btnGrv
    Local cTexto    := ""
	Private oDlg2

    //Verifica Divisão
    aQtd    := CalcQtd(_nQuant, _nQDig)
    nTamQtd := Len(aQtd)

    If nTamQtd > 0
        For nX :=1 To nTamQtd
           cTexto   +=  cValtoChar(aQtd[nX]) + IIf(nX = nTamQtd, "", ", ")
        Next nX
    
	    //Tela para digitar quantidade
	    DEFINE MsDialog oDlg2 TITLE "Dstribuição" STYLE DS_MODALFRAME FROM 0,0 TO 200,600 PIXEL

	    @ 10,10 SAY oSay1 PROMPT 'Distribuição do Replicar' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg2 PIXEL
	    @ 25,10 SAY oSay2 PROMPT 'Quantidade de Ativos Adicionados: ' + cValtoChar(nTamQtd) SIZE 290,40 COLORS CLR_BLACK FONT oFontSub OF oDlg2 PIXEL
        @ 40,10 SAY oSay3 PROMPT 'Distribuição de Quantidades: ' + cTexto                   SIZE 500,40 COLORS CLR_BLACK FONT oFontSub OF oDlg2 PIXEL

	    @ 80,020 BUTTON btnGrv PROMPT "Confirmar"   SIZE 070, 017 FONT oFontBtn ACTION {||RepAtv(aQtd, nTamQtd)} OF oDlg2  PIXEL
	    @ 80,110 BUTTON btnOut PROMPT "Cancelar"    SIZE 070, 017 FONT oFontBtn ACTION (oDlg2:End()) OF oDlg2  PIXEL

	    ACTIVATE DIALOG oDlg2 CENTERED

    Else
        MSGSTOP( "Nao foi possivel distribuir ativo selecionado", "Bloqueio" )
        oDlg2:End()
    EndIf

Return
/*---------------------------------------------------------------------*
 | Func:  RepAtv                                                       |
 | Desc:  Funcao para Replicar ativos                                  |
 *---------------------------------------------------------------------*/
Static Function RepAtv(_aQtd, _nTamQtd)
    Local aArea
    Local nX
    Local aParam    := {}
    Local aCab      := {}
    Local aItens    := {}
    Local cBase     := SN1->N1_CBASE
    Local cItem     := SN1->N1_ITEM
    Local cBaseNov  := ""
    Local cItemNov  := ""
    Local cChapa    := ""
    Local lErro     := .F.
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.

    oDlg2:End()

    //Busca Ultimo item
    cUltItem    := BuscItem(cBase)
    cItemNov    := SOMA1(cUltItem)

    If _nTamQtd > 0
        For nX :=1 To _nTamQtd
        
            aArea       := GetArea() 

            //Posiciona no Registro
            SN1->(DbSetOrder(1))
            If SN1->(DbSeek(FwxFilial("SN1") + cBase + cItem  )) 

                //Atualiza Campos Unicos  
                cBaseNov    := SN1->N1_CBASE
                cChapa      := cItemNov
    
                //Preenche cabecalho tabela SN1
                aCab := {}
                AAdd(aCab,{"N1_CBASE"   , cBaseNov          ,NIL})
                AAdd(aCab,{"N1_ITEM"    , cItemNov          ,NIL})
                AAdd(aCab,{"N1_AQUISIC" , SN1->N1_AQUISIC   ,NIL})
                AAdd(aCab,{"N1_DESCRIC" , SN1->N1_DESCRIC   ,NIL})
                AAdd(aCab,{"N1_QUANTD"  , _aQtd[nX]          ,NIL})
                AAdd(aCab,{"N1_CHAPA"   , cChapa            ,NIL})
                AAdd(aCab,{"N1_PATRIM"  , SN1->N1_PATRIM    ,NIL})
                AAdd(aCab,{"N1_GRUPO"   , SN1->N1_GRUPO     ,NIL})
                AAdd(aCab,{"N1_MARGEM"  , SN1->N1_MARGEM    ,NIL})
                AAdd(aCab,{"N1_XREPATV" , "X"               ,NIL})
       
                //Posiciona nos item SN3
                SN3->(DbSetOrder(1))
                If SN3->(DbSeek(FwxFilial("SN3") + cBase + cItem  ))
        
                    aItens := {}

                    AAdd(aItens,{;
                    {"N3_CBASE"   , cBaseNov            ,NIL},;
                    {"N3_ITEM"    , cItemNov            ,NIL},;
                    {"N3_TIPO"    , SN3->N3_TIPO        ,NIL},;
                    {"N3_BAIXA"   , "0"                 ,NIL},;
                    {"N3_HISTOR"  , SN3->N3_HISTOR      ,NIL},;
                    {"N3_CCONTAB" , SN3->N3_CCONTAB     ,NIL},;
                    {"N3_CUSTBEM" , SN3->N3_CUSTBEM     ,NIL},;
                    {"N3_CDEPREC" , SN3->N3_CDEPREC     ,NIL},;
                    {"N3_CDESP"   , SN3->N3_CDESP       ,NIL},;
                    {"N3_CCORREC" , SN3->N3_CCORREC     ,NIL},;
                    {"N3_CCUSTO"  , SN3->N3_CCUSTO      ,NIL},;
                    {"N3_DINDEPR" , SN3->N3_DINDEPR     ,NIL},;
                    {"N3_VORIG1"  , (SN3->N3_VORIG1 / _aQtd[nX]) ,NIL},;
                    {"N3_TXDEPR1" , SN3->N3_TXDEPR1     ,NIL},;
                    {"N3_VORIG2"  , (SN3->N3_VORIG2 / _aQtd[nX]) ,NIL},;
                    {"N3_TXDEPR2" , SN3->N3_TXDEPR2     ,NIL},;
                    {"N3_VORIG3"  , (SN3->N3_VORIG3 / _aQtd[nX]) ,NIL},;
                    {"N3_TXDEPR3" , SN3->N3_TXDEPR3     ,NIL},;
                    {"N3_VORIG4"  , (SN3->N3_VORIG4 / _aQtd[nX]) ,NIL},;
                    {"N3_TXDEPR4" , SN3->N3_TXDEPR4     ,NIL},;
                    {"N3_VORIG5"  , (SN3->N3_VORIG5 / _aQtd[nX]) ,NIL},;
                    {"N3_TXDEPR5" , SN3->N3_TXDEPR5     ,NIL},;
                    {"N3_VRDACM1" , SN3->N3_VRDACM1     ,NIL},;
                    {"N3_SUBCCON" , SN3->N3_SUBCCON     ,NIL},;
                    {"N3_SEQ"     , SN3->N3_SEQ         ,NIL},;
                    {"N3_CLVLCON" , SN3->N3_CLVLCON     ,NIL};
                        })

                EndIf
                
                //Controle de transacao
                Begin Transaction

                conOut('Inicio da rotina Automatica '+ Time())
                MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
                conOut('FIM' +Time())

                If lMsErroAuto 
                    MostraErro()
                    lErro   := .T.
                    DisarmTransaction()
                else
                    ConfirmSx8()
                    conOut('INCLUIDO ATIVO N3_CBASE: '+ cBase + ", N3_ITEM : "+cItem)
                ENDIF    

                RestArea(aArea)
                End Transaction
            EndIf

            cItemNov    := SOMA1(cItemNov)

        Next nX
        
        //Execauto de exclusão
        If !lErro
            ExecExcl(cBase, cItem)

            MSGINFO( "Ativos Replicados com Sucesso!", "Replicar Ativos" ) 
        EndIf

        oDlg1:End()
        
    EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  ExecExcl                                                     |
 | Desc:  Funcao para execauto exclusao SN1                            |
 *---------------------------------------------------------------------*/
Static Function ExecExcl(_cBase, _cItem)
    Local aArea     := GetArea()
    Local aParam    := {}
    Local aCab      := {}

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.

    SN1->(DbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
    If SN1->(DbSeek(xFilial("SN1")+ _cBase + _cItem)) 

        aCab := {}
        AAdd(aCab,{"N1_CBASE"   , SN1->N1_CBASE     ,NIL})
        AAdd(aCab,{"N1_ITEM"    , SN1->N1_ITEM      ,NIL})
        AAdd(aCab,{"N1_AQUISIC" , SN1->N1_AQUISIC   ,NIL})
        AAdd(aCab,{"N1_DESCRIC" , SN1->N1_DESCRIC   ,NIL})
        AAdd(aCab,{"N1_QUANTD"  , SN1->N1_QUANTD    ,NIL})
        AAdd(aCab,{"N1_CHAPA"   , SN1->N1_CHAPA     ,NIL})
        AAdd(aCab,{"N1_PATRIM"  , SN1->N1_PATRIM    ,NIL})
        AAdd(aCab,{"N1_GRUPO"   , SN1->N1_GRUPO     ,NIL})

    EndIf

    Begin Transaction

        MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,Nil,5,aParam)

        If lMsErroAuto

            MostraErro()
            DisarmTransaction()

        Endif

    End Transaction

    RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  VldQtd                                                       |
 | Desc:  Funcao para Validar quantidade digitada                      |
 *---------------------------------------------------------------------*/
Static Function VldQtd(_nQuant, _nQDig)
	Local lRet := .T.

    //Verifica quantidade digitada
    If _nQDig > _nQuant
        MSGSTOP( "Quantidade digitada deve ser menor ou igual que a quantidade do Bem selecionado", "Bloqueio")
        lRet    := .F.
    EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  CalcQtd                                                      |
 | Desc:  Funcao para Verificar Qauntidades a Gravar                   |
 *---------------------------------------------------------------------*/
Static Function CalcQtd(_nQuant, _nQDig)
    Local aQtdCalc  := {}
    Local nResult   := 0
    Local nInteiro  := 0
    Local nResto    := 0
    Local cResult   := ""
    Local nI

    //Efetua Calculos
    nResult     := _nQuant / _nQDig
    cResult     := cValToChar(nResult)
    nPos        := At(".", cResult)
    If nPos > 0
        nInteiro    := Val(Substr(cResult, 1, (nPos - 1)))
        nResto      := _nQuant - (_nQDig * nInteiro)
    else
        nInteiro    := nResult
        nResto      := 0
    EndIf

    //Adiciona valores do calculo inteiros
    For nI := 1 To nInteiro
        aAdd(aQtdCalc, _nQDig)
    Next

    //Adiciona valores do resto do calculo
    If nResto > 0
        aAdd(aQtdCalc, nResto)
    EndIf

Return aQtdCalc

/*---------------------------------------------------------------------*
 | Func:  BuscItem                                                     |
 | Desc:  Funcao para Verificaqual ultimo item do ativo                |
 *---------------------------------------------------------------------*/
Static Function BuscItem(_cBase)
    Local cUltItem  := ""
	Local cQuery    := ""
	Local cAliasSN1 := GetNextAlias()
    
	//Busca itens da SN1
	cQuery := " SELECT DISTINCT N1_CBASE, N1_ITEM "
	cQuery += " FROM " + RetSQLname("SN1") + " SN1 "
	cQuery += " WHERE N1_CBASE = '"+ _cBase +"' "
	cQuery += " AND SN1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSN1,.F.,.T.)

    //Percorre até o ultimo
	(cAliasSN1)->(DbGoTop())
	While !(cAliasSN1)->(EOF())
        cUltItem    := (cAliasSN1)->N1_ITEM
		(cAliasSN1)->(DbSkip())
	EndDo

Return cUltItem
