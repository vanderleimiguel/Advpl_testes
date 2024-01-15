#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

class fswComissoes from rochesa.fswBaseObj
    Static Method GetQuery( cSql as Character, aParam as Array, cAlias as Character ) as Character
EndClass

User Function CodeAnalys()

Return

Method GetQuery( cSql as Character, aParam as Array, cAlias as Character ) as Character Class fswBaseObj

    Local cRet as Character
    Local nI   as Numeric
    Local oSt  as Object

    cRet := ''

    oSt := FWPreparedStatement():New()
        //Define a consulta e os parâmetros
        oSt:SetQuery( cSql )

        for nI := 1 to len( aParam )
            do case
                case ValType( aParam[nI] ) == 'C'
                    oSt:SetString( nI, aParam[nI] )

                case ValType( aParam[nI] ) == 'N'
                    oSt:setNumeric( nI, aParam[nI] )

                case ValType( aParam[nI] ) == 'D'
                    oSt:SetDate( nI, aParam[nI] )

                case ValType( aParam[nI] ) == 'L'
                    oSt:SetBoolean( nI, aParam[nI] )

                case ValType( aParam[nI] ) == 'A'
                    oSt:setIn( nI, aParam[nI] )
            endcase
        next

        cRet := MpSysOpenQuery( changeQuery( oSt:GetFixQuery() ), cAlias )
        if (Select( cRet ) == 0)
            UserException('Erro ao processar a query: ' + alltrim(cSql) + ".")
        endif
    fwFreeVar( @oSt )

Return cret
