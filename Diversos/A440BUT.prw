#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A440BUT
    Ponto de entrada inclusão de botão dentro da liberação do pedido
    @author Wagner Neves
    @since 27/04/2023
    @version 1.0
/*/

User Function A440BUT

	Local aArea := GetArea()
	Local aButtons := {}

	aAdd(aButtons, {"BUDGETY", {|| U_GCREL069() } , "Impressão do Pedido" } )

	RestArea(aArea)

Return aButtons
