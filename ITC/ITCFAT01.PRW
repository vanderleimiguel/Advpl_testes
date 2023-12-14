//Bibliotecas
#Include "TOTVS.CH"
#Include "TOPCONN.CH"
#Include "RPTDEF.CH"


//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} ITCFAT01
Relatório - Pedidos de Venda - 
@author Wagner Neves
@since 21/07/2023
@version 1.0
	@example
	u_ITCFAT01()
	@obs 
/*/

User Function ITCFAT01()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""

	//Definições da pergunta
	cPerg := "ITCFAT01"

	Pergunte(cPerg,.T.)

	//Cria as definições do relatório
	oReport := fReportDef()

	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 4 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	Local oFunTot1 := Nil
	cTitulo := "Relação de Pedidos"
	//Criação do componente de impressão
	oReport := TReport():New(	"ITCFAT01",; //Nome do Relatório
								cTitulo,;	 //Título
								cPerg,;		 //Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	oReport:SetLineHeight(45)
	oReport:nFontBody := 8
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	

	//Colunas do relatório
	TRCell():New(oSectDad, "FILIAL" 	, "QRY_AUX", "Filial" 		  	    , /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PEDIDO"    	, "QRY_AUX", "Numero Pedido"   		, /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEM"  		, "QRY_AUX", "Numero Item"    		, /*cPicture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE"    , "QRY_AUX", "Cliente" , /*cPicture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOJACLI"    , "QRY_AUX", "Loja" , /*cPicture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME"    	, "QRY_AUX", "Nome Cliente"			,/*cPicture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "UFCLI"    	, "QRY_AUX", "UF Cliente"			,/*cPicture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "CLIENTR" 	, "QRY_AUX", "Cliente Entrega" 		,/*cPicture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOJAENT"    , "QRY_AUX", "Loja Entrega" 		,/*cPicture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TRANSP"	    , "QRY_AUX", "Transportadora" 		, /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOMTRANS"	, "QRY_AUX", "Nome Transportadora" 	, /*cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "TIPOCLI"	, "QRY_AUX", "Tipo Cliente" 		, /*cPicture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO_CLI"	, "QRY_AUX", "Descricao Tipo" 		, /*cPicture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "PEDCLI" 	, "QRY_AUX", "Pedido Cliente" 		, /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CONDPAG"    , "QRY_AUX", "Cond Pag." 			, /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRPG" 	, "QRY_AUX", "Descricao Cond Pagto"	, /*cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "CODVEN"  	, "QRY_AUX", "Vendedor"	   			, /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOMVEND"  	, "QRY_AUX", "Nome Vendedor"		, /*cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISPED"	, "QRY_AUX", "Emissao"      		, /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPFRETE"	, "QRY_AUX", "Tipo Frete"      		, /*cPicture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO_FRETE"	, "QRY_AUX", "Descrição"      		, /*cPicture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "VLRFRETE"	, "QRY_AUX", "Valor Frete"      	,"@E 999,999,999.99", 14.2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MENNOTA"	, "QRY_AUX", "MSG Nota"      		,/*@cPicture*/, 254, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODNATUR"	, "QRY_AUX", "Natureza"      		,/*@cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRNAT"	, "QRY_AUX", "Descricao Natureza"  	,/*@cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OBSINT"	    , "QRY_AUX", "OBS Interna"      	,/*@cPicture*/, 254, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "XSTATUS"	, "QRY_AUX", "Status"      			,/*@cPicture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESSTATUS"	, "QRY_AUX", "Descrição Status"    	,/*@cPicture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "PRODUTO"	, "QRY_AUX", "Produto"      		, /*cPicture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRPRO" 	, "QRY_AUX", "Descrição"    		, /*cPicture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "UMPROD" 	, "QRY_AUX", "UND"    				, /*cPicture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDVEN" 	, "QRY_AUX", "Quantidade"   		, "@E 999,999,999.99", 14.2 /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRCVEN" 	, "QRY_AUX", "Unitario"     		, "@E 999,999.999999", 14.5 /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALTOTPED" 	, "QRY_AUX", "Valor Total"     		, "@E 999,999,999.99", 14.2 /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALDESCPED" , "QRY_AUX", "Desconto"       		, "@E 999,999,999.99", 14.2,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALLIQPED" 	, "QRY_AUX", "Valor Líquido"   		, "@E 999,999,999.99", 14.2 /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODTES"    	, "QRY_AUX", "Tes"		   			, /*cPicture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TEXTOTES"  	, "QRY_AUX", "Descricao Tes"		, /*cPicture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFOPPED"  	, "QRY_AUX", "CFOP"	 				, /*cPicture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "NFISCAL"  	, "QRY_AUX", "Nota Fiscal"	   			, /*cPicture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "SERIENF"  	, "QRY_AUX", "Serie"	   		, /*cPicture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEMNF"  	, "QRY_AUX", "Item Nota"	 		, /*cPicture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTCTBNF"	, "QRY_AUX", "Data Contábil"   		, /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOTALNF"  	, "QRY_AUX", "Valor Total"        	, "@E 999,999,999.99", 14.2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "VLRBASICM"  , "QRY_AUX", "Base ICMS"        	, "@E 999,999,999.99", 14.2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLRICMS"    , "QRY_AUX", "Valor ICMS"       	, "@E 999,999,999.99", 14.2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NCMPROD"	, "QRY_AUX", "NCM"      			, /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLASFIS"	, "QRY_AUX", "CST"      			, /*cPicture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PERCICMS"	, "QRY_AUX", "Aliquota ICMS	"   	, "@E 999.99", 6.2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFORIG"		, "QRY_AUX", "NF ORIGEM"   			, /*cPicture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERORIG"	, "QRY_AUX", "SERIE NF ORIGEM" 		, /*cPicture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ORIGPAGA"	, "QRY_AUX", "PAGTO NF ORIGEM"		, /*cPicture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	                                   
	//Totalizadores
//	oFunTot1 := TRFunction():New(oSectDad:Cell("C6_VALOR"),,"SUM",,"Total Geral","@E 999,999,999.99") 
	/*            
	Sintaxe - TRFunction():New( <oCell> , <cName> , <cFunction> , <oBreak> , <cTitle> , <cPicture> , <uFormula> , <lEndSection> , <lEndReport> , <lEndPage> , <oParent> , <bCondition> , <lDisable> , <bCanPrint> )
	Parâmetros
	oCell		Objeto				Objeto da classe TRCell que o totalizador se refere	
	cName		Caracter			Identificação do totalizador	
	cFunction	Caracter			Função que será utilizada pelo totalizador. Exemplo: SUM, COUNT, MAX, MIN	
	oBreak		Objeto				Objeto da classe TRBreak que define em qual quebra o totalizador será impresso	
	cTitle		Caracter			Título do totalizador. Se não informado será utilizado o título da célula que o totalizador se refere	
	cPicture	Caracter			Máscara de impressão do totalizador. Se não informado será utilizado a máscara da célula que o totalizador se refere	
	uFormula	Caracter 			Tipo 		Caracter: Expressão ADVPL para macro execução
				Bloco de Código		Tipo 		Bloco de Código: Bloco de Código com a expressão ADVPL para execução
	lEndSection	Lógico				Se verdadeiro, indica se o totalizador será impresso na quebra de seção	
	lEndReport	Lógico				Se verdadeiro, indica se o totalizador será impresso no final do relatório	
	lEndPage	Lógico				Se verdadeiro, indica se o totalizador será impresso no final de cada página	
	oParent		Objeto				Objeto da classe TRSection que o totalizador se refere	
	bCondition	Bloco de Código		Bloco de Código com a condição de atualização dos valores do totalizador	
	lDisable	Lógico				Se verdadeiro, define que não irá atualizar os valores do totalizador	
	bCanPrint	Bloco de Código		Bloco de Código com a condição de impressão dos valores do totalizador	
	*/
	//oFunTot1 := TRFunction():New(oSectDad:Cell("VALTOTPED"),,"SUM",,,"@E 999,999,999.99",,,,,,,,)
	oFunTot1 := TRFunction():New(oSectDad:Cell("VALLIQPED"),,"SUM",,,"@E 999,999,999.99",,,,,,,,)
	oFunTot1:SetEndReport(.F.)
Return oReport

/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	//Local nListaTes:= ALLTRIM(GETMV("MV_XLKRF02")) //'501','503','504','506','507','509','511','514','520','570','580','581','590','50A'                                                                                                                                                                       
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT" 							+ STR_PULA
	cQryAux += " SC5.C5_FILIAL		FILIAL,"		+ STR_PULA
	cQryAux += " SC5.C5_NUM			PEDIDO,"		+ STR_PULA
	cQryAux += " SC6.C6_ITEM		ITEM,"			+ STR_PULA
	cQryAux += " SC5.C5_CLIENTE		CLIENTE,"		+ STR_PULA
	cQryAux += " SC5.C5_LOJACLI		LOJACLI,"		+ STR_PULA
	cQryAux += " SA1.A1_NOME		NOME,"			+ STR_PULA
	cQryAux += " SA1.A1_EST			UFCLI,"			+ STR_PULA
	cQryAux += " SC5.C5_CLIENT		CLIENTR,"		+ STR_PULA
	cQryAux += " SC5.C5_LOJAENT		LOJAENT,"		+ STR_PULA
	cQryAux += " SC5.C5_TRANSP		TRANSP," 		+ STR_PULA
	cQryAux += " SA4.A4_NOME		NOMTRANS," 		+ STR_PULA
	cQryAux += " SC5.C5_TIPOCLI		TIPOCLI,"		+ STR_PULA
	cQryAux += " CASE"						+ STR_PULA
	cQryAux += " WHEN SC5.C5_TIPOCLI = 'F' THEN 'CONSUMIDOR FINAL'" 	+ STR_PULA
	cQryAux += " WHEN SC5.C5_TIPOCLI = 'L' THEN 'PRODUTOR RURAL'"		+ STR_PULA
	cQryAux += " WHEN SC5.C5_TIPOCLI = 'R' THEN 'REVENDEDOR'" 			+ STR_PULA
	cQryAux += " WHEN SC5.C5_TIPOCLI = 'S' THEN 'SOLIDARIO'"			+ STR_PULA
	cQryAux += " WHEN SC5.C5_TIPOCLI = 'X' THEN 'EXPORTACAO'"			+ STR_PULA
	cQryAux += " ELSE ' '"					+ STR_PULA
	cQryAux += " END AS TIPO_CLI,"		+ STR_PULA	
	cQryAux +="  SC6.C6_PEDCLI		PEDCLI,"		+ STR_PULA
	cQryAux += " SC5.C5_CONDPAG		CONDPAG,"		+ STR_PULA
	cQryAux += " SE4.E4_DESCRI		DESCRPG,"		+ STR_PULA
	cQryAux += " SC5.C5_VEND1		CODVEN,"		+ STR_PULA
	cQryAux += " SA3.A3_NOME		NOMVEND,"		+ STR_PULA
	cQryAux += " SC5.C5_EMISSAO		EMISPED,"		+ STR_PULA
	cQryAux += " SC5.C5_TPFRETE		TIPFRETE,"		+ STR_PULA
	cQryAux += " CASE"								+ STR_PULA
	cQryAux += "    WHEN SC5.C5_TPFRETE = 'C' THEN 'CIF' "					+ STR_PULA
	cQryAux += "    WHEN SC5.C5_TPFRETE = 'F' THEN 'FOB' "					+ STR_PULA
	cQryAux += "    WHEN SC5.C5_TPFRETE = 'T' THEN 'CONTA TERCEIRO'" 		+ STR_PULA
	cQryAux += "    WHEN SC5.C5_TPFRETE = 'R' THEN 'CONTA REMETENTE'" 		+ STR_PULA
	cQryAux += "    WHEN SC5.C5_TPFRETE = 'D' THEN 'CONTA DESTINATARIO'"	+ STR_PULA
	cQryAux += "    WHEN SC5.C5_TPFRETE = 'S' THEN 'SEM FRETE'"				+ STR_PULA
	cQryAux += " ELSE ' '"							+ STR_PULA
	cQryAux += " END AS TIPO_FRETE,"				+ STR_PULA	
	cQryAux += " SC5.C5_FRETE		VLRFRETE,"		+ STR_PULA
	cQryAux += " SC5.C5_MENNOTA		MENNOTA,"		+ STR_PULA
	cQryAux += " SC5.C5_NATUREZ		CODNATUR,"		+ STR_PULA
	cQryAux += " SED.ED_DESCRIC		DESCRNAT,"		+ STR_PULA
	cQryAux += " SC5.C5_OBSINT		OBSINT,"		+ STR_PULA
	cQryAux += " SC5.C5_XSTATUS		XSTATUS,"		+ STR_PULA
	cQryAux += " CASE"								+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '1' THEN 'PENDENTE' " 				+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '2' THEN 'APROVADO' "					+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '3' THEN 'AUT/FAT'" 		+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '4' THEN 'FORNEC/PROD'" 		+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '5' THEN 'PERSONALIZACAO'"	+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '6' THEN 'MOSTRUARIO'"			+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '7' THEN 'DOAÇÃO'" 		+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '8' THEN 'FATURADO'"	+ STR_PULA
	cQryAux += " WHEN SC5.C5_XSTATUS = '9' THEN 'CANCELADO'"			+ STR_PULA
	cQryAux += " ELSE ' '"					+ STR_PULA
	cQryAux += " END AS DESSTATUS,"		+ STR_PULA	
	cQryAux += " SC6.C6_PRODUTO		PRODUTO,"		+ STR_PULA
	cQryAux += " SC6.C6_DESCRI		DESCRPRO,"		+ STR_PULA
	cQryAux += " SC6.C6_UM			UMPROD,"		+ STR_PULA
	cQryAux += " SC6.C6_QTDVEN		QTDVEN,"		+ STR_PULA
	cQryAux += " SC6.C6_PRCVEN		PRCVEN,"		+ STR_PULA
	cQryAux += " (SC6.C6_VALOR+SC6.C6_VALDESC)	VALTOTPED,"	+ STR_PULA 	
	cQryAux += " SC6.C6_VALDESC		VALDESCPED,"	+ STR_PULA
	cQryAux += " SC6.C6_VALOR       VALLIQPED,	"	+ STR_PULA
	cQryAux += " SC6.C6_TES			CODTES,"		+ STR_PULA
	cQryAux += " SF4.F4_TEXTO		TEXTOTES,"		+ STR_PULA
	cQryAux += " SC6.C6_CF			CFOPPED,"		+ STR_PULA
	cQryAux += " SD2.D2_DOC			NFISCAL,"		+ STR_PULA	
	cQryAux += " SD2.D2_SERIE		SERIENF,"		+ STR_PULA
	cQryAux += " SD2.D2_ITEM		ITEMNF,"		+ STR_PULA
	cQryAux += " SD2.D2_EMISSAO		DTCTBNF,"		+ STR_PULA
	cQryAux += " SD2.D2_TOTAL		TOTALNF,"		+ STR_PULA
	cQryAux += " SD2.D2_BASEICM		VLRBASICM,"		+ STR_PULA
	cQryAux += " SD2.D2_VALICM		VLRICMS,"		+ STR_PULA
	cQryAux += " SB1.B1_POSIPI		NCMPROD,"		+ STR_PULA		
	cQryAux += " SF4.F4_SITTRIB		CLASFIS,"		+ STR_PULA
	cQryAux += " SD2.D2_PICM		PERCICMS,"		+ STR_PULA
	cQryAux += " ' '  				NFORIG,"		+ STR_PULA
	cQryAux += " ' '				SERORIG,"		+ STR_PULA
	cQryAux += " ' ' 				ORIGPAGA"		+ STR_PULA


	cQryAux += " FROM "+RetSqlName("SC5")+" AS SC5" + STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SC6")+" AS SC6 ON SC6.C6_FILIAL=SC5.C5_FILIAL"								+ STR_PULA
	cQryAux += " AND SC6.C6_NUM=SC5.C5_NUM AND SC6.D_E_L_E_T_=' '"														+ STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SB1")+" AS SB1 ON SB1.B1_FILIAL=SUBSTRING(SC5.C5_FILIAL,1,4) AND SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_=' '"		+ STR_PULA	
	cQryAux += " LEFT  JOIN " +RetSqlName("SA4")+" AS SA4 ON SA4.A4_FILIAL=SUBSTRING(SC5.C5_FILIAL,1,4) AND SA4.A4_COD = SC5.C5_TRANSP AND SA4.D_E_L_E_T_=' '"		+ STR_PULA
	cQryAux += " LEFT  JOIN " +RetSqlName("SA3")+" AS SA3 ON SA3.A3_FILIAL=SUBSTRING(SC5.C5_FILIAL,1,4) AND SA3.A3_COD = SC5.C5_VEND1 AND SA3.D_E_L_E_T_=' '"		+ STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SE4")+" AS SE4 ON SE4.E4_CODIGO=SC5.C5_CONDPAG AND SE4.D_E_L_E_T_ = ' '"	+ STR_PULA
	cQryAux += " LEFT JOIN "  +RetSqlName("SED")+" AS SED ON SED.ED_CODIGO=SC5.C5_NATUREZ AND SED.D_E_L_E_T_ = ' '"	+ STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SF4")+" AS SF4 ON SF4.F4_CODIGO=SC6.C6_TES AND SF4.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SA1")+" AS SA1 ON SA1.A1_FILIAL=SUBSTRING(SC5.C5_FILIAL,1,4) AND SA1.A1_COD=SC5.C5_CLIENTE AND SA1.A1_LOJA=SC5.C5_LOJACLI AND SA1.D_E_L_E_T_=' '"		+ STR_PULA	
	cQryAux += " LEFT JOIN  " +RetSqlName("SD2")+" AS SD2 ON SD2.D2_FILIAL=SC6.C6_FILIAL AND SD2.D2_PEDIDO=SC6.C6_NUM"	+ STR_PULA	
	cQryAux += " AND SD2.D2_ITEMPV=SC6.C6_ITEM AND SD2.D_E_L_E_T_=' '"													+ STR_PULA
	cQryAux += " LEFT  JOIN " +RetSqlName("SE1")+" AS SE1 ON SE1.E1_FILIAL=SD2.D2_FILIAL AND SE1.E1_NUM=SD2.D2_DOC AND SE1.E1_PREFIXO=SD2.D2_SERIE AND SE1.E1_CLIENTE=SD2.D2_CLIENTE AND SE1.E1_LOJA=SD2.D2_LOJA AND (SE1.E1_PARCELA='' OR SE1.E1_PARCELA='001') AND SE1.D_E_L_E_T_=' '"		+ STR_PULA			
	cQryAux += " WHERE"																									+ STR_PULA
	IF MV_PAR13 = 1 // Seleciona Filiais ?  1=Sim   2=Não
		cQryAux += " SC5.C5_FILIAL BETWEEN '" +MV_PAR14+"' AND '" +MV_PAR15+"' AND" 									+ STR_PULA
	ELSE
		cQryAux += " SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND"										 					+ STR_PULA
	ENDIF	
	cQryAux += " SC5.D_E_L_E_T_ = ' ' AND"																				+ STR_PULA
	cQryAux += " SC5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND" 						+ STR_PULA
	cQryAux += " SC5.C5_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' AND "											+ STR_PULA
	cQryAux += " SC5.C5_LOJACLI BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' AND "											+ STR_PULA
	cQryAux += " SC5.C5_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' AND "											+ STR_PULA	
	cQryAux += " SC5.C5_TRANSP BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' AND "											+ STR_PULA	
	cQryAux += " SC6.C6_PRODUTO BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"'"												+ STR_PULA
	
	//Busca devoluções
	cQryAux += " UNION ALL "
	
	cQryAux += "SELECT" 							+ STR_PULA
	cQryAux += " SD1.D1_FILIAL		FILIAL,"		+ STR_PULA
	cQryAux += " ' '				PEDIDO,"		+ STR_PULA
	cQryAux += " ' '				ITEM,"			+ STR_PULA
	cQryAux += " SD1.D1_FORNECE		CLIENTE,"		+ STR_PULA
	cQryAux += " SD1.D1_LOJA		LOJACLI,"		+ STR_PULA
	cQryAux += " SA1D.A1_NOME		NOME,"			+ STR_PULA
	cQryAux += " SA1D.A1_EST		UFCLI,"			+ STR_PULA
	cQryAux += " ' '				CLIENTR,"		+ STR_PULA
	cQryAux += " ' '				LOJAENT,"		+ STR_PULA
	cQryAux += " ' '				TRANSP," 		+ STR_PULA
	cQryAux += " ' '				NOMTRANS," 		+ STR_PULA
	cQryAux += " SA1D.A1_TIPO		TIPOCLI,"		+ STR_PULA

	cQryAux += " CASE"												+ STR_PULA
	cQryAux += " WHEN SA1D.A1_TIPO = 'F' THEN 'CONSUMIDOR FINAL'" 	+ STR_PULA
	cQryAux += " WHEN SA1D.A1_TIPO = 'L' THEN 'PRODUTOR RURAL'"		+ STR_PULA
	cQryAux += " WHEN SA1D.A1_TIPO = 'R' THEN 'REVENDEDOR'" 		+ STR_PULA
	cQryAux += " WHEN SA1D.A1_TIPO = 'S' THEN 'SOLIDARIO'"			+ STR_PULA
	cQryAux += " WHEN SA1D.A1_TIPO = 'X' THEN 'EXPORTACAO'"			+ STR_PULA
	cQryAux += " ELSE ' '"											+ STR_PULA
	cQryAux += " END AS TIPO_CLI,"									+ STR_PULA	
	cQryAux +="  ' '				PEDCLI,"		+ STR_PULA
	cQryAux += " ' '				CONDPAG,"		+ STR_PULA
	cQryAux += " ' '				DESCRPG,"		+ STR_PULA
	cQryAux += " ' '				CODVEN,"		+ STR_PULA
	cQryAux += " ' '				NOMVEND,"		+ STR_PULA
	cQryAux += " SD1.D1_EMISSAO		EMISPED,"		+ STR_PULA
	cQryAux += " ' '				TIPFRETE,"		+ STR_PULA
	cQryAux += " ' '				TIPO_FRETE,"	+ STR_PULA
	cQryAux += " ' '				VLRFRETE,"		+ STR_PULA
	cQryAux += " ' '				MENNOTA,"		+ STR_PULA
	cQryAux += " ' '				CODNATUR,"		+ STR_PULA
	cQryAux += " ' '				DESCRNAT,"		+ STR_PULA
	cQryAux += " ' '				OBSINT,"		+ STR_PULA
	cQryAux += " ' '				XSTATUS,"		+ STR_PULA
	cQryAux += " ' '				DESC_STAT,"		+ STR_PULA
	cQryAux += " SD1.D1_COD			PRODUTO,"		+ STR_PULA
	cQryAux += " SB1D.B1_DESC		DESCRPRO,"		+ STR_PULA
	cQryAux += " SB1D.B1_UM			UMPROD,"		+ STR_PULA
	cQryAux += " SD1.D1_QUANT*-1	QTDVEN,"		+ STR_PULA
	cQryAux += " ' '				PRCVEN,"		+ STR_PULA
	cQryAux += " ' '				VALTOTPED,"		+ STR_PULA
	cQryAux += " ' '				VALDESCPED,"	+ STR_PULA
	cQryAux += " ' '				VALLIQPED,"		+ STR_PULA
	cQryAux += " SD1.D1_TES			CODTES,"		+ STR_PULA
	cQryAux += " SF4D.F4_TEXTO		TEXTOTES,"		+ STR_PULA
	cQryAux += " SD1.D1_CF			CFOPPED,"		+ STR_PULA
	cQryAux += " SD1.D1_DOC			NFISCAL,"		+ STR_PULA	
	cQryAux += " SD1.D1_SERIE		SERIENF,"		+ STR_PULA
	cQryAux += " SD1.D1_ITEM		ITEMNF,"		+ STR_PULA
	cQryAux += " SD1.D1_DTDIGIT		DTCTBNF,"		+ STR_PULA
	cQryAux += " SD1.D1_TOTAL*-1	TOTALNF,"		+ STR_PULA
	cQryAux += " SD1.D1_BASEICM*-1	VLRBASICM,"		+ STR_PULA
	cQryAux += " SD1.D1_VALICM*-1	VLRICMS,"		+ STR_PULA
	cQryAux += " SB1D.B1_POSIPI		NCMPROD,"		+ STR_PULA		
	cQryAux += " SF4D.F4_SITTRIB	CLASFIS,"			+ STR_PULA
	cQryAux += " SD1.D1_PICM		PERCICMS,"		+ STR_PULA

	cQryAux += " SD1.D1_NFORI  		NFORIG,"		    + STR_PULA
	cQryAux += " SD1.D1_SERIORI		SERORIG,"		+ STR_PULA
	cQryAux += " SE1D.E1_BAIXA 		ORIGPAGA"		+ STR_PULA

	cQryAux += " FROM "+RetSqlName("SD1")+" AS SD1" + STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SB1")+" AS SB1D ON SB1D.B1_FILIAL=SUBSTRING(SD1.D1_FILIAL,1,4) AND SB1D.B1_COD = SD1.D1_COD AND SB1D.D_E_L_E_T_=' '"		+ STR_PULA	
	cQryAux += " INNER JOIN " +RetSqlName("SF4")+" AS SF4D ON SF4D.F4_CODIGO=SD1.D1_TES AND SF4D.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += " INNER JOIN " +RetSqlName("SA1")+" AS SA1D ON SA1D.A1_FILIAL=SUBSTRING(SD1.D1_FILIAL,1,4) AND SA1D.A1_COD=SD1.D1_FORNECE AND SA1D.A1_LOJA=SD1.D1_LOJA AND SA1D.D_E_L_E_T_=' '"		+ STR_PULA		
	cQryAux += " LEFT  JOIN " +RetSqlName("SE1")+" AS SE1D ON SE1D.E1_FILIAL=SD1.D1_FILIAL AND SE1D.E1_NUM=SD1.D1_NFORI AND SE1D.E1_PREFIXO=SD1.D1_SERIORI AND SE1D.E1_CLIENTE=SD1.D1_FORNECE AND SE1D.E1_LOJA=SD1.D1_LOJA AND (SE1D.E1_PARCELA='' OR SE1D.E1_PARCELA='001')AND SE1D.D_E_L_E_T_=' '"		+ STR_PULA		
	cQryAux += " WHERE"																									+ STR_PULA
	IF MV_PAR13 = 1 // Seleciona Filiais ?  1=Sim   2=Não
		cQryAux += " SD1.D1_FILIAL BETWEEN '" +MV_PAR14+"' AND '" +MV_PAR15+"' AND" 									+ STR_PULA
	ELSE
		cQryAux += " SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND"										 					+ STR_PULA
	ENDIF	
	cQryAux += " SD1.D_E_L_E_T_ = ' ' AND"																				+ STR_PULA
	cQryAux += " SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND" 						+ STR_PULA
	cQryAux += " SD1.D1_FORNECE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' AND "											+ STR_PULA
	cQryAux += " SD1.D1_LOJA    BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' AND "											+ STR_PULA
	cQryAux += " SD1.D1_COD		BETWEEN '"+MV_PAR11+"' AND '"+MV_PAR12+"' AND "											+ STR_PULA
	cQryAux += " SD1.D1_TIPO = 'D' "											+ STR_PULA

	cQryAux += " ORDER BY 1,17,2,3"  		                               									+ STR_PULA

	cQryAux := ChangeQuery(cQryAux)
	               
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
//	TCSetField("QRY_AUX", "C5_EMISSAO", "D")
//	TCSetField("QRY_AUX", "D2_EMISSAO", "D")
	TCSetField("QRY_AUX", "DTCTBNF", "D")
	TCSetField("QRY_AUX", "EMISPED", "D")
	TCSetField("QRY_AUX", "ORIGPAGA", "D")
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		oSectDad:PrintLine()		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())	
	RestArea(aArea)
Return               

