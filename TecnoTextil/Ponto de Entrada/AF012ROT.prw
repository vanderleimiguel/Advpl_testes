#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} AF012ROT
Ponto de entrada Inclusão de opção ao menu da rotina
@author Wagner Neves
@since 12/12/2023
@version 1.0
@type function
/*/
User Function AF012ROT()

    Local aNewRotina := PARAMIXB[1]

    If ExistBlock("TECREPA1")
        ADD OPTION aNewRotina TITLE "Replicar Ativo" ACTION "U_TECREPA1()" OPERATION 7 ACCESS 0
    EndIf

Return aNewRotina
