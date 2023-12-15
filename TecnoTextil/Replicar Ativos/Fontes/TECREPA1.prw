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

		@ 130,090 BUTTON btnGrv PROMPT "Replicar"   SIZE 100, 017 FONT oFontBtn ACTION IIf(lValid,ReplcMod(nQuant, nQDig),MSGSTOP( "Quantidade digitada nao é valida!", "Validacao Quantidade!" ))  OF oDlg1  PIXEL
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
	    DEFINE MsDialog oDlg2 TITLE "Distribuição" STYLE DS_MODALFRAME FROM 0,0 TO 200,600 PIXEL

	    @ 10,10 SAY oSay1 PROMPT 'Distribuição do Replicar' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg2 PIXEL
	    @ 25,10 SAY oSay2 PROMPT 'Quantidade de Ativos Adicionados: ' + cValtoChar(nTamQtd) SIZE 290,40 COLORS CLR_BLACK FONT oFontSub OF oDlg2 PIXEL
        @ 40,10 SAY oSay3 PROMPT 'Distribuição de Quantidades: ' + cTexto                   SIZE 500,40 COLORS CLR_BLACK FONT oFontSub OF oDlg2 PIXEL

	    @ 80,020 BUTTON btnGrv PROMPT "Confirmar"   SIZE 070, 017 FONT oFontBtn ACTION MsgRun("Replicando...", "Replicar Ativo", {||RepAtv(aQtd, nTamQtd, _nQDig, _nQuant)}) OF oDlg2  PIXEL
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
Static Function RepAtv(_aQtd, _nTamQtd, _nQDig, _nQuant)
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
    Local nVlrOri1  := 0
    Local nVlrOri2  := 0
    Local nVlrOri3  := 0
    Local nVlrOri4  := 0
    Local nVlrOri5  := 0
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
    Private cAliasSN3   := GetNextAlias()

    aArea       := GetArea() 
    
    //Busca Ultimo item
    cUltItem    := BuscItem(cBase)
    cItemNov    := SOMA1(cUltItem)

    If _nTamQtd > 0       
        For nX :=1 To _nTamQtd          

            //Posiciona no Registro
            SN1->(DbSetOrder(1))
            If SN1->(DbSeek(FwxFilial("SN1") + cBase + cItem  )) 

                //Atualiza Campos Unicos  
                cBaseNov    := SN1->N1_CBASE
                cChapa      := cBaseNov + cItemNov
    
                //Preenche cabecalho tabela SN1
                aCab := {}
                AAdd(aCab,{"N1_INDAVP"  , SN1->N1_INDAVP    ,NIL})
                AAdd(aCab,{"N1_GRUPO"   , SN1->N1_GRUPO     ,NIL})
                AAdd(aCab,{"N1_PATRIM"  , SN1->N1_PATRIM    ,NIL})
                AAdd(aCab,{"N1_CBASE"   , cBaseNov          ,NIL})
                AAdd(aCab,{"N1_ITEM"    , cItemNov          ,NIL})
                AAdd(aCab,{"N1_BITMAP"  , SN1->N1_BITMAP    ,NIL})
                AAdd(aCab,{"N1_AQUISIC" , SN1->N1_AQUISIC   ,NIL})
                AAdd(aCab,{"N1_QUANTD"  , _aQtd[nX]         ,NIL})
                AAdd(aCab,{"N1_DESCRIC" , SN1->N1_DESCRIC   ,NIL})
                AAdd(aCab,{"N1_CHAPA"   , cChapa            ,NIL})
                AAdd(aCab,{"N1_APOLICE" , SN1->N1_APOLICE   ,NIL})
                AAdd(aCab,{"N1_CODSEG"  , SN1->N1_CODSEG    ,NIL})
                AAdd(aCab,{"N1_DTVENC"  , SN1->N1_DTVENC    ,NIL})
                AAdd(aCab,{"N1_CSEGURO" , SN1->N1_CSEGURO   ,NIL})
                AAdd(aCab,{"N1_TIPOSEG" , SN1->N1_TIPOSEG   ,NIL})
                AAdd(aCab,{"N1_FORNEC"  , SN1->N1_FORNEC    ,NIL})
                AAdd(aCab,{"N1_LOJA"    , SN1->N1_LOJA      ,NIL})
                AAdd(aCab,{"N1_LOCAL"   , SN1->N1_LOCAL     ,NIL})
                AAdd(aCab,{"N1_NSERIE"  , SN1->N1_NSERIE    ,NIL})
                AAdd(aCab,{"N1_NFISCAL" , SN1->N1_NFISCAL   ,NIL})
                AAdd(aCab,{"N1_PROJETO" , SN1->N1_PROJETO   ,NIL})
                AAdd(aCab,{"N1_CHASSIS" , SN1->N1_CHASSIS   ,NIL})
                AAdd(aCab,{"N1_PLACA"   , SN1->N1_PLACA     ,NIL})
                AAdd(aCab,{"N1_STATUS"  , SN1->N1_STATUS    ,NIL})
                AAdd(aCab,{"N1_CODCIAP" , SN1->N1_CODCIAP   ,NIL})
                AAdd(aCab,{"N1_ICMSAPR" , SN1->N1_ICMSAPR   ,NIL})
                AAdd(aCab,{"N1_DTBLOQ"  , SN1->N1_DTBLOQ    ,NIL})
                AAdd(aCab,{"N1_CODBEM"  , SN1->N1_CODBEM    ,NIL})
                AAdd(aCab,{"N1_BASESUP" , SN1->N1_BASESUP   ,NIL})
                AAdd(aCab,{"N1_ITEMSUP" , SN1->N1_ITEMSUP   ,NIL})
                AAdd(aCab,{"N1_CALCPIS" , SN1->N1_CALCPIS   ,NIL})
                AAdd(aCab,{"N1_CODBAR"  , SN1->N1_CODBAR    ,NIL})
                AAdd(aCab,{"N1_PENHORA" , SN1->N1_PENHORA   ,NIL})
                AAdd(aCab,{"N1_MESCPIS" , SN1->N1_MESCPIS   ,NIL})
                AAdd(aCab,{"N1_DTCLASS" , SN1->N1_DTCLASS   ,NIL})
                AAdd(aCab,{"N1_DIACTB"  , SN1->N1_DIACTB    ,NIL})
                AAdd(aCab,{"N1_NODIA"   , SN1->N1_NODIA     ,NIL})
                AAdd(aCab,{"N1_TAXAPAD" , SN1->N1_TAXAPAD   ,NIL})
                AAdd(aCab,{"N1_CODCUSD" , SN1->N1_CODCUSD   ,NIL})
                AAdd(aCab,{"N1_TPCUSTD" , SN1->N1_TPCUSTD   ,NIL})
                AAdd(aCab,{"N1_TPBEM"   , SN1->N1_TPBEM     ,NIL})
                AAdd(aCab,{"N1_TPOUTR"  , SN1->N1_TPOUTR    ,NIL})
                AAdd(aCab,{"N1_CODRGI"  , SN1->N1_CODRGI    ,NIL})
                AAdd(aCab,{"N1_NOMCART" , SN1->N1_NOMCART   ,NIL})
                AAdd(aCab,{"N1_AREA"    , SN1->N1_AREA      ,NIL})
                AAdd(aCab,{"N1_REDE"    , SN1->N1_REDE      ,NIL})
                AAdd(aCab,{"N1_LOGIMOV" , SN1->N1_LOGIMOV   ,NIL})
                AAdd(aCab,{"N1_NRIMOV"  , SN1->N1_NRIMOV    ,NIL})
                AAdd(aCab,{"N1_COMIMOV" , SN1->N1_COMIMOV   ,NIL})
                AAdd(aCab,{"N1_BAIIMOV" , SN1->N1_BAIIMOV   ,NIL})
                AAdd(aCab,{"N1_MUNIMOV" , SN1->N1_MUNIMOV   ,NIL})
                AAdd(aCab,{"N1_SIGLAUF" , SN1->N1_SIGLAUF   ,NIL})
                AAdd(aCab,{"N1_CEPIMOV" , SN1->N1_CEPIMOV   ,NIL})
                AAdd(aCab,{"N1_DETPATR" , SN1->N1_DETPATR   ,NIL})
                AAdd(aCab,{"N1_UTIPATR" , SN1->N1_UTIPATR   ,NIL})
                AAdd(aCab,{"N1_QUALIFI" , SN1->N1_QUALIFI   ,NIL})
                AAdd(aCab,{"N1_ORIGEM"  , SN1->N1_ORIGEM    ,NIL})
                AAdd(aCab,{"N1_TAXAVP"  , SN1->N1_TAXAVP    ,NIL})
                AAdd(aCab,{"N1_PRODUTO" , SN1->N1_PRODUTO   ,NIL})
                AAdd(aCab,{"N1_TPCTRAT" , SN1->N1_TPCTRAT   ,NIL})
                AAdd(aCab,{"N1_NFESPEC" , SN1->N1_NFESPEC   ,NIL})
                AAdd(aCab,{"N1_NFITEM"  , SN1->N1_NFITEM    ,NIL})
                AAdd(aCab,{"N1_PROJREV" , SN1->N1_PROJREV   ,NIL})
                AAdd(aCab,{"N1_PROJETP" , SN1->N1_PROJETP   ,NIL})
                AAdd(aCab,{"N1_PROJITE" , SN1->N1_PROJITE   ,NIL})
                AAdd(aCab,{"N1_DTAVP"   , SN1->N1_DTAVP     ,NIL})
                AAdd(aCab,{"N1_ORIGCRD" , SN1->N1_ORIGCRD   ,NIL})
                AAdd(aCab,{"N1_CSTPIS"  , SN1->N1_CSTPIS    ,NIL})
                AAdd(aCab,{"N1_ALIQPIS" , SN1->N1_ALIQPIS   ,NIL})
                AAdd(aCab,{"N1_CSTCOFI" , SN1->N1_CSTCOFI   ,NIL})
                AAdd(aCab,{"N1_ALIQCOF" , SN1->N1_ALIQCOF   ,NIL})
                AAdd(aCab,{"N1_CODBCC"  , SN1->N1_CODBCC    ,NIL})
                AAdd(aCab,{"N1_TPAVP"   , SN1->N1_TPAVP     ,NIL})
                AAdd(aCab,{"N1_MARGEM"  , SN1->N1_MARGEM    ,NIL})
                AAdd(aCab,{"N1_REVMRG"  , SN1->N1_REVMRG    ,NIL})
                AAdd(aCab,{"N1_PROVIS"  , SN1->N1_PROVIS    ,NIL})
                AAdd(aCab,{"N1_CBCPIS"  , SN1->N1_CBCPIS    ,NIL})
                AAdd(aCab,{"N1_INDPRO"  , SN1->N1_INDPRO    ,NIL})
                AAdd(aCab,{"N1_NUMPRO"  , SN1->N1_NUMPRO    ,NIL})
                AAdd(aCab,{"N1_NUMSEQ"  , SN1->N1_NUMSEQ    ,NIL})
                AAdd(aCab,{"N1_BMCONTR" , SN1->N1_BMCONTR   ,NIL})
                AAdd(aCab,{"N1_SLBMCON" , SN1->N1_SLBMCON   ,NIL})
                AAdd(aCab,{"N1_CDCONTR" , SN1->N1_CDCONTR   ,NIL})
                AAdd(aCab,{"N1_SDOC"    , SN1->N1_SDOC      ,NIL})         
                AAdd(aCab,{"N1_XREPATV" , "X"               ,NIL})


                //Busca dados da SN3
                aItens := {}
                If nX = 1
                    BuscaSN3(cBase, cItem)
                EndIf
                (cAliasSN3)->(DbGoTop())
	            While !(cAliasSN3)->(EOF())
        
                // SN3->(DbSetOrder(1))
                // If SN3->(DbSeek(FwxFilial("SN3") + cBase + cItem  ))
                    nVlrOri1    := Round((CALIASSN3)->N3_VORIG1 / _nQuant, 2)
                    nVlrOri2    := Round((CALIASSN3)->N3_VORIG2 / _nQuant, 2)
                    nVlrOri3    := Round((CALIASSN3)->N3_VORIG3 / _nQuant, 2)
                    nVlrOri4    := Round((CALIASSN3)->N3_VORIG4 / _nQuant, 2)
                    nVlrOri5    := Round((CALIASSN3)->N3_VORIG5 / _nQuant, 2)
        
                    AAdd(aItens,{;
                    {"N3_CBASE"   , cBaseNov            ,NIL},;
                    {"N3_ITEM"    , cItemNov            ,NIL},;
                    {"N3_TIPO"    , (CALIASSN3)->N3_TIPO        ,NIL},;
                    {"N3_TIPREAV" , (CALIASSN3)->N3_TIPREAV     ,NIL},;
                    {"N3_BAIXA"   , "0"                 ,NIL},;
                    {"N3_HISTOR"  , (CALIASSN3)->N3_HISTOR      ,NIL},;
                    {"N3_TPSALDO" , (CALIASSN3)->N3_TPSALDO     ,NIL},;
                    {"N3_TPDEPR"  , (CALIASSN3)->N3_TPDEPR      ,NIL},;
                    {"N3_CCONTAB" , (CALIASSN3)->N3_CCONTAB     ,NIL},;
                    {"N3_CUSTBEM" , (CALIASSN3)->N3_CUSTBEM     ,NIL},;
                    {"N3_CDEPREC" , (CALIASSN3)->N3_CDEPREC     ,NIL},;
                    {"N3_CCUSTO"  , (CALIASSN3)->N3_CCUSTO      ,NIL},;
                    {"N3_CCDEPR"  , (CALIASSN3)->N3_CCDEPR      ,NIL},;
                    {"N3_CDESP"   , (CALIASSN3)->N3_CDESP       ,NIL},;
                    {"N3_CCORREC" , (CALIASSN3)->N3_CCORREC     ,NIL},;
                    {"N3_VORIG1"  , _aQtd[nX] * nVlrOri1 ,NIL},;
                    {"N3_TXDEPR1" , (CALIASSN3)->N3_TXDEPR1     ,NIL},;
                    {"N3_VORIG2"  , _aQtd[nX] * nVlrOri2 ,NIL},;
                    {"N3_TXDEPR2" , (CALIASSN3)->N3_TXDEPR2     ,NIL},;
                    {"N3_VORIG3"  , _aQtd[nX] * nVlrOri3 ,NIL},;
                    {"N3_TXDEPR3" , (CALIASSN3)->N3_TXDEPR3     ,NIL},;
                    {"N3_VORIG4"  , _aQtd[nX] * nVlrOri4 ,NIL},;
                    {"N3_TXDEPR4" , (CALIASSN3)->N3_TXDEPR4     ,NIL},;
                    {"N3_VORIG5"  , _aQtd[nX] * nVlrOri5 ,NIL},;
                    {"N3_TXDEPR5" , (CALIASSN3)->N3_TXDEPR5     ,NIL},;                  
                    {"N3_VRCBAL1" , (CALIASSN3)->N3_VRCBAL1     ,NIL},;
                    {"N3_VRDBAL1" , (CALIASSN3)->N3_VRCBAL1     ,NIL},;
                    {"N3_VRCMES1" , (CALIASSN3)->N3_VRCMES1     ,NIL},;
                    {"N3_VRDMES1" , (CALIASSN3)->N3_VRDMES1     ,NIL},;
                    {"N3_VRCACM1" , (CALIASSN3)->N3_VRCACM1     ,NIL},;
                    {"N3_VRDACM1" , (CALIASSN3)->N3_VRDACM1     ,NIL},;
                    {"N3_VRDBAL2" , (CALIASSN3)->N3_VRDBAL2     ,NIL},;
                    {"N3_VRDMES2" , (CALIASSN3)->N3_VRDMES2     ,NIL},;
                    {"N3_VRCACM2" , (CALIASSN3)->N3_VRCACM2     ,NIL},;
                    {"N3_VRDACM2" , (CALIASSN3)->N3_VRDACM2     ,NIL},;
                    {"N3_VRDBAL3" , (CALIASSN3)->N3_VRDBAL3     ,NIL},;
                    {"N3_VRDMES3" , (CALIASSN3)->N3_VRDMES3     ,NIL},;
                    {"N3_VRCACM3" , (CALIASSN3)->N3_VRCACM3     ,NIL},;
                    {"N3_VRDACM3" , (CALIASSN3)->N3_VRDACM3     ,NIL},;
                    {"N3_VRDBAL4" , (CALIASSN3)->N3_VRDBAL4     ,NIL},;
                    {"N3_VRDMES4" , (CALIASSN3)->N3_VRDMES4     ,NIL},;
                    {"N3_VRCACM4" , (CALIASSN3)->N3_VRCACM4     ,NIL},;
                    {"N3_VRDACM4" , (CALIASSN3)->N3_VRDACM4     ,NIL},;
                    {"N3_VRDBAL5" , (CALIASSN3)->N3_VRDBAL5     ,NIL},;
                    {"N3_VRDMES5" , (CALIASSN3)->N3_VRDMES5     ,NIL},;
                    {"N3_VRCACM5" , (CALIASSN3)->N3_VRCACM5     ,NIL},;
                    {"N3_VRDACM5" , (CALIASSN3)->N3_VRDACM5     ,NIL},;
                    {"N3_INDICE1" , (CALIASSN3)->N3_INDICE1     ,NIL},;
                    {"N3_INDICE2" , (CALIASSN3)->N3_INDICE2     ,NIL},;
                    {"N3_INDICE3" , (CALIASSN3)->N3_INDICE3     ,NIL},;
                    {"N3_INDICE4" , (CALIASSN3)->N3_INDICE4     ,NIL},;
                    {"N3_INDICE5" , (CALIASSN3)->N3_INDICE5     ,NIL},;
                    {"N3_VRCDM1"  , (CALIASSN3)->N3_VRCDM1      ,NIL},;
                    {"N3_VRCDB1"  , (CALIASSN3)->N3_VRCDB1      ,NIL},;
                    {"N3_VRCDA1"  , (CALIASSN3)->N3_VRCDA1      ,NIL},;
                    {"N3_VRCDA2"  , (CALIASSN3)->N3_VRCDA2      ,NIL},;
                    {"N3_VRCDA3"  , (CALIASSN3)->N3_VRCDA3      ,NIL},;
                    {"N3_VRCDA4"  , (CALIASSN3)->N3_VRCDA4      ,NIL},;
                    {"N3_VRCDA5"  , (CALIASSN3)->N3_VRCDA5      ,NIL},;
                    {"N3_PERDEPR" , (CALIASSN3)->N3_PERDEPR     ,NIL},;
                    {"N3_CRIDEPR" , (CALIASSN3)->N3_CRIDEPR     ,NIL},;
                    {"N3_CALDEPR" , (CALIASSN3)->N3_CALDEPR     ,NIL},;
                    {"N3_VMXDEPR" , (CALIASSN3)->N3_VMXDEPR     ,NIL},;
                    {"N3_VLSALV1" , (CALIASSN3)->N3_VLSALV1     ,NIL},;
                    {"N3_DEPREC"  , (CALIASSN3)->N3_DEPREC      ,NIL},;
                    {"N3_CALCDEP" , (CALIASSN3)->N3_CALCDEP     ,NIL},;
                    {"N3_PRODANO" , (CALIASSN3)->N3_PRODANO     ,NIL},;
                    {"N3_PRODMES" , (CALIASSN3)->N3_PRODMES     ,NIL},;
                    {"N3_PRODACM" , (CALIASSN3)->N3_PRODACM     ,NIL},;
                    {"N3_SEQ"     , (CALIASSN3)->N3_SEQ         ,NIL},;        
                    {"N3_CCDESP"  , (CALIASSN3)->N3_CCDESP      ,NIL},;
                    {"N3_CCCDEP"  , (CALIASSN3)->N3_CCCDEP      ,NIL},;
                    {"N3_CCCDES"  , (CALIASSN3)->N3_CCCDES      ,NIL},;
                    {"N3_CCCORR"  , (CALIASSN3)->N3_CCCORR      ,NIL},;
                    {"N3_SUBCTA"  , (CALIASSN3)->N3_SUBCTA      ,NIL},;
                    {"N3_SUBCCON" , (CALIASSN3)->N3_SUBCCON     ,NIL},;
                    {"N3_SUBCCDE" , (CALIASSN3)->N3_SUBCCDE     ,NIL},;
                    {"N3_SUBCDES" , (CALIASSN3)->N3_SUBCDES     ,NIL},;
                    {"N3_SUBCCOR" , (CALIASSN3)->N3_SUBCCOR     ,NIL},;
                    {"N3_BXICMS"  , (CALIASSN3)->N3_BXICMS      ,NIL},;
                    {"N3_SEQREAV" , (CALIASSN3)->N3_SEQREAV     ,NIL},;
                    {"N3_AMPLIA1" , (CALIASSN3)->N3_AMPLIA1     ,NIL},;
                    {"N3_AMPLIA2" , (CALIASSN3)->N3_AMPLIA2     ,NIL},;
                    {"N3_AMPLIA3" , (CALIASSN3)->N3_AMPLIA3     ,NIL},;
                    {"N3_AMPLIA4" , (CALIASSN3)->N3_AMPLIA4     ,NIL},;
                    {"N3_AMPLIA5" , (CALIASSN3)->N3_AMPLIA5     ,NIL},;
                    {"N3_FILORIG" , (CALIASSN3)->N3_FILORIG     ,NIL},;
                    {"N3_CLVL"    , (CALIASSN3)->N3_CLVL        ,NIL},;
                    {"N3_CLVLCON" , (CALIASSN3)->N3_CLVLCON     ,NIL},;
                    {"N3_CLVLDEP" , (CALIASSN3)->N3_CLVLDEP     ,NIL},;
                    {"N3_CLVLCDE" , (CALIASSN3)->N3_CLVLCDE     ,NIL},;
                    {"N3_CLVLDES" , (CALIASSN3)->N3_CLVLDES     ,NIL},;
                    {"N3_CLVLCOR" , (CALIASSN3)->N3_CLVLCOR     ,NIL},;
                    {"N3_LOCAL"   , (CALIASSN3)->N3_LOCAL       ,NIL},;
                    {"N3_VLACEL1" , (CALIASSN3)->N3_VLACEL1     ,NIL},;
                    {"N3_VLACEL2" , (CALIASSN3)->N3_VLACEL2     ,NIL},;
                    {"N3_VLACEL3" , (CALIASSN3)->N3_VLACEL3     ,NIL},;
                    {"N3_VLACEL4" , (CALIASSN3)->N3_VLACEL4     ,NIL},;
                    {"N3_VLACEL5" , (CALIASSN3)->N3_VLACEL5     ,NIL},;
                    {"N3_RATEIO"  , (CALIASSN3)->N3_RATEIO      ,NIL},;
                    {"N3_CODRAT"  , (CALIASSN3)->N3_CODRAT      ,NIL},;
                    {"N3_CODIND"  , (CALIASSN3)->N3_CODIND      ,NIL},;
                    {"N3_ATFCPR"  , (CALIASSN3)->N3_ATFCPR      ,NIL},;
                    {"N3_INTP"    , (CALIASSN3)->N3_INTP        ,NIL};
                        })
                        // {"N3_DTACELE" , (CALIASSN3)->N3_DTACELE     ,NIL},;
                        //{"N3_DEXAUST" , (CALIASSN3)->N3_DEXAUST     ,NIL},;

                //EndIf
                		(cAliasSN3)->(DbSkip())
	            EndDo
                
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
        oDlg2:End()
        (cAliasSN3)->(DbCloseArea())
        
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
    If _nQDig >= _nQuant
        MSGSTOP( "Quantidade digitada deve ser menor que a quantidade do Bem selecionado", "Bloqueio")
        lRet    := .F.
    EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  CalcQtd                                                      |
 | Desc:  Funcao para Verificar Qauntidades a Gravar                   |
 *---------------------------------------------------------------------*/
Static Function CalcQtd(_nQuant, _nQDig)
    Local aQtdCalc  := {}
    Local nResto    := 0
    Local nI

    //Efetua Calculos
    nResto  := _nQuant - _nQDig

    //Adiciona valores do calculo inteiros
    For nI := 1 To _nQDig
        aAdd(aQtdCalc, 1)
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

/*---------------------------------------------------------------------*
 | Func:  BuscaSN3                                                     |
 | Desc:  Funcao para buscar dados da SN3                              |
 *---------------------------------------------------------------------*/
Static Function BuscaSN3(_cBase, _cItem)
	Local cQuery    := ""
	    
	//Busca itens da SN3
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLname("SN3") + " SN3 "
	cQuery += " WHERE N3_CBASE = '"+ _cBase +"' AND N3_ITEM = '"+ _cItem +"' "
	cQuery += " AND SN3.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSN3,.F.,.T.)

    (cAliasSN3)->(DbGoTop())
Return

