//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToCVN
Função para gravar dados de CSV para CVN
@author Wagner Neves
@since 28/08/2023
@version 1.0
@type function
/*/
User Function CsvToCVN()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv)", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| ImpCsvCVN() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  CsvToCVN                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 Static Function ImpCsvCVN()
    Local aArea       := GetArea()
    Local nTotLinhas  := 0
    Local cLinAtu     := ""
    Local nLinhaAtu   := 0
    Local aLinha      := {}
    Local aColCVN     := {} 
    Local oArquivo
    Local aLinhas
    Local cLinha      := ""
    Local cCtaRef     := ""
    Local cDscCta     := "" 
    Local cCtaSup     := "" 
    Local nLinha      := 0  

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
                aColCVN     := {} 
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                //Define linhas a processar
                If nLinhaAtu >= 8 .AND. nLinhaAtu <= 1560

                    aLinha[12]   := FwNoAccent(aLinha[12])

                    If Len(aLinha[8])       == 1
                        cCtaSup  := ""
                    ElseIf Len(aLinha[8])   == 2
                        cCtaSup  := SubStr(aLinha[8], 1, 1)
                    ElseIf Len(aLinha[8])   == 3
                        cCtaSup  := SubStr(aLinha[8], 1, 2)                         
                    ElseIf Len(aLinha[8])   == 5
                        cCtaSup  := SubStr(aLinha[8], 1, 3)  
                    ElseIf Len(aLinha[8])   == 7
                        cCtaSup  := SubStr(aLinha[8], 1, 5) 
                    ElseIf Len(aLinha[8])   == 9
                        cCtaSup  := SubStr(aLinha[8], 1, 7)                                                                        
                    EndIf 

                    nLinha++
                    If nLinha > 999
                        cLinha      := TranLinh(nLinha) 
                    Else
                        cLinha      := PADL(cValToChar(nLinha), 3, "0")
                    EndIf

                    //Extrai dados do array para as variaveis   
                    cCtaRef     := aLinha[8]
                    cDscCta     := aLinha[12]         
                    
                    //Array dos campos da CVN
                    aadd(aColCVN, cLinha )
                    aadd(aColCVN, cCtaRef ) 
                    aadd(aColCVN, cDscCta)   
                    aadd(aColCVN, cCtaSup) 

                    GravCVN(aColCVN)    
   
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
 | Func:  GravCVN                                                      |
 | Desc:  Função que grava Dados na CVN                                |
 *---------------------------------------------------------------------*/
Static Function GravCVN(_aColCVN)
    Local aArea       := GetArea()
    DbSelectArea("CVN")
    RecLock("CVN", .T.)	

    //Dados do Arquivo CSV
    CVN->CVN_LINHA      := _aColCVN[1]
	CVN->CVN_CTAREF     := _aColCVN[2]
	CVN->CVN_DSCCTA     := _aColCVN[3]  
    CVN->CVN_CTASUP     := _aColCVN[4] 
    
    //Dados Padrões
    CVN->CVN_CODPLA     := "PRTSE"
    CVN->CVN_VERSAO     := "0001"    
    CVN->CVN_DSCPLA     := "PLANO DE CONTAS TSE"
    CVN->CVN_DTVIGI     := CTOD("01/01/1985")
    CVN->CVN_DTVIGF     := CTOD("31/12/2030")          
    CVN->CVN_ENTREF     := "99"
    CVN->CVN_TPUTIL     := "A"
    CVN->CVN_CLASSE     := "1"
    CVN->CVN_NATCTA     := "01"
    CVN->CVN_STAPLA     := "1"

    CVN->(MsUnLock()) // Confirma e finaliza a operação
    RestArea(aArea)
Return

Static Function TranLinh(_nLinha) 
    Local _cLinha   := ""
    Local _nLinha2  := 0
    Local cPesq     := ","
    Local cString   := ""
    Local nPos      := 0

    _nLinha2    := _nLinha - 1000

    cString     :=  cValToChar(_nLinha2 / 25)

    nPos        := At(cPesq, cString, 1)

    _nLinha3    := Val(SubStr(cString, 1, nPos-1))

    If _nLinha2 <= 25

        If _nLinha2     == 0
            _cLinha     := "00A"
        ElseIf _nLinha2 == 1
            _cLinha     := "00B"
        ElseIf _nLinha2 == 2
            _cLinha     := "00C"    
        ElseIf _nLinha2 == 3
            _cLinha     := "00D"
        ElseIf _nLinha2 == 4
            _cLinha     := "00E" 
        ElseIf _nLinha2 == 5
            _cLinha     := "00F"
        ElseIf _nLinha2 == 6
            _cLinha     := "00G" 
        ElseIf _nLinha2 == 7
            _cLinha     := "00H"
        ElseIf _nLinha2 == 8
            _cLinha     := "00I" 
        ElseIf _nLinha2 == 9
            _cLinha     := "00J"
        ElseIf _nLinha2 == 10
            _cLinha     := "00K" 
        ElseIf _nLinha2 == 11
            _cLinha     := "00L"
        ElseIf _nLinha2 == 12
            _cLinha     := "00M" 
        ElseIf _nLinha2 == 13
            _cLinha     := "00N"
        ElseIf _nLinha2 == 14
            _cLinha     := "00O" 
        ElseIf _nLinha2 == 15
            _cLinha     := "00P" 
        ElseIf _nLinha2 == 16
            _cLinha     := "00Q"
        ElseIf _nLinha2 == 17
            _cLinha     := "00R" 
        ElseIf _nLinha2 == 18
            _cLinha     := "00S"
        ElseIf _nLinha2 == 19
            _cLinha     := "00T" 
        ElseIf _nLinha2 == 20
            _cLinha     := "00U"
        ElseIf _nLinha2 == 21
            _cLinha     := "00V"
        ElseIf _nLinha2 == 22
            _cLinha     := "00W"
        ElseIf _nLinha2 == 23
            _cLinha     := "00X"
        ElseIf _nLinha2 == 24
            _cLinha     := "00Y"
        ElseIf _nLinha2 == 25
            _cLinha     := "00Z"
        EndIf

    EndIf

Return _cLinha

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
