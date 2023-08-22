//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToCt1
Função para gravar dados de CSV para CT1
@author Vanderlei
@since 27/06/2023
@version 1.0
@type function
/*/

User Function CsvToCt1()
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

                    GravCT1(aCols)

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
 | Func:  GravCT1                                                      |
 | Desc:  Função que grava Conta na CT1                                |
 *---------------------------------------------------------------------*/
 
Static Function GravCT1(_aCols)

    DbSelectArea("CT1")
    RecLock("CT1", .T.)	

    //Dados CSV
    CT1->CT1_CONTA     := _aCols[1] 
	CT1->CT1_DESC01    := _aCols[2] 
	CT1->CT1_CLASSE    := _aCols[3] 
	CT1->CT1_RES       := _aCols[4]  
    CT1->CT1_CTASUP    := _aCols[5] 

    //Dados Padrões
	CT1->CT1_NORMAL     := "1" //1=Devedora;2=Credora
	CT1->CT1_BLOQ       := "2"  
	CT1->CT1_ACITEM     := "1" 
    CT1->CT1_ACCUST     := "1" 
    CT1->CT1_ACCLVL     := "1"    
    CT1->CT1_DC         := "5"
    CT1->CT1_NCUSTO     := 0
    CT1->CT1_CVD02      := "1"
    CT1->CT1_CVD03      := "1"        
    CT1->CT1_CVD04      := "1"
    CT1->CT1_CVD05      := "1"  
    CT1->CT1_CVC02      := "1"
    CT1->CT1_CVC03      := "1"        
    CT1->CT1_CVC04      := "1"
    CT1->CT1_CVC05      := "1" 
    CT1->CT1_DTEXIS     := CTOD("01/01/1985") 
    CT1->CT1_AGLSLD     := "2"
    CT1->CT1_CCOBRG     := "2"
    CT1->CT1_ITOBRG     := "2"               
    CT1->CT1_CLOBRG     := "2"
    CT1->CT1_LALHIR     := "2"
    CT1->CT1_LALUR      := "0"
    CT1->CT1_ACATIV     := "2"
    CT1->CT1_ATOBRG     := "2"               
    CT1->CT1_ACET05     := "2"
    CT1->CT1_05OBRG     := "2"             
    CT1->CT1_INTP       := "2"
    CT1->CT1_PVARC      := "2" 

    MsUnLock() // Confirma e finaliza a operação

Return


