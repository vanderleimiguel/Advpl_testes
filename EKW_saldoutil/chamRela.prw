		// aCstSld		:= SldUtil((cAliasSB1)->B1_TIPO, (cAliasSB1)->B1_COD, (cAliasSB1)->B2_LOCAL, dDiaIni, dDiaFinal)    

		// nSldUtil	:= aCstSld[1]
		// nCstUtil	:= aCstSld[2]


/*---------------------------------------------------------------------*
 | Func:  SldUtil                                                      |
 | Desc:  Funcao para calcular Saldo Utilizado                         |
 *---------------------------------------------------------------------*/
Static Function SldUtil(_cTipo, _cProduto, _Local, _dDiaIni, _dDiaFinal)   
	Local nSldUtil		:= 0
	Local aDados    	:= {}
	Local aSldCst       := {}
	Local nCusto        := 0
	Local nSalant		:= 0
	Local nCompras		:= 0
	Local nReqCons		:= 0
	Local nReqProd		:= 0
	Local nReqTrans		:= 0
	Local nProducao		:= 0
	Local nVendas		:= 0
	Local nReqOutr		:= 0
	Local nDevVendas	:= 0
	Local nDevComprs	:= 0
	Local nEntrTerc		:= 0
	Local nSaiTerc		:= 0
	Local nSaldoAtu		:= 0 
	Local nQtdCons		:= 0
	Local nQtdProd		:= 0
	Local nQtdVnds		:= 0
	Local nQtdDev		:= 0
	Local nX

	//Busca dados de saldos utilizados
	aDados := U_EKWCUSP3(_cTipo, _cProduto, _Local, _dDiaIni, _dDiaFinal)
	If Len(aDados) = 17
		//Transforma valor negativo para positivo
		For nX := 1 To Len(aDados)
			If aDados[nX][3] < 0
				aDados[nX][3] := aDados[nX][3] * -1
			EndIf
		Next nX

		nSalant		:= aDados[1][3] //"Saldo Inicial"
		nCompras	:= aDados[2][3] //"Compras"	
		nReqCons	:= aDados[3][3] //"Movimentacoes Internas"	
		nReqProd	:= aDados[4][3] //"Requisicoes para Producao"
		nReqTrans	:= aDados[5][3] //"Transferencias"
		nProducao	:= aDados[6][3] //"Producao"
		nVendas		:= aDados[7][3] //"Vendas"	
		nReqOutr	:= aDados[8][3] //"Transf. p/ Processo"
		nDevVendas	:= aDados[9][3] //"Devolucao de Vendas"	
		nDevComprs	:= aDados[10][3] //"Devolucao de Compras"
		nEntrTerc	:= aDados[11][3] //"Entrada Poder Terceiros"	
		nSaiTerc	:= aDados[12][3] //"Saida Poder Terceiros"
		nSaldoAtu	:= aDados[13][3] //"Saldo Atual"
		nQtdProd	:= aDados[14][3] //"Qtd Requisicao Producao"
		nQtdCons	:= aDados[15][3] //"Qtd Movimentacao Interna"
		nQtdVnds	:= aDados[16][3] //"Qtd Vendas"
		nQtdDev		:= aDados[17][3] //"Qtd Devolucao Vendas"

		nCusto     	:= nReqCons + nReqProd + (nVendas - nDevVendas)
		nSldUtil    := nQtdCons + nQtdProd + (nQtdVnds - nQtdDev)

	EndIf

	//Grava Array
	AADD(aSldCst, nSldUtil )
	AADD(aSldCst, nCusto )

Return aSldCst
