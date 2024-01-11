#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A440BUT
    Ponto de entrada inclus�o de bot�o dentro da libera��o do pedido
    @author Wagner Neves
    @since 27/04/2023
    @version 1.0
/*/

User Function A440BUT

	Local aArea := GetArea()
	Local aButtons := {}

	aAdd(aButtons, {"BUDGETY", {|| U_GCREL069() } , "Impress�o do Pedido" } )

	RestArea(aArea)

Return aButtons
