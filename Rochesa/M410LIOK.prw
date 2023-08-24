#include 'protheus.ch'

/*/{Protheus.doc} M410LIOK
Ponto de entrada Validação de linha de pedido - ocorre durante a troca da linha da getdados
@author Wagner Neves
@since 23/08/2023
@version 1.0
@type function
/*/
User Function M410LIOK()

	Local lRet := .T.
	Local ni
	Local cItem     := ""
	Local cProduto  := ""
	Local cTes      := ""
    Local cCodAju   := ""
	Local cCodRef   := ""
	Local cIfComp   := ""
	Local cCodFisc  := ""
	Local cICMS     := ""

	For ni := 1 To Len(ACOLS)

		cItem     := ACOLS[1][1]
		cProduto  := ACOLS[1][2]
		cTes      := ACOLS[1][13]

        //Extrai dados na TES
		SF4->(DbSetOrder(1))
		SF4->(DbGoTop())
		If SF4->( DbSeek( xFilial("SF4") + cTes ) )
			cCodAju     := SF4->F4_XCODAJU
			cCodRef     := SF4->F4_XCODREF
			cIfComp     := SF4->F4_XIFCOMP
			cCodFisc    := SF4->F4_CF
			cICMS       := SF4->F4_SITTRIB

            //Verifica se dados estao preenchidos
			If Empty(cCodAju) .OR. Empty(cCodRef) .OR. Empty(cIfComp) .OR. Empty(cCodFisc) .OR. Empty(cICMS)
				MSGSTOP( "TES: " + cTes + " ,do item: " + cItem + " ,nao esta preenchido no Relacionamento TES x Cod.Val.Decl", "Bloqueio" )
				lRet := .F.
                EXIT
			EndIf

            //Verifica se produto esta na tabela F3K
			If lRet == .T.
				F3K->(DbSetOrder(1))
				F3K->(DbGoTop())
				If !F3K->( DbSeek( xFilial("F3K") + cProduto + cCodFisc ) )
					GravF3K(cCodAju, cCodRef, cIfComp, cCodFisc, cICMS, cProduto)
				EndIf
			EndIf
		EndIf
	Next ni

Return lRet

/*---------------------------------------------------------------------*
 | Func:  GravF3K                                                      |
 | Desc:  Função que grava Dados na Tabela F3K                         |
 *---------------------------------------------------------------------*/
Static Function GravF3K(_cCodAju, _cCodRef, _cIfComp, _cCodFisc, _cICMS, _cProduto)

    DbSelectArea("F3K")
    RecLock("F3K", .T.)	

    F3K->F3K_PROD       := _cProduto
    F3K->F3K_GRCLAN     := "" 
	F3K->F3K_GRPLAN     := ""
	F3K->F3K_GRFLAN     := ""  
    F3K->F3K_CFOP       := _cCodFisc
	F3K->F3K_CODAJU     := _cCodAju
	F3K->F3K_CST        := _cICMS  
    F3K->F3K_CODREF     := _cCodRef
    F3K->F3K_IFCOMP     := _cIfComp
    F3K->F3K_DINCLU     := DATE()

    F3K->(MsUnLock()) // Confirma e finaliza a operação

Return
