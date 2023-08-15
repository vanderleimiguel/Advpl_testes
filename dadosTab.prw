#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function dadosTab()

	Local cQuery       := ""

	cQuery := "SELECT N1_GRUPO, N1_CBASE, N3_FILIAL, N3_CBASE, N3_TXDEPR1, N3_CCONTAB, N3_CCDEPR, N3_CDEPREC "
	cQuery += " FROM "+RetSqlName("SN1")+" SN1"
	cQuery += " INNER JOIN "+RetSqlName("SN3")+" SN3 ON N3_CBASE = N1_CBASE AND SN3.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE SN1.D_E_L_E_T_ = ''

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"tabQuery1",.F.,.T.)
	DbSelectArea("tabQuery1")
	tabQuery1->(DbGoTop())

	DbSelectArea("sn3")
	SN3->(DBGOTOP())
	dbsetOrder(1)

	While SN3->(!EOF())
		while tabQuery1->(!EOF())
			If  AllTrim(SN3->N3_FILIAL)+AllTrim(SN3->N3_CBASE) == AllTrim(tabQuery1->N3_FILIAL)+AllTrim(tabQuery1->N3_CBASE)
				RecLock("SN3",.F.)
				DO CASE
				CASE tabQuery1->N1_GRUPO == "0001"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100012"
					SN3->N3_CCDEPR   := "3120752019"
					SN3->N3_CDEPREC := "1250200011"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0002"
					SN3->N3_TXDEPR1 := 20
					SN3->N3_CCONTAB := "1250100017"
					SN3->N3_CCDEPR   := "3120752019"
					SN3->N3_CDEPREC := "1250200013"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0003"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100014"
					SN3->N3_CCDEPR   := "3150752023"
					SN3->N3_CDEPREC := "1250200012"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0004"
					SN3->N3_TXDEPR1 := 4
					SN3->N3_CCONTAB := "1250100003"
					SN3->N3_CCDEPR   := "3120551712"
					SN3->N3_CDEPREC := "1250200003"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0005"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100011"
					SN3->N3_CCDEPR   := "3120551712"
					SN3->N3_CDEPREC := "1250200010"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0006"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100007"
					SN3->N3_CCDEPR   := "3150752023"
					SN3->N3_CDEPREC := "1250200007"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0007"
					SN3->N3_TXDEPR1 := 20
					SN3->N3_CCONTAB := "1260010006"
					SN3->N3_CCDEPR   := "3150752023"
					SN3->N3_CDEPREC := "1260020002"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0008"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100009"
					SN3->N3_CCDEPR   := "3120752019"
					SN3->N3_CDEPREC := "1250200009"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0009"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100013"
					SN3->N3_CCDEPR   := "3120752019"
					SN3->N3_CDEPREC := "1250200002"
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0010"
					SN3->N3_TXDEPR1 := 0
					SN3->N3_CCONTAB := ""
					SN3->N3_CCDEPR   := ""
					SN3->N3_CDEPREC := ""
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0011"
					SN3->N3_TXDEPR1 := 0
					SN3->N3_CCONTAB := ""
					SN3->N3_CCDEPR   := ""
					SN3->N3_CDEPREC := ""
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0012"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100008"
					SN3->N3_CCDEPR   := "3150752023"
					SN3->N3_CDEPREC := "1250200008 "
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0013"
					SN3->N3_TXDEPR1 := 0
					SN3->N3_CCONTAB := "1250100015"
					SN3->N3_CCDEPR   := ""
					SN3->N3_CDEPREC := ""
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0014"
					SN3->N3_TXDEPR1 := 0
					SN3->N3_CCONTAB := ""
					SN3->N3_CCDEPR   := ""
					SN3->N3_CDEPREC := ""
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0015"
					SN3->N3_TXDEPR1 := 4
					SN3->N3_CCONTAB := ""
					SN3->N3_CCDEPR   := ""
					SN3->N3_CDEPREC := ""
					MsUnlock()
				CASE tabQuery1->N1_GRUPO == "0016"
					SN3->N3_TXDEPR1 := 10
					SN3->N3_CCONTAB := "1250100005"
					SN3->N3_CCDEPR   := "3150752023"
					SN3->N3_CDEPREC := "1250200005"
					MsUnlock()
				ENDCASE
			EndIf
			tabQuery1->(DbSkip())
		EndDo
		tabQuery1->(DbGoTop())
		SN3->(DbSkip())
	EndDo

	SN3->(DbCloseArea())
	tabQuery1->(DbCloseArea())

    MSGINFO( "Dados atualizados com sucesso", "Atualizacao" )

Return
