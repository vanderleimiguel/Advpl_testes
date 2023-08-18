//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToSN
Função para gravar dados de CSV para SNG e FNG
@author Wagner Neves
@since 18/08/2023
@version 1.0
@type function
/*/
User Function CsvToNG()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv)", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| ImpCsvSN() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  ImpCsvSN                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function ImpCsvSN()
    Local aArea       := GetArea()
    Local nTotLinhas  := 0
    Local cLinAtu     := ""
    Local nLinhaAtu   := 0
    Local aLinha      := {}
    Local aColSNG     := {}
    Local aColFNG     := {}    
    Local oArquivo
    Local aLinhas
    Local cCodigo     := ""
    Local cDescri     := ""
    Local nTxDepr     := 0
    Local cTipo       := "" 
    Local cHistor     := "" 
    Local cTpSaldo    := ""
    Local cTpDepre    := ""
    Local nFNGTxDep   := 0

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
                aColSNG     := {}
                aColFNG     := {}  
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                //Define linhas a processar
                If nLinhaAtu >= 4 .AND. nLinhaAtu <= 11

                    //Insere zeros a esquerda
                    aLinha[1] := PADL(aLinha[1],4,"0")
                    aLinha[4] := PADL(aLinha[4],2,"0")

                    //Ajuste de Valores numericos
                    If aLinha[3] == ""
                        aLinha[3] := 0
                    Else
                        aLinha[3] := StrTran(aLinha[3], '.', '')
                        aLinha[3] := VAL(AllTrim(StrTran(aLinha[3], ',', '.')))
                    EndIf
                    If aLinha[8] == ""
                        aLinha[8] := 0
                    Else
                        aLinha[8] := StrTran(aLinha[8], '.', '')
                        aLinha[8] := VAL(AllTrim(StrTran(aLinha[8], ',', '.')))
                    EndIf

                    //Extrai dados do array para as variaveis                   
                    cCodigo     := aLinha[1]
                    cDescri     := aLinha[2]
                    nTxDepr     := aLinha[3]
                    cTipo       := aLinha[4] 
                    cHistor     := aLinha[5] 
                    cTpSaldo    := aLinha[6]
                    cTpDepre    := aLinha[7]
                    nFNGTxDep   := aLinha[8]
                    
                    //Array dos campos da SNG
                    aadd(aColSNG, cCodigo )
                    aadd(aColSNG, cDescri ) 
                    aadd(aColSNG, nTxDepr)   

                    GravSNG(aColSNG)    

                    //Array dos campos da FNG
                    aadd(aColFNG, cTipo )
                    aadd(aColFNG, cHistor )
                    aadd(aColFNG, cTpSaldo )                     
                    aadd(aColFNG, cTpDepre ) 
                    aadd(aColFNG, nFNGTxDep )
                    aadd(aColFNG, cCodigo )
                               
                    GravFNG(aColFNG)      
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
 | Func:  GravSNG                                                      |
 | Desc:  Função que grava Dados na SNG                                |
 *---------------------------------------------------------------------*/
 
Static Function GravSNG(_aColSNG)

    DbSelectArea("SNG")
    RecLock("SNG", .T.)	

    SNG->NG_FILIAL     := "01"
    SNG->NG_GRUPO      := _aColSNG[1] 
	SNG->NG_DESCRIC    := _aColSNG[2]
	SNG->NG_TXDEPR1    := _aColSNG[3]  

    SNG->(MsUnLock()) // Confirma e finaliza a operação

Return


/*---------------------------------------------------------------------*
 | Func:  GravFNG                                                      |
 | Desc:  Função que grava Dados na FNG                                |
 *---------------------------------------------------------------------*/
 
Static Function GravFNG(_aColFNG)

    DbSelectArea("FNG")
    RecLock("FNG", .T.)	

    FNG->FNG_FILIAL      := "01"      
    FNG->FNG_TIPO        := _aColFNG[1] 
	FNG->FNG_HISTOR      := _aColFNG[2]
	FNG->FNG_TPSALD      := _aColFNG[3]  
    FNG->FNG_TPDEPR      := _aColFNG[4]    
    FNG->FNG_TXDEP1      := _aColFNG[5]  
    FNG->FNG_GRUPO       := _aColFNG[6] 

    FNG->(MsUnLock()) // Confirma e finaliza a operação

Return
