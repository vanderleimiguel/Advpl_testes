//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToCVD
Função para gravar dados de CSV para CVD
@author Vanderlei
@since 27/06/2023
@version 1.0
@type function
/*/
User Function CsvToCVD()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImporta() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 Static Function fImporta()
    Local aArea      := GetArea()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local aCols      := {}
    Local oArquivo
    Local aLinhas

    
    Local cCONTA    := ""
    Local cDESC01   := ""
    Local cCLASSE   := ""
    Local cRES      := ""
    Local cCTASUP   := ""

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
 
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                //Define linhas a processar
                If nLinhaAtu >= 8 .AND. nLinhaAtu <= 759

                    aCols   := {}

                    //Tratamento de dados das colunas
                    If Len(aLinha[8]) <= 6
                        cCLASSE   := "1" //Sintetico
                    ElseIf Len(aLinha[8]) > 6
                        cCLASSE   := "2" //Analitico
                    EndIf

                    If Len(aLinha[8]) == 1
                        cCTASUP := ""
                    ElseIf  Len(aLinha[8]) == 2
                        cCTASUP := SUBSTR( aLinha[8], 1, 1)
                    ElseIf  Len(aLinha[8]) == 3
                        cCTASUP := SUBSTR( aLinha[8], 1, 2)     
                    ElseIf  Len(aLinha[8]) == 4
                        cCTASUP := SUBSTR( aLinha[8], 1, 3)  
                    ElseIf  Len(aLinha[8]) == 5
                        cCTASUP := SUBSTR( aLinha[8], 1, 4)  
                    ElseIf  Len(aLinha[8]) == 6
                        cCTASUP := SUBSTR( aLinha[8], 1, 4) 
                    ElseIf  Len(aLinha[8]) > 6
                        cCTASUP := SUBSTR( aLinha[8], 1, 6)                                                                                                                            
                    EndIf   
                            
                    cCONTA    := aLinha[8]
                    cDESC01   := FwNoAccent(aLinha[12])
                    cRES      := aLinha[1]

                    aadd(aCols, cCONTA  )
                    aadd(aCols, cDESC01 )
                    aadd(aCols, cCLASSE )
                    aadd(aCols, cRES    )
                    aadd(aCols, cCTASUP )                    

                    GravCVD(aCols)

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
 | Func:  GravCVD                                                      |
 | Desc:  Função que grava Conta na CVD                                |
 *---------------------------------------------------------------------*/
 
Static Function GravCVD(_aCols)

    DbSelectArea("CVD")
    RecLock("CVD", .T.)	

    //Dados CSV
    CVD->CVD_CONTA     := _aCols[1] 
	CVD->CVD_DESC01    := _aCols[2] 
	CVD->CVD_CLASSE    := _aCols[3] 
	CVD->CVD_RES       := _aCols[4]  
    CVD->CVD_CTASUP    := _aCols[5] 

    //Dados Padrões
	CVD->CVD_NORMAL     := "1" //1=Devedora;2=Credora
	CVD->CVD_BLOQ       := "2"  
	CVD->CVD_ACITEM     := "1" 
    CVD->CVD_ACCUST     := "1" 
    CVD->CVD_ACCLVL     := "1"    
    CVD->CVD_DC         := "5"
    CVD->CVD_NCUSTO     := 0
    CVD->CVD_CVD02      := "1"
    CVD->CVD_CVD03      := "1"        
    CVD->CVD_CVD04      := "1"
    CVD->CVD_CVD05      := "1"  
    CVD->CVD_CVC02      := "1"
    CVD->CVD_CVC03      := "1"        
    CVD->CVD_CVC04      := "1"
    CVD->CVD_CVC05      := "1" 
    CVD->CVD_DTEXIS     := CTOD("01/01/1985") 
    CVD->CVD_AGLSLD     := "2"
    CVD->CVD_CCOBRG     := "2"
    CVD->CVD_ITOBRG     := "2"               
    CVD->CVD_CLOBRG     := "2"
    CVD->CVD_LALHIR     := "2"
    CVD->CVD_LALUR      := "0"
    CVD->CVD_ACATIV     := "2"
    CVD->CVD_ATOBRG     := "2"               
    CVD->CVD_ACET05     := "2"
    CVD->CVD_05OBRG     := "2"             
    CVD->CVD_INTP       := "2"
    CVD->CVD_PVARC      := "2" 

    MsUnLock() // Confirma e finaliza a operação

Return


