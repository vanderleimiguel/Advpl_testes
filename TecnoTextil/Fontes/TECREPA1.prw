#Include "TOTVS.ch"

/*/{Protheus.doc} TECREPA1
TecnoTextil - Replicar Ativo
Função que replica ativo
@author Wagner Neves
@since 13/12/2023
@version 1.0
@type function
/*/
User Function TECREPA1()
	Local oSay1
	Local oSay2
	Local oTGet1
	Local btnOut
	Local btnGrv
	Local cBem  	:= AllTrim(SN1->N1_CBASE)
    Local cItem     := AllTrim(SN1->N1_ITEM)
    Local nQuant    := SN1->N1_QUANTD
	Local nQDig     := 0
	Local lValid    := .F.
	Private oDlg1

	//Fontes
	Private cFontUti    := "Tahoma"
	Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
	Private oFontBtn    := TFont():New(cFontUti, , -14)

    //Tela para digitar quantidade
	DEFINE MsDialog oDlg1 TITLE "Replicar Ativos" STYLE DS_MODALFRAME FROM 0,0 TO 300,600 PIXEL

	@ 10,10 SAY oSay1 PROMPT 'Bem: ' + cBem + ', Item: ' + cItem + ', Quantidade: ' + cValToChar(nQuant) SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL
	@ 60,10 SAY oSay2 PROMPT 'Quantidade: ' SIZE 80,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL

	oTGet1:= TGet():New(60, 90,bSetGet( nQDig ), oDlg1, 20, 10,"@E 999",{||lValid := VldQtd(nQuant, nQDig),}, /*nClrFore*/, /*nClrBack*/, /*oFontPadrao*/, , , .T., /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*bChange*/, .F., /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, .F.)

	@ 130,090 BUTTON btnGrv PROMPT "Replicar"   SIZE 100, 017 FONT oFontBtn ACTION IIf(lValid,RepAtv(nQDig),MSGSTOP( "Quantidade digitada nao é valida!", "Validacao Quantidade!" )) OF oDlg1  PIXEL
	@ 130,195 BUTTON btnOut PROMPT "Sair" 	    SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End()) OF oDlg1  PIXEL

	ACTIVATE DIALOG oDlg1 CENTERED

Return

/*---------------------------------------------------------------------*
 | Func:  RepAtv                                                       |
 | Desc:  Funcao para Replicar ativos                                  |
 *---------------------------------------------------------------------*/
Static Function RepAtv(_nQDig)

    MSGINFO( "replicado", "Replicar" )

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
