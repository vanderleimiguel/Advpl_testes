#INCLUDE "Protheus.ch"

User Function FT140EXC()

Local lRet := .T.

    dbSelectArea("ACV")
    ACV->(dbSetOrder(1))
    ACV->(dbGoTop())
        While ACV->(!EOF()) .and. lRet == .T.
            iF ACU->ACU_COD == ACV->ACV_CATEGO
                lRet := .F.
                MSGSTOP( "Esta categoria possui amarracao de produtos, nao pode ser excluida", "Bloqueio" )
            EndIf
            ACV->(dbSkip())
        Enddo
    ACV->(dbCloseArea())

Return lRet
