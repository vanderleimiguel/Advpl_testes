//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToCt1
Função para gravar dados de CSV para CT1 e gravar contas na SA1 e SA2
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

	CntCli()
    CntFor()
    CntForEx()

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
    Local cCntCli   := "1120010001"
    Local cCntFor   := "2110010001"
    Local cCntForEx := "2110020001"
    Local cCONTA    := ""
    Local cDESC01   := ""
    Local cCLASSE   := ""
    Local cNORMAL   := ""
    Local cRES      := ""
    Local cBLOQ     := ""
    Local cCTASUP   := ""
    Local cACITEM   := ""
    Local cACCUST   := ""
    Local cACCLVL   := ""
    Local cNTSPED   := ""


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

                If Len(aLinha) == 5
                    aadd(aLinha, aLinha[5] )
                    aLinha[5] := StrTran(aLinha[4], '"', '')
                    aLinha[4] := SUBSTR(StrTran(aLinha[3], '"', ''), 20)
                    aLinha[3] := SUBSTR(StrTran(aLinha[3], '"', ''), 1, 14)
                    aLinha[3] := StrTran(aLinha[3], '.', '')

                    //Adiciona contas dos clientes
                    If aLinha[3] == "1120010001" .and. alinha[4] <> "000000" .and. alinha[6] == "diferente"

                        DbSelectArea("CT1")
                        DbSetOrder(6)

                        If !dbSeek(xFilial("CT1") + aLinha[4])
                            aCols := {}
                            
                            DbSelectArea("CT1")
                            DbSetOrder(1)
                            While dbSeek(xFilial("CT1") + Alltrim(cCntCli))
                                cCntCli :=  cValToChar(Val(cCntCli) + 1)
                            EndDo
                            
                            cCONTA    := cCntCli
                            cDESC01   := aLinha[4]
                            cCLASSE   := "2"
                            cNORMAL   := "1"
                            cRES      := aLinha[1]
                            cBLOQ     := "2"
                            cCTASUP   := "112001"
                            cACITEM   := "1"
                            cACCUST   := "2"
                            cACCLVL   := "1"
                            cNTSPED   := "1"

                            aadd(aCols, cCONTA )
                            aadd(aCols, cDESC01 )
                            aadd(aCols, cCLASSE )
                            aadd(aCols, cNORMAL )
                            aadd(aCols, cRES )
                            aadd(aCols, cBLOQ )
                            aadd(aCols, cCTASUP )
                            aadd(aCols, cACITEM )
                            aadd(aCols, cACCUST )
                            aadd(aCols, cACCLVL )
                            aadd(aCols, cNTSPED )

                            GravCT1(aCols)
                        Else
                        If CT1->CT1_CTASUP == "112001"
                            cCntCli := CT1->CT1_CONTA
                        EndIf
                        EndIf
                    EndIf

                    ////Adiciona contas dos Fornecedores
                    If aLinha[3] == "2110010001" .and. alinha[4] <> "000000" .and. alinha[6] == "diferente"

                        DbSelectArea("CT1")
                        DbSetOrder(6)

                        If !dbSeek(xFilial("CT1") + aLinha[4])
                            aCols := {}
                               
                            DbSelectArea("CT1")
                            DbSetOrder(1)
                            While dbSeek(xFilial("CT1") + Alltrim(cCntFor))
                                cCntFor   :=  cValToChar(Val(cCntFor) + 1)
                            EndDo

                            cCONTA    := cCntFor
                            cDESC01   := aLinha[4]
                            cCLASSE   := "2"
                            cNORMAL   := "2"
                            cRES      := aLinha[1]
                            cBLOQ     := "2"
                            cCTASUP   := "211001"
                            cACITEM   := "1"
                            cACCUST   := "2"
                            cACCLVL   := "1"
                            cNTSPED   := "02"

                            aadd(aCols, cCONTA )
                            aadd(aCols, cDESC01 )
                            aadd(aCols, cCLASSE )
                            aadd(aCols, cNORMAL )
                            aadd(aCols, cRES )
                            aadd(aCols, cBLOQ )
                            aadd(aCols, cCTASUP )
                            aadd(aCols, cACITEM )
                            aadd(aCols, cACCUST )
                            aadd(aCols, cACCLVL )
                            aadd(aCols, cNTSPED )

                            GravCT1(aCols)
                        Else
                            If CT1->CT1_CTASUP == "211001"
                                cCntFor := CT1->CT1_CONTA
                            EndIf
                        EndIf
                    EndIf
                    //Adiciona contas dos Fornecedores Externos
                    If aLinha[3] == "2110100001" .and. alinha[4] <> "000000" .and. alinha[6] == "diferente"

                        DbSelectArea("CT1")
                        DbSetOrder(6)

                        If !dbSeek(xFilial("CT1") + aLinha[4])
                            aCols := {}

                            DbSelectArea("CT1")
                            DbSetOrder(1)
                            While dbSeek(xFilial("CT1") + Alltrim(cCntForEx))
                                cCntForEx :=  cValToChar(Val(cCntForEx) + 1)
                            EndDo  
                            
                            cCONTA    := cCntForEx
                            cDESC01   := aLinha[4]
                            cCLASSE   := "2"
                            cNORMAL   := "2"
                            cRES      := aLinha[1]
                            cBLOQ     := "2"
                            cCTASUP   := "211002"
                            cACITEM   := "1"
                            cACCUST   := "2"
                            cACCLVL   := "1"
                            cNTSPED   := "02"

                            aadd(aCols, cCONTA )
                            aadd(aCols, cDESC01 )
                            aadd(aCols, cCLASSE )
                            aadd(aCols, cNORMAL )
                            aadd(aCols, cRES )
                            aadd(aCols, cBLOQ )
                            aadd(aCols, cCTASUP )
                            aadd(aCols, cACITEM )
                            aadd(aCols, cACCUST )
                            aadd(aCols, cACCLVL )
                            aadd(aCols, cNTSPED )

                            GravCT1(aCols)
                        Else
                            If CT1->CT1_CTASUP == "211002"
                                cCntForEx := CT1->CT1_CONTA
                            EndIf
                        EndIf
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
 | Func:  GravCT1                                                      |
 | Desc:  Função que grava Conta na CT1                                |
 *---------------------------------------------------------------------*/
 
Static Function GravCT1(_aCols)

    DbSelectArea("CT1")
    RecLock("CT1", .T.)	

    CT1->CT1_CONTA     := _aCols[1] 
	CT1->CT1_DESC01    := _aCols[2] 
	CT1->CT1_CLASSE    := _aCols[3]  
	CT1->CT1_NORMAL    := _aCols[4] 
	CT1->CT1_RES       := _aCols[5]  
	CT1->CT1_BLOQ      := _aCols[6]  
	CT1->CT1_CTASUP    := _aCols[7] 
	CT1->CT1_ACITEM    := _aCols[8] 
    CT1->CT1_ACCUST    := _aCols[9] 
    CT1->CT1_ACCLVL    := _aCols[10]
    CT1->CT1_NTSPED    := _aCols[11]
    
    MsUnLock() // Confirma e finaliza a operação

Return

/*---------------------------------------------------------------------*
 | Func:  CntCli                                                       |
 | Desc:  Função que atualiza conta do cliente na SA1                  |
 *---------------------------------------------------------------------*/

Static Function CntCli()
    Local cAlias    	 := GetNextAlias()
	Local cQuery    	 := ""

	cQuery := " SELECT CT1.CT1_CONTA, CT1.CT1_DESC01"+ CRLF
	cQuery += " FROM " + RetSqlName("CT1") + ' CT1 ' + CRLF
	cQuery += " WHERE CT1.D_E_L_E_T_ = '' AND CT1_CONTA LIKE '%112001%'"+ CRLF

    cQuery := CHANGEQUERY( cQuery )
	TCQUERY cQuery NEW ALIAS cAlias

    DbselectArea("SA1")
	DbSetOrder(2)
	While !cAlias->( Eof() )
        If SA1->(DbSeek( xFilial("SA1") + cAlias->CT1_DESC01 ))
            DbSelectArea("SA1")
            RecLock("SA1", .F.)	

            SA1->A1_CONTA     := cAlias->CT1_CONTA

            MsUnLock()
        EndIf
        cAlias->( DbSkip() )
    Enddo
    
Return

/*---------------------------------------------------------------------*
 | Func:  CntFor                                                       |
 | Desc:  Função que atualiza conta do Fornecedor na SA2               |
 *---------------------------------------------------------------------*/

Static Function CntFor()
    Local cAlias2    	 := GetNextAlias()
	Local cQuery2    	 := ""

	cQuery2 := " SELECT CT1.CT1_CONTA, CT1.CT1_DESC01"+ CRLF
	cQuery2 += " FROM " + RetSqlName("CT1") + ' CT1 ' + CRLF
	cQuery2 += " WHERE CT1.D_E_L_E_T_ = '' AND CT1_CONTA LIKE '%211001%'"+ CRLF

    cQuery2 := CHANGEQUERY( cQuery2 )
	TCQUERY cQuery2 NEW ALIAS cAlias2

    DbselectArea("SA2")
	DbSetOrder(2)
	While !cAlias2->( Eof() )
        If SA2->(DbSeek( xFilial("SA2") + cAlias2->CT1_DESC01 ))
            DbSelectArea("SA2")
            RecLock("SA2", .F.)	

            SA2->A2_CONTA     := cAlias2->CT1_CONTA

            MsUnLock()
        EndIf
        cAlias2->( DbSkip() )
    Enddo
    
Return

/*---------------------------------------------------------------------*
 | Func:  CntForEx                                                     |
 | Desc:  Função que atualiza conta do Fornecedor Externo na SA2       |
 *---------------------------------------------------------------------*/

Static Function CntForEx()
    Local cAlias3    	 := GetNextAlias()
	Local cQuery3    	 := ""

	cQuery3 := " SELECT CT1.CT1_CONTA, CT1.CT1_DESC01"+ CRLF
	cQuery3 += " FROM " + RetSqlName("CT1") + ' CT1 ' + CRLF
	cQuery3 += " WHERE CT1.D_E_L_E_T_ = '' AND CT1_CONTA LIKE '%211002%'"+ CRLF

    cQuery3 := CHANGEQUERY( cQuery3 )
	TCQUERY cQuery3 NEW ALIAS cAlias3

    DbselectArea("SA2")
	DbSetOrder(2)
	While !cAlias3->( Eof() )
        If SA2->(DbSeek( xFilial("SA2") + cAlias3->CT1_DESC01 ))
            DbSelectArea("SA2")
            RecLock("SA2", .F.)	

            SA2->A2_CONTA     := cAlias3->CT1_CONTA

            MsUnLock()
        EndIf
        cAlias3->( DbSkip() )
    Enddo
    
Return
