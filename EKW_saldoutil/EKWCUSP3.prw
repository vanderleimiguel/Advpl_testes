// #INCLUDE "MATR320.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} EKWCUSP3
Função para buscar dados de entrada e saidas de produtos
@author Wagner Neves
@since 20/12/2023
@version 1.0
@type function
/*/
User Function EKWCUSP3(_cTipo, _cProduto, _Local, _dDiaIni, _dDiaFinal)
	Local oReport
	Local aDados	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef(_cTipo, _cProduto, _Local, _dDiaIni, _dDiaFinal)
	aDados	:= ReportPrint(oReport)
// oReport:PrintDialog()

Return aDados
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ReportDef ³ Autor ³Nereu Humberto Junior  ³ Data ³23.06.2006³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
	±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³Nenhum                                                      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(_cTipo, _cProduto, _Local, _dDiaIni, _dDiaFinal)

	Local oReport
	Local oSection1
	// Local oCell
	Local cTamVlr  := 20
	Local cPictVl  := PesqPict("SD2","D2_CUSTO1",20)
	Local cProcNam := GetSPName("MAT056","22")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("MATR320","Resumo das Entradas e Saidas","MTR320", {|oReport| ReportPrint(oReport)},"STR0002"+" "+"STR0003"+" "+"STR0004") //"Resumo das Entradas e Saidas"##"Este programa mostra um resumo ,por tipo de material ,de todas  as  suas"##"entradas e saidas. A coluna SALDO INICIAL  e' o  resultado da  soma  das"##"outras colunas do relatorio e nao o saldo inicial cadastrado no estoque."
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)

//Parametros originais, agora recebidos via funcao
	mv_par01	:= _Local     // Almoxarifado De
	mv_par02	:= _Local     // Almoxarifado Ate
	mv_par03	:= _cTipo     // Tipo inicial
	mv_par04	:= _cTipo     // Tipo final
	mv_par05	:= _cProduto     // Produto inicial
	mv_par06	:= _cProduto     // Produto Final
	mv_par07	:= _dDiaIni     // Emissao de
	mv_par08	:= _dDiaFinal     // Emissao ate
	mv_par09	:= 1     // moeda selecionada ( 1 a 5 )
	mv_par10	:= 3     // Saldo a considerar : Atual / Fechamento
	mv_par11	:= 1     // Considera Saldo MOD: Sim / Nao
	mv_par12	:= 1     // Imprime OPs geradas pelo SIGAMNT? Sim / Nao

	oSection1 := TRSection():New(oReport,"Movimentacoes dos Produtos",{"SB1","SD1","SD2","SD3"}) //"Movimentacoes dos Produtos"
	oSection1 :SetTotalInLine(.F.)
	oSection1 :SetNoFilter("SD1")
	oSection1 :SetNoFilter("SD2")
	oSection1 :SetNoFilter("SD3")
//	If ExistProc( cProcNam, VerIDProc())
//		oSection1 :SetNoFilter("SB1")
//	EndIf
	TRCell():New(oSection1,"cTipant"	,"   ",/*Titulo*/			,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oSection1:Cell("cTipant"):GetFieldInfo("B1_TIPO")
	TRCell():New(oSection1,"nSalant"	,"   ","Saldo"+CRLF+"Inicial"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saldo"##"Inicial"
	TRCell():New(oSection1,"nCompras"	,"   ","Compras"				,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Compras"
	TRCell():New(oSection1,"nReqCons"	,"   ","Movimentacoes"+CRLF+"Internas"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Movimentacoes"##"Internas"
	TRCell():New(oSection1,"nReqProd"	,"   ","Requisicoes"+CRLF+"para Producao"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Requisicoes"##"para Producao"
	TRCell():New(oSection1,"nReqTrans"	,"   ","Transferencias"				,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Transferencias"
	TRCell():New(oSection1,"nProducao"	,"   ","Producao"				,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Producao"
	TRCell():New(oSection1,"nVendas"	,"   ","Vendas"				,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Vendas"
	TRCell():New(oSection1,"nReqOutr"	,"   ","Transf. p/"+CRLF+"Processo"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Transf. p/"##"Processo"
	TRCell():New(oSection1,"nDevVendas"	,"   ","Devolucao de"+CRLF+"Vendas"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Devolucao de"##"Vendas"
	TRCell():New(oSection1,"nDevComprs"	,"   ","Devolucao de"+CRLF+"Compras"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Devolucao de"##"Compras"
	TRCell():New(oSection1,"nEntrTerc"	,"   ","Entrada Poder"+CRLF+"Terceiros"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Entrada Poder"##"Terceiros"
	TRCell():New(oSection1,"nSaiTerc"	,"   ","Saida Poder"+CRLF+"Terceiros"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saida Poder"##"Terceiros"
	TRCell():New(oSection1,"nSaldoAtu"	,"   ","Saldo"+CRLF+"Atual"	,cPictVl,cTamVlr	,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Saldo"##"Atual"

	TRFunction():New(oSection1:Cell("nSalant"   ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nCompras"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nReqCons"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nReqProd"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nReqTrans" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nProducao" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nVendas"   ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nReqOutr"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nDevVendas"),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nDevComprs"),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nEntrTerc" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nSaiTerc"  ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)
	TRFunction():New(oSection1:Cell("nSaldoAtu" ),NIL,"SUM",/*oBreak*/,"",cPictVl,/*uFormula*/,.F.,.T.)

Return(oReport)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³21.06.2006³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
	±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³Nenhum                                                      ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasSDH)
	Local aDados	:= {}
	Local oSection1	:= oReport:Section(1)
	Local cSelectD1 := '', cWhereD1 := ''
	Local cSelectD2 := '', cWhereD2 := ''
	Local cSelectD3 := '', cWhereD3 := ''
	Local cSelectB2 := '', cWhereB2 := ''
	Local lContinua :=.T.
	Local lPassou   :=.F.
	Local lTotal    :=.F.
	Local nValor    := 0
	Local nQtd      := 0
	Local cProduto  := ""
	Local cFiltroUsr:= ""
	Local nSalant,nCompras,nReqCons,nReqProd,nEntrTerc,nReqMNT
	Local nSaiTerc,cTipAnt,cCampo,cMoeda,nReqTrans,nProducao,nReqProc
	Local nVendas,nSaldoAtu,nReqOutr,nDevVendas,nDevComprs
	Local cSelect	:= ''
	Local cSelect1	:= ''
	Local aStrucSB1 := SB1->(dbStruct())
	Local cName		:= ""
	Local nX        := 0
	Local aResult   := {'',0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local cProcNam  := GetSPName("MAT056","22")
	Local lD3Servico:= GetMV('MV_D3SERVI', .F., 'N')=='S'
	Local cAliasTop := ""
	Local cLocProc	:= GetMvNNR('MV_LOCPROC','99')
	Local cCQ		:= GetMvNNR('MV_CQ','98')
	Local cWMSNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
	Local lLocProc  := .F.
	Local nQtdProd	:= 0
	Local nQtdCons	:= 0
	Local nQtdVnds	:= 0
	Local nQtdDev	:= 0

	cMoeda := LTrim(Str(mv_par09))
	cMoeda := IIF(cMoeda=="0","1",cMoeda)
	oReport:SetTitle( oReport:Title()+"STR0007"+AllTrim(GetMv("MV_SIMB"+cMoeda))+" - "+"STR0035"+dtoc(mv_par07,"ddmmyy")+"STR0036"+dtoc(mv_par08,"ddmmyy"))

	oReport:NoUserFilter()  // Desabilita a aplicacao do filtro do usuario no filtro/query das secoes

	cFiltroUsr := oSection1:GetAdvplExp()

	dbSelectArea("SD2")
	dbSetOrder(1)
	nRegs := SD2->(LastRec())

	dbSelectArea("SD3")
	dbSetOrder(1)
	nRegs += SD3->(LastRec())

	dbSelectArea("SD1")
	dbSetOrder(1)
	nRegs += SD1->(LastRec())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento do relatorio com Stored Procdures                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

		cAliasTop := GetNextAlias()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatorio da secao 1                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(1):BeginQuery()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta rotina foi escrita para adicionar no select os campos         ³
		//³usados no filtro do usuario quando houver, a rotina acrecenta      ³
		//³somente os campos que forem adicionados ao filtro testando         ³
		//³se os mesmo já existem no select ou se forem definidos novamente   ³
		//³pelo o usuario no filtro, esta rotina acrecenta o minimo possivel  ³
		//³de campos no select pois pelo fato da tabela SD1 ter muitos campos |
		//³e a query ter UNION, ao adicionar todos os campos do SD1 podera'   |
		//³derrubar o TOP CONNECT e abortar o sistema.                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	cSelect  := "B1_COD,B1_TIPO,B1_UM,B1_GRUPO,B1_DESC," //  comentado esta linha pois ao definir o filtro pelo usuario não 
		//  era adicionado nenhum campo de filtro se estivesse relacionado
		cSelect1 := "%"
		cSelect2 := "%"
		oSection1:GetAdvplExp()
		If !Empty(cFiltroUsr)
			For nX := 1 To SB1->(FCount())
				cName := SB1->(FieldName(nX))
				If AllTrim( cName ) $ cFiltroUsr
					If aStrucSB1[nX,2] <> "M"
						If !cName $ cSelect
							cSelect1 += cName + ","
						EndIf
					EndIf
				EndIf
			Next
			cSelect1 += "%"
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Complemento do SELECT da tabela SD1                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSelectD1 := "% D1_CUSTO"
		If mv_par09 > 1
			cSelectD1 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
		EndIf
		cSelectD1 += " CUSTO,"
		cSelectD1 += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Complemento do WHERE da tabela SD1                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhereD1 := "%"
		If cPaisLoc <> "BRA"
			cWhereD1 += " AND D1_REMITO = '" + Space(TamSx3("D1_REMITO")[1]) + "' "
		EndIf
		cWhereD1 += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Complemento do SELECT da tabela SD2                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSelectD2 := "% D2_CUSTO"
		cSelectD2 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
		cSelectD2 += " CUSTO,"
		cSelectD2 += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Complemento do WHERE da tabela SD2                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhereD2 := "%"
		If cPaisLoc <> "BRA"
			cWhereD2 += " AND D2_REMITO = '" + Space(TamSx3("D2_REMITO")[1]) + "' "
		EndIf
		cWhereD2 += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Complemento do SELECT da tabelas SD3                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSelectD3 := "% D3_CUSTO"
		cSelectD3 += Str(mv_par09,1,0) // Coloca a Moeda do Custo
		cSelectD3 +=	" CUSTO,"
		cSelectD3 += "%"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Complemento do WHERE da tabela SD3                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cWhereD3 := "%"
		If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
			cWhereD3 += " AND D3_ESTORNO <> 'S'"
		EndIf
		If SuperGetMV('MV_D3SERVI', .F., 'N') == 'N' .And. IntDL()
			cWhereD3 += " AND ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500')  "
			cWhereD3 += " OR  (D3_SERVIC <> '   ' AND D3_TM > '500' AND D3_LOCAL ='"+GetMvNNR('MV_CQ','98')+"') )"
		EndIf
		cWhereD3 += "%"

		BeginSql Alias cAliasTop

		SELECT 	'SD1' ARQ, 				//-- 01 ARQ
				 SB1.B1_COD PRODUTO, 	//-- 02 PRODUTO
				 SB1.B1_TIPO, 			//-- 03 TIPO
				 SB1.B1_UM,   			//-- 04 UM
				 SB1.B1_GRUPO,      	//-- 05 GRUPO
				 SB1.B1_DESC,      		//-- 06 DESCR
 				 %Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				 D1_DTDIGIT DTDIGIT,	//-- 08 DATA
				 D1_TES TES,			//-- 09 TES
				 D1_CF CF,				//-- 10 CF
				 D1_NUMSEQ SEQUENCIA,	//-- 11 SEQUENCIA
				 D1_DOC DOCUMENTO,		//-- 12 DOCUMENTO
				 D1_SERIE SERIE,		//-- 13 SERIE
				 D1_QUANT QUANTIDADE,	//-- 14 QUANTIDADE
				 D1_QTSEGUM QUANT2UM,	//-- 15 QUANT2UM
				 D1_LOCAL ARMAZEM,		//-- 16 ARMAZEM
				 ' ' OP,				//-- 17 OP
				 D1_FORNECE FORNECEDOR,	//-- 18 FORNECEDOR
				 D1_LOJA LOJA,			//-- 19 LOJA
				 D1_TIPO TIPONF,		//-- 20 TIPO NF
				 %Exp:cSelectD1%		//-- 21 CUSTO / 21 B1_CODITE	
				 SD1.R_E_C_N_O_ NRECNO  //-- 22 RECNO
	
		FROM %table:SB1% SB1,%table:SD1% SD1,%table:SF4% SF4
	
		WHERE SB1.B1_COD     =  SD1.D1_COD		AND  	SD1.D1_FILIAL  =  %xFilial:SD1%		AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%  	AND 	SD1.D1_TES     =  SF4.F4_CODIGO		AND
			  SF4.F4_ESTOQUE =  'S'				AND 	SD1.D1_DTDIGIT >= %Exp:mv_par07%   AND
			  SD1.D1_DTDIGIT <= %Exp:mv_par08%	AND		SD1.D1_ORIGLAN <> 'LF'				AND
			  SD1.D1_LOCAL   >= %Exp:mv_par01%	AND		SD1.D1_LOCAL   <= %Exp:mv_par02%	AND
			  SD1.%NotDel%						AND 	SF4.%NotDel%                        AND
	          SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD     <= %Exp:mv_par06% 	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND		SB1.B1_TIPO    >= %Exp:mv_par03%	AND
			  SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%						   		  
			  %Exp:cWhereD1%
		
	    UNION
	    
		SELECT 'SD2',	     			//-- 01 ARQ
				SB1.B1_COD,	        	//-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,		    //-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				D2_EMISSAO,				//-- 08 DATA
				D2_TES,					//-- 09 TES
				D2_CF,					//-- 10 CF
				D2_NUMSEQ,				//-- 11 SEQUENCIA
				D2_DOC,					//-- 12 DOCUMENTO
				D2_SERIE,				//-- 13 SERIE
				D2_QUANT,				//-- 14 QUANTIDADE
				D2_QTSEGUM,				//-- 15 QUANT2UM
				D2_LOCAL,				//-- 16 ARMAZEM
				' ',					//-- 17 OP
				D2_CLIENTE,				//-- 18 FORNECEDOR
				D2_LOJA,				//-- 19 LOJA
				D2_TIPO,				//-- 20 TIPO NF
				%Exp:cSelectD2%			//-- 21 CUSTO 
				SD2.R_E_C_N_O_ SD2RECNO //-- 22 RECNO
				
		FROM %table:SB1% SB1,%table:SD2% SD2,%table:SF4% SF4
			
		WHERE	SB1.B1_COD     =  SD2.D2_COD		AND	SD2.D2_FILIAL  = %xFilial:SD2%		AND
				SF4.F4_FILIAL  = %xFilial:SF4% 		AND	SD2.D2_TES     =  SF4.F4_CODIGO		AND
				SF4.F4_ESTOQUE =  'S'				AND	SD2.D2_EMISSAO >= %Exp:mv_par07%	AND
				SD2.D2_EMISSAO <= %Exp:mv_par08%	AND	SD2.D2_ORIGLAN <> 'LF'				AND
				SD2.D2_LOCAL   >= %Exp:mv_par01%	AND	SD2.D2_LOCAL   <= %Exp:mv_par02%	AND
				SD2.%NotDel%						AND SF4.%NotDel%						AND
		        SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%						   		  
  				%Exp:cWhereD2%
				
		UNION		
	
		SELECT 	'SD3',	    			//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,	     	//-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO				
				D3_EMISSAO,				//-- 08 DATA
				D3_TM,					//-- 09 TES
				D3_CF,					//-- 10 CF
				D3_NUMSEQ,				//-- 11 SEQUENCIA
				D3_DOC,					//-- 12 DOCUMENTO
				' ',					//-- 13 SERIE
				D3_QUANT,				//-- 14 QUANTIDADE
				D3_QTSEGUM,				//-- 15 QUANT2UM
				D3_LOCAL,				//-- 16 ARMAZEM
				D3_OP,					//-- 17 OP
				' ',					//-- 18 FORNECEDOR
				' ',					//-- 19 LOJA
				' ',					//-- 20 TIPO NF
				%Exp:cSelectD3%			//-- 21 CUSTO
				SD3.R_E_C_N_O_ SD3RECNO //-- 22 RECNO
	
		FROM %table:SB1% SB1,%table:SD3% SD3
		
		WHERE	SB1.B1_COD     =  SD3.D3_COD 		AND SD3.D3_FILIAL  =  %xFilial:SD3%		AND
				SD3.D3_EMISSAO >= %Exp:mv_par07%	AND	SD3.D3_EMISSAO <= %Exp:mv_par08%	AND
				SD3.D3_LOCAL   >= %Exp:mv_par01%	AND	SD3.D3_LOCAL   <= %Exp:mv_par02%	AND
				SD3.%NotDel%						                                   		AND
		        SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%					   	   		  
				%Exp:cWhereD3%				
				
		UNION
		
		SELECT 	'SB1',			     	//-- 01 ARQ
				SB1.B1_COD,	    	    //-- 02 PRODUTO
				SB1.B1_TIPO,		    //-- 03 TIPO
				SB1.B1_UM,				//-- 04 UM
				SB1.B1_GRUPO,		    //-- 05 GRUPO
				SB1.B1_DESC,		    //-- 06 DESCR
				%Exp:cSelect1%			//-- 07 FILTRO COM CAMPOS DO USUARIO
				' ',					//-- 08 DATA
				' ',					//-- 09 TES
				' ',					//-- 10 CF
				' ',					//-- 11 SEQUENCIA	
				' ',					//-- 12 DOCUMENTO
				' ',					//-- 13 SERIE
				0,						//-- 14 QUANTIDADE
				0,						//-- 15 QUANT2UM
				' ',	    			//-- 16 ARMAZEM
				' ',					//-- 17 OP
				' ',					//-- 18 FORNECEDOR
				' ',					//-- 19 LOJA
				' ',					//-- 20 TIPO NF
				0,						//-- 21 CUSTO 
				0						//-- 22 RECNO 
	
		FROM %table:SB1% SB1
		
		WHERE   SB1.B1_COD     >= %Exp:mv_par05%	AND		SB1.B1_COD  <= %Exp:mv_par06% 	AND
				SB1.B1_FILIAL  =  %xFilial:SB1%	    AND		SB1.B1_TIPO >= %Exp:mv_par03%	AND
				SB1.B1_TIPO    <= %Exp:mv_par04%	AND		SB1.%NotDel%					   	   		  
	
		ORDER BY 3,2,1
	
		EndSql
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Metodo EndQuery ( Classe TRSection )                                    ³
		//³                                                                        ³
		//³Prepara o relatorio para executar o Embedded SQL.                       ³
		//³                                                                        ³
		//³ExpA1 : Array com os parametros do tipo Range                           ³
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicio da impressao do fluxo do relatorio                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasTop)
		oReport:SetMeter(nRegs)

		oSection1:Init()

		While !oReport:Cancel() .And. !(cAliasTop)->(Eof())

			If oReport:Cancel()
				Exit
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtro de Usuario                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cFiltroUsr)
				If !(&cFiltroUsr)
					dbSelectArea(cAliasTop)
					dbSkip()
					Loop
				EndIf
			EndIf

			cTipant := (cAliasTop)->B1_TIPO
			oSection1:Cell("cTipant"):SetValue(cTipant)

			Store 0 TO 	nSalant,nCompras,nReqCons,nReqProd,nEntrTerc,nSaiTerc,nReqMNT,nQtdProd,nQtdCons,nQtdVnds,nQtdDev
			Store 0 TO 	nReqTrans,nProducao,nVendas,nSaldoAtu,nReqOutr,nDevVendas,nDevComprs,nReqProc
			lPassou := .F.
			lLocProc:= .F.

			While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->B1_TIPO == cTipAnt

				If oReport:Cancel()
					Exit
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtro de Usuario                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cFiltroUsr)
					If !(&cFiltroUsr)
						dbSelectArea(cAliasTop)
						dbSkip()
						Loop
					EndIf
				EndIf

				cProduto  := (cAliasTop)->PRODUTO

				oReport:IncMeter()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Saldo final e inicial dos almoxarifados                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SB2")
				dbSeek(xFilial()+cProduto+mv_par01,.T.)
				While !EOF() .And. B2_FILIAL+B2_COD == xFilial()+cProduto .And. B2_LOCAL <= mv_par02
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se deve somar custo da Mao de Obra no Saldo Final   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If	!(IsProdMod(SB2->B2_COD) .And. mv_par11 == 2)
						If SB2->B2_LOCAL == cLocProc
							lLocProc := .T.
						EndIf
						IF mv_par10==1
							nSaldoAtu := nSaldoAtu + &("B2_VATU"+cMoeda)
						Elseif mv_par10 == 2
							nSaldoAtu := nSaldoAtu + &("B2_VFIM"+cMoeda)
						Else
							aSaldoAtu	:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,mv_par08+1)
							nSaldoAtu 	:= nSaldoAtu + aSaldoAtu[mv_par09+1]
						EndIF
					EndIf
					dbSkip()
				EndDo

				lPassou := IIF(nSaldoAtu > 0,.t.,lPassou)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SB1 - Verifica Produtos Sem Movimento						 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SB1"
					dbSkip()
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SD1 - Pesquisa as Entradas de um determinado produto         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD1"

					dbSelectArea("SF4")
					dbSeek(xFilial()+(cAliasTop)->TES)
					dbSelectArea(cAliasTop)

					If SF4->F4_ESTOQUE == "S"
						nValor 	:= (cAliasTop)->CUSTO
						nQtd	:= (cAliasTop)->QUANTIDADE
						If SF4->F4_PODER3 == "N"
							If (cAliasTop)->TIPONF == "D"
								nDevVendas  += nValor
								nQtdDev     += nQtd
							Else
								nCompras += nValor
							EndIf
						Else
							nEntrTerc += nValor
						EndIf
						lPassou := .T.
					EndIf
					dbSkip()
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SD2 - Pesquisa Vendas                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD2"

					dbSelectArea("SF4")
					dbSeek(xFilial()+(cAliasTop)->TES)
					dbSelectArea(cAliasTop)
					If SF4->F4_ESTOQUE == "S"
						nValor 	:= (cAliasTop)->CUSTO
						nQtd	:= (cAliasTop)->QUANTIDADE
						If SF4->F4_PODER3 == "N"
							If (cAliasTop)->TIPONF == "D"
								nDevComprs += nValor
							Else
								nVendas  += nValor
								nQtdVnds += nQtd
							EndIf
						Else
							nSaiTerc += nValor
						EndIf
						lPassou := .T.
					EndIf
					dbSkip()
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SD3 - Pesquisa requisicoes                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasTop)
				While !Eof() .And. (cAliasTop)->PRODUTO == cProduto .And. Alltrim((cAliasTop)->ARQ) == "SD3"

					If SubStr(AllTrim((cAliasTop)->OP),7,2) == 'OS' .And. SubStr(AllTrim((cAliasTop)->OP),9,3) == '001' .And. MV_PAR12 == 2 .And. !__lPyme
						If (cAliasTop)->TES > "500"
							nReqMNT += (cAliasTop)->CUSTO*-1
						Else
							nReqMNT += (cAliasTop)->CUSTO
						EndIf
						dbskip()
						Loop
					EndIf

					nValor 	:= (cAliasTop)->CUSTO
					nQtd	:= (cAliasTop)->QUANTIDADE

					If (cAliasTop)->TES > "500"
						nValor := nValor*-1
					EndIf

					If Substr((cAliasTop)->CF,1,2) == "PR"
						nProducao += nValor
					ElseIf allTrim((cAliasTop)->CF)$"RE4/DE4"
						nReqTrans += nValor
					ElseIf Empty((cAliasTop)->OP) .And. Substr((cAliasTop)->CF,3,1) != "3"
						nReqCons += nValor
						nQtdCons  += nQtd
					ElseIf !Empty((cAliasTop)->OP)
						nReqProd += nValor
						nQtdProd += nQtd
					Else
						nReqOutr += nValor
						If !lLocProc
							nReqProc += nValor
						EndIf
					EndIf
					lPassou := .T.
					dbSkip()
				EndDo
				dbSelectArea(cAliasTop)
			EndDo

			If lPassou
				lTotal:=.T.

				nSalant := nSaldoAtu-nCompras-nReqProd-nReqCons-nProducao+nVendas-nReqTrans-IF(!lLocProc,nReqProc,Abs(nReqProc))-nDevVendas+nDevComprs-nEntrTerc+nSaiTerc

				oSection1:Cell("nSalant"   ):SetValue(nSalant)
				oSection1:Cell("nCompras"  ):SetValue(nCompras)
				oSection1:Cell("nReqCons"  ):SetValue(nReqCons)
				oSection1:Cell("nReqProd"  ):SetValue(nReqProd)
				oSection1:Cell("nReqTrans" ):SetValue(nReqTrans)
				oSection1:Cell("nProducao" ):SetValue(nProducao)
				oSection1:Cell("nVendas"   ):SetValue(nVendas)
				oSection1:Cell("nReqOutr"  ):SetValue(nReqOutr)
				oSection1:Cell("nDevVendas"):SetValue(nDevVendas)
				oSection1:Cell("nDevComprs"):SetValue(nDevComprs)
				oSection1:Cell("nEntrTerc" ):SetValue(nEntrTerc)
				oSection1:Cell("nSaiTerc"  ):SetValue(nSaiTerc)
				oSection1:Cell("nSaldoAtu" ):SetValue(nSaldoAtu)

				AADD(aDados, {"Saldo Inicial"				, ""	, nSalant})
				AADD(aDados, {"Compras"						, "SD1"	, nCompras})
				AADD(aDados, {"Movimentacoes Internas"		, "SD3"	, nReqCons})
				AADD(aDados, {"Requisicoes para Producao"	, "SD3"	, nReqProd})
				AADD(aDados, {"Transferencias"				, "SD3"	, nReqTrans})
				AADD(aDados, {"Producao"					, "SD3"	, nProducao})
				AADD(aDados, {"Vendas"						, "SD2"	, nVendas})
				AADD(aDados, {"Transf. p/ Processo"			, "SD3"	, nReqOutr})
				AADD(aDados, {"Devolucao de Vendas"			, "SD1"	, nDevVendas})
				AADD(aDados, {"Devolucao de Compras"		, "SD2"	, nDevComprs})
				AADD(aDados, {"Entrada Poder Terceiros"		, "SD1"	, nEntrTerc})
				AADD(aDados, {"Saida Poder Terceiros"		, "SD2"	, nSaiTerc})
				AADD(aDados, {"Saldo Atual"					, ""	, nSaldoAtu})
				AADD(aDados, {"Qtd Requisicao Producao"	    , ""	, nQtdProd})
				AADD(aDados, {"Qtd Movimentacao Interna"	, ""	, nQtdCons})
				AADD(aDados, {"Qtd Vendas"					, ""	, nQtdVnds})
				AADD(aDados, {"Qtd Devolucao Vendas"		, ""	, nQtdDev})

				// oSection1:PrintLine()
			EndIf
			dbSelectArea(cAliasTop)
		EndDo
		oSection1:Finish()
	//EndIf

Return aDados

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³VerIDProc ³ Autor ³ Marcelo Pimentel      ³ Data ³24.07.2007³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³Identifica a sequencia de controle do fonte ADVPL com a     ³±±
	±±³          ³stored procedure, qualquer alteracao que envolva diretamente³±±
	±±³          ³a stored procedure a variavel sera incrementada.            ³±±
	±±³          ³Procedure MAT005                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
Static Function VerIDProc()
Return '002'
