//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToSED
Função para gravar dados de CSV para SED
@author Wagner Neves
@since 18/08/2023
@version 1.0
@type function
/*/
User Function CsvToSED()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv)", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| ImpCsvSED() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  CsvToSED                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function ImpCsvSED()
    Local aArea       := GetArea()
    Local nTotLinhas  := 0
    Local cLinAtu     := ""
    Local nLinhaAtu   := 0
    Local aLinha      := {}
    Local aColSED     := {} 
    Local oArquivo
    Local aLinhas
    Local cCodigo     := ""
    Local cDescric    := ""
    Local cTipo       := "" 
    Local cCond       := "" 
    Local cUso        := ""
    Local cPai        := ""
    Local cMovBco     := ""
    Local cMsBloq     := ""

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

            //Enquanto tiver linhas
            While (oArquivo:HasLine())
                aColSED     := {} 
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                //Define linhas a processar
                If nLinhaAtu >= 2 .AND. nLinhaAtu <= 139

                    If aLinha[3] == "Sintetico"
                        aLinha[3]   := "1"
                    ElseIf aLinha[3] == "Analitico"
                        aLinha[3]   := "2"
                    EndIf

                    aLinha[2]   := Limpar(aLinha[2])

                    //Extrai dados do array para as variaveis                   
                    cCodigo     := aLinha[1]
                    cDescric    := aLinha[2]
                    cTipo       := aLinha[3] 
                    cCond       := aLinha[4] 
                    cUso        := aLinha[5]
                    cPai        := aLinha[6]
                    cMovBco     := aLinha[7]
                    cMsBloq     := aLinha[8]
                    
                    //Array dos campos da SED
                    aadd(aColSED, cCodigo )
                    aadd(aColSED, cDescric ) 
                    aadd(aColSED, cTipo)   
                    aadd(aColSED, cCond) 
                    aadd(aColSED, cUso) 
                    aadd(aColSED, cPai)
                    aadd(aColSED, cMovBco) 
                    aadd(aColSED, cMsBloq) 

                    GravSED(aColSED)    
   
                EndIf
            EndDo

        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
 
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
 
    RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  GravSED                                                      |
 | Desc:  Função que grava Dados na SED                                |
 *---------------------------------------------------------------------*/
 
Static Function GravSED(_aColSED)
    Local aArea       := GetArea()
    DbSelectArea("SED")
    RecLock("SED", .T.)	

    //Dados do Arquivo CSV
    SED->ED_CODIGO      := _aColSED[1] 
	SED->ED_DESCRIC     := _aColSED[2]
	SED->ED_TIPO        := _aColSED[3]  
    SED->ED_COND        := _aColSED[4] 
	SED->ED_USO         := _aColSED[5]
	SED->ED_PAI         := _aColSED[6]  
    SED->ED_MOVBCO      := _aColSED[7] 
    SED->ED_MSBLQL      := _aColSED[8] 
    
    //Dados Padrões
    SED->ED_CALCIRF     := "N"
    SED->ED_CALCISS     := "N"
    SED->ED_CALCINS     := "N"
    SED->ED_CALCCSL     := "N"
    SED->ED_CALCCOF     := "N"
    SED->ED_CALCPIS     := "N"
    SED->ED_DEDPIS      := "2"
    SED->ED_DEDCOF      := "2"
    SED->ED_CALCSES     := "N"
    SED->ED_IRRFCAR     := "N"    
    SED->ED_INSSCAR     := "N" 
    SED->ED_DEDINSS     := "1"
    SED->ED_CALCFET     := "2"
    SED->ED_RATOBR      := "2"
    SED->ED_CFJUR       := "2"
    SED->ED_CPJUR       := "1"
    SED->ED_CRJUR       := "1"
    SED->ED_BANCJUR     := "2"
    SED->ED_CPRB        := "1"
    SED->ED_TPREG       := "1"
    SED->ED_DTINCLU     := DATE()
    SED->ED_RECIRRF     := "3"
    SED->ED_CALCFMP     := "2"
    SED->ED_RECFUN      := "1"
    SED->ED_F100        := "1"
    SED->ED_JURCAP      := "2"
    SED->ED_JURSPD      := "2"
    SED->ED_RINSSPA     := "2"
    SED->ED_ESCRIT      := "2"
    SED->ED_GRPJUR      := "2"
    SED->ED_ALUGUEL     := "1"  

    SED->(MsUnLock()) // Confirma e finaliza a operação
    RestArea(aArea)
Return

Static Function Limpar(cLimpa)
		
			cLimpa := StrTran(cLimpa, "!", "")
			cLimpa := StrTran(cLimpa, "#", "")
			cLimpa := StrTran(cLimpa, "@", "")
			cLimpa := StrTran(cLimpa, "$", "")
			cLimpa := StrTran(cLimpa, "%", "")
			cLimpa := StrTran(cLimpa, "&", "")
			cLimpa := StrTran(cLimpa, "*", "")
			cLimpa := StrTran(cLimpa, "(", "")
			cLimpa := StrTran(cLimpa, ")", "")
			cLimpa := StrTran(cLimpa, "_", "")
			cLimpa := StrTran(cLimpa, "=", "")
			cLimpa := StrTran(cLimpa, "+", "")
			cLimpa := StrTran(cLimpa, "{", "")
			cLimpa := StrTran(cLimpa, "}", "")
			cLimpa := StrTran(cLimpa, "[", "")
			cLimpa := StrTran(cLimpa, "]", "")
			cLimpa := StrTran(cLimpa, "/", "")
			cLimpa := StrTran(cLimpa, "?", "")
			cLimpa := StrTran(cLimpa, ".", "")
			cLimpa := StrTran(cLimpa, "\", "")
			cLimpa := StrTran(cLimpa, "|", "")
			cLimpa := StrTran(cLimpa, ":", "")
			cLimpa := StrTran(cLimpa, ";", "")
			cLimpa := StrTran(cLimpa, '"', '')
			cLimpa := StrTran(cLimpa, '°', '')
			cLimpa := StrTran(cLimpa, 'ª', '')
			cLimpa :=  FwNoAccent(cLimpa)

Return cLimpa
