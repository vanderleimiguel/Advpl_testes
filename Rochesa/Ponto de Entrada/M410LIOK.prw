#include 'protheus.ch'

/*/{Protheus.doc} M410LIOK
Ponto de entrada Validação de linha de pedido - ocorre durante a troca da linha da getdados
@author Wagner Neves
@since 24/08/2023
@version 1.0
@type function
/*/
User Function M410LIOK()

	Local lRet      := .T.
	Local cItem     := ""
	Local cProduto  := ""
	Local cTes      := ""
	Local cCodAju   := ""
	Local cCodRef   := ""
	Local cIfComp   := ""
	Local cCodFisc  := ""
	Local cSitTrib  := ""
	Local cFil      := ""
	Local nLinha    := N
    Local nPosItem  := 0
    Local nPosProd  := 0
    Local nPosTes   := 0        

	//Busca posicao na coluna
    nPosItem    := aScan(aHeader,{|X| Alltrim(Upper(X[2]))=="C6_ITEM"})
    nPosProd    := aScan(aHeader,{|X| Alltrim(Upper(X[2]))=="C6_PRODUTO"})
    nPosTes     := aScan(aHeader,{|X| Alltrim(Upper(X[2]))=="C6_TES"})

    cItem     	:= ACOLS[nLinha][nPosItem]
	cProduto  	:= ACOLS[nLinha][nPosProd]
	cTes      	:= ACOLS[nLinha][nPosTes]

	//Extrai dados na TES
	SF4->(DbSetOrder(1))
	SF4->(DbGoTop())
	If SF4->( DbSeek( xFilial("SF4") + cTes ) )
		cCodAju     := SF4->F4_XCODAJU
		cCodRef     := SF4->F4_XCODREF
		cIfComp     := SF4->F4_XIFCOMP
		cCodFisc    := SF4->F4_CF
		cSitTrib    := SF4->F4_SITTRIB
		cFil        := SF4->F4_FILIAL

		//Verifica se dados estao preenchidos
		If Empty(cCodAju) .OR. Empty(cCodRef) .OR. Empty(cIfComp) .OR. Empty(cCodFisc) .OR. Empty(cSitTrib)
			MSGSTOP( "TES: " + cTes + " ,do item: " + cItem + " ,nao esta preenchido no Relacionamento TES x Cod.Val.Decl", "Bloqueio" )
			lRet := .F.
		EndIf

		//Verifica se produto esta na tabela F3K
		If lRet == .T.
			F3K->(DbSetOrder(1))
			F3K->(DbGoTop())
			If !F3K->( DbSeek( cFil + cProduto + cCodFisc + cCodAju + cSitTrib ) )
				cProces     := .T.
			else
				cProces     := .F.
			EndIf

            //Grava dados na tabela F3K
			GravF3K(cFil, cCodAju, cCodRef, cIfComp, cCodFisc, cSitTrib, cProduto, cProces)
		EndIf
	EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  GravF3K                                                      |
 | Desc:  Função que grava Dados na Tabela F3K                         |
 *---------------------------------------------------------------------*/
Static Function GravF3K(_cFil, _cCodAju, _cCodRef, _cIfComp, _cCodFisc, _cSitTrib, _cProduto, _cProces)

    DbSelectArea("F3K")
    RecLock("F3K", _cProces)	

    F3K->F3K_FILIAL     := _cFil
    F3K->F3K_PROD       := _cProduto
    F3K->F3K_CFOP       := _cCodFisc
	F3K->F3K_CODAJU     := _cCodAju
	F3K->F3K_CST        := _cSitTrib  
    F3K->F3K_CODREF     := _cCodRef
    F3K->F3K_IFCOMP     := _cIfComp
    F3K->F3K_DINCLU     := DATE()

    F3K->(MsUnLock()) // Confirma e finaliza a operação

Return
