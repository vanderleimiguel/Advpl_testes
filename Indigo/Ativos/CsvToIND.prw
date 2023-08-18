//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToSN
Função para gravar dados de CSV para SN1 e SN3
@author Wagner Neves
@since 18/08/2023
@version 1.0
@type function
/*/
User Function CsvToIND()
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
    Local aColSN1     := {}
    Local aColSN2     := {}
    Local aColSN3     := {}    
    Local oArquivo
    Local aLinhas
    Local cBASE       := ""
    Local cITEM       := ""
    Local cN3TIPO     := ""
    Local cDESCRI     := ""
    Local cN1FORNE    := ""
    Local cN1FISCA    := ""
    Local cAQUIS      := ""
    Local cN1GRUPO    := ""
    Local cN3CCONT    := ""
    Local cN3CDEPR    := ""
    Local cN3CCDEP    := ""
    Local nN1QUANT    := ""
    Local nN3TXDEP    := ""
    Local nN3VORIG    := ""
    Local nN3VRDAC    := ""
    Local nNome       := 0
    Local nSequenc    := 0
    Local cNome       := ""
    Local cParcNom    := ""
    Private cSituac   := ""

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
                aColSN1     := {}
                aColSN2     := {}
                aColSN3     := {}  
                nSequenc    := 0
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                //Define linhas a processar
                If nLinhaAtu >= 5 .AND. nLinhaAtu <= 271

                    //Insere zeros a esquerda
                    aLinha[13] := PADL(aLinha[13],6,"0")
                    aLinha[14] := PADL(aLinha[14],4,"0")
                    aLinha[15] := PADL(aLinha[15],2,"0")

                    //Ajuste Grupo
                    If aLinha[1] == "VEICULOS"
                        aLinha[1] := "0003"
                    ElseIf aLinha[1] == "MOVEIS E UTENS."
                        aLinha[1] := "0004"
                    ElseIf aLinha[1] == "EQUIP. DE INFOR."
                        aLinha[1] := "0006"
                    ElseIf aLinha[1] == "MAQUINAS E EQUIP."
                        aLinha[1] := "0001"
                    ElseIf aLinha[1] == "DESPESA"
                        aLinha[1] := "0007"
                    ElseIf aLinha[1] == "BENFEITORIA"
                        aLinha[1] := "0008"                      
                    EndIf

                    //Ajuste de Valores numericos
                    If aLinha[6] == ""
                        aLinha[6] := 0
                    Else
                        aLinha[6] := StrTran(aLinha[6], '.', '')
                        aLinha[6] := VAL(AllTrim(StrTran(aLinha[6], ',', '.')))
                    EndIf
                    If aLinha[9] == ""
                        aLinha[9] := 0
                    Else
                        aLinha[9] := StrTran(aLinha[9], '.', '')
                        aLinha[9] := VAL(AllTrim(StrTran(aLinha[9], ',', '.')))
                    EndIf
                    If aLinha[10] == ""
                        aLinha[10] := 0
                    Else
                        aLinha[10] := StrTran(aLinha[10], '.', '')
                        aLinha[10] := VAL(AllTrim(StrTran(aLinha[10], ',', '.')))
                    EndIf
                    If aLinha[12] == ""
                        aLinha[12] := 0
                    Else
                        aLinha[12] := StrTran(aLinha[12], '.', '')
                        aLinha[12] := VAL(AllTrim(StrTran(aLinha[12], ',', '.')))
                    EndIf
                    If aLinha[7] == ""
                        aLinha[7] := 0
                    Else
                        aLinha[7] := StrTran(aLinha[7], '%', '')
                        aLinha[7] := StrTran(aLinha[7], '.', '')
                        aLinha[7] := VAL(AllTrim(StrTran(aLinha[7], ',', '.')))
                    EndIf 

                    //Extrai dados do array para as variaveis                   
                    cBASE       := aLinha[13] //C6
                    cITEM       := aLinha[14] //C4
                    cN3TIPO     := aLinha[15] //C2
                    cDESCRI     := SUBSTR( aLinha[11], 1, 40)
                    cN1FISCA    := aLinha[5]
                    cAQUIS      := CTOD(aLinha[2])
                    cN1GRUPO    := aLinha[1] //C4
                    // cN3CCONT    := aLinha[12]
                    // cN3CDEPR    := aLinha[14]
                    // cN3CCDEP    := aLinha[16]
                    nN1QUANT    := aLinha[12] //N
                    nN3TXDEP    := aLinha[7] //N
                    nN3VORIG    := aLinha[6] //N
                    nN3VRDAC    := aLinha[9] //N

                    //Verifica se Numero do bem ja foi inserido anteriormente
                   
                        //Array dos campos da SN1
                        aadd(aColSN1, cBASE )
                        aadd(aColSN1, cITEM ) 
                        aadd(aColSN1, cDESCRI ) 
                        aadd(aColSN1, cN1FORNE )
                        aadd(aColSN1, cN1FISCA )
                        aadd(aColSN1, cAQUIS ) 
                        aadd(aColSN1, cN1GRUPO )
                        aadd(aColSN1, nN1QUANT )  
     

                        GravSN1(aColSN1)    

                    //Array dos campos da SN3
                    aadd(aColSN3, cBASE )
                    aadd(aColSN3, cITEM )
                    aadd(aColSN3, cN3TIPO )                     
                    aadd(aColSN3, cDESCRI ) 
                    aadd(aColSN3, cN3CCONT )
                    aadd(aColSN3, cN3CDEPR )
                    aadd(aColSN3, cN3CCDEP ) 
                    aadd(aColSN3, nN3TXDEP ) 
                    aadd(aColSN3, nN3VORIG )
                    aadd(aColSN3, nN3VRDAC ) 
                    aadd(aColSN3, cAQUIS )             

                    GravSN3(aColSN3) 

                    //Verifica tamanho do nome
                    cNome  := aLinha[11]     
                    nNome  := Len(cNome)
                    If nNome > 40
                        While nNome <> 0
                            aColSN2     := {}
                            cParcNom    := SUBSTR( cNome, 1, 40)
                            cNome       := SUBSTR( cNome, 41)

                            nSequenc++
                            cSequenc := cValToChar(nSequenc)

                            //Array dos campos da SN2
                            aadd(aColSN2, cBASE )
                            aadd(aColSN2, cITEM )
                            aadd(aColSN2, PADL(cSequenc,2,"0") )                     
                            aadd(aColSN2, cParcNom ) 
                            aadd(aColSN2, PADL(cSequenc,3,"0") )         

                            GravSN2(aColSN2) 

                            nNome  := Len(cNome)
                        EndDo

                    EndIf                    
                       
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
 | Func:  GravSN1                                                      |
 | Desc:  Função que grava Dados na SN1                                |
 *---------------------------------------------------------------------*/
 
Static Function GravSN1(_aColSN1)

    DbSelectArea("SN1")
    RecLock("SN1", .T.)	

    SN1->N1_FILIAL     := "01"
    SN1->N1_PATRIM     := "N"
    SN1->N1_CBASE      := _aColSN1[1] 
	SN1->N1_ITEM       := _aColSN1[2]
	SN1->N1_DESCRIC    := _aColSN1[3]  
    SN1->N1_NFISCAL    := _aColSN1[5] 
	SN1->N1_AQUISIC    := _aColSN1[6]
	SN1->N1_GRUPO      := _aColSN1[7]  
    SN1->N1_QUANTD     := _aColSN1[8] 

    SN1->(MsUnLock()) // Confirma e finaliza a operação

Return


/*---------------------------------------------------------------------*
 | Func:  GravSN3                                                      |
 | Desc:  Função que grava Dados na SN3                                |
 *---------------------------------------------------------------------*/
 
Static Function GravSN3(_aColSN3)

    DbSelectArea("SN3")
    RecLock("SN3", .T.)	

    SN3->N3_FILIAL      := "01"
    SN3->N3_TPSALDO     := "1"
    SN3->N3_TPDEPR      := "1"        
    SN3->N3_CBASE       := _aColSN3[1] 
	SN3->N3_ITEM        := _aColSN3[2]
	SN3->N3_TIPO        := _aColSN3[3]  
    SN3->N3_HISTOR      := _aColSN3[4]    
    // SN3->N3_CCONTAB     := _aColSN3[5] 
	// SN3->N3_CDEPREC     := _aColSN3[6]
	// SN3->N3_CCDEPR      := _aColSN3[7]  
    SN3->N3_TXDEPR1     := _aColSN3[8]   
	SN3->N3_VORIG1      := _aColSN3[9]  
    SN3->N3_VRDACM1     := _aColSN3[10] 
    SN3->N3_DINDEPR     := _aColSN3[11] 
    SN3->N3_AQUISIC     := _aColSN3[11]

    SN3->(MsUnLock()) // Confirma e finaliza a operação

Return

Static Function GravSN2(_aColSN2)

    DbSelectArea("SN2")
    RecLock("SN2", .T.)	

    SN2->N2_FILIAL     := "01"
    SN2->N2_CBASE      := _aColSN2[1] 
	SN2->N2_ITEM       := _aColSN2[2]
	SN2->N2_SEQUENC    := _aColSN2[3]  
    SN2->N2_HISTOR     := _aColSN2[4] 
	SN2->N2_TIPO       := "01"
	SN2->N2_SEQ        := "001"  

    SN2->(MsUnLock()) // Confirma e finaliza a operação

Return
