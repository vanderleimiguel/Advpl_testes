#include 'protheus.ch'

/*/{Protheus.doc} BloqTes
Função para Verificar grupo para permissao de alteração do campo C6_TES
@author Wagner Neves
@since 23/08/2023
@version 1.0
@type function
/*/
User Function BloqTes()

    Local cUserId   := ""
    Local aGrupo    := {}
    Local cGrupo    := ""
    Local lRet      := .T.

    cUserId := RetCodUsr()
    aGrupo  := UsrRetGrp(cUserId)
    cGrupo  := aGrupo[1]

    If cGrupo <> "000000"
        MSGALERT( "Voce nao tem permissao para alterar este campo", "Bloqueio" )
        lRet    := .F.
    EndIf

Return(lRet)
