//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToCTT
Função para gravar dados de CSV para CTT
@author Wagner Neves
@since 18/08/2023
@version 1.0
@type function
/*/
User Function CsvToCTT()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv)", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| ImpCsvCTT() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  CsvToCTT                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function ImpCsvCTT()
    Local aArea       := GetArea()
    Local nTotLinhas  := 0
    Local cLinAtu     := ""
    Local nLinhaAtu   := 0
    Local aLinha      := {}
    Local aColCTT     := {} 
    Local oArquivo
    Local aLinhas
    Local cCusto      := ""
    Local cDesc01     := ""
    Local cClasse     := "" 
    Local cBloq       := "" 
    Local cDtExis     := ""
    Local cCCSup      := ""

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
                aColCTT     := {} 
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                //Define linhas a processar
                If nLinhaAtu >= 2 .AND. nLinhaAtu <= 80

                    If aLinha[3] == "SINTETICO"
                        aLinha[3]   := "1"
                    ElseIf aLinha[3] == "ANALITICO"
                        aLinha[3]   := "2"
                    EndIf

                    aLinha[2]   := FwNoAccent(aLinha[2])

                    If Len(aLinha[1])       == 1
                        cCCSup  := ""
                    ElseIf Len(aLinha[1])   == 2
                        cCCSup  := SubStr(aLinha[1], 1, 1)
                    ElseIf Len(aLinha[1])   == 3
                        cCCSup  := SubStr(aLinha[1], 1, 2)                         
                    ElseIf Len(aLinha[1])   == 6
                        cCCSup  := SubStr(aLinha[1], 1, 3)                        
                    EndIf 

                    aLinha[5]   := CTOD(aLinha[5])

                    //Extrai dados do array para as variaveis   
                    cCusto      := aLinha[1]
                    cDesc01     := aLinha[2]
                    cClasse     := aLinha[3] 
                    cBloq       := aLinha[4] 
                    cDtExis     := aLinha[5]           
                    
                    //Array dos campos da CTT
                    aadd(aColCTT, cCusto )
                    aadd(aColCTT, cDesc01 ) 
                    aadd(aColCTT, cClasse)   
                    aadd(aColCTT, cBloq) 
                    aadd(aColCTT, cDtExis) 
                    aadd(aColCTT, cCCSup)

                    GravCTT(aColCTT)    
   
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
 | Func:  GravCTT                                                      |
 | Desc:  Função que grava Dados na CTT                                |
 *---------------------------------------------------------------------*/
Static Function GravCTT(_aColCTT)
    Local aArea       := GetArea()
    DbSelectArea("CTT")
    RecLock("CTT", .T.)	

    //Dados do Arquivo CSV
    CTT->CTT_CUSTO      := _aColCTT[1] 
	CTT->CTT_DESC01     := _aColCTT[2]
	CTT->CTT_CLASSE     := _aColCTT[3]  
    CTT->CTT_BLOQ       := _aColCTT[4] 
	CTT->CTT_DTEXIS     := _aColCTT[5]
	CTT->CTT_CCSUP      := _aColCTT[6]  
    
    //Dados Padrões
    CTT->CTT_ITOBRG     := "2"
    CTT->CTT_CLOBRG     := "2"    
    CTT->CTT_ACITEM     := "1"
    CTT->CTT_ACCLVL     := "1" 
    CTT->CTT_INTRES     := "2"          
    CTT->CTT_RESERV     := "1"

    CTT->(MsUnLock()) // Confirma e finaliza a operação
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
