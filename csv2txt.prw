//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} Csv2Txt
Função para converter dados de CSV para TXT
@author Vanderlei
@since 07/06/2023
@version 1.0
@type function
/*/

User Function Csv2Txt()
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
    Local aArrayTxt  := {}
    Local oArquivo
    Local aLinhas
    Local lQuebr    := .T.
    Local cArqGera := "C:\temp\testeTxt.txt"
    Local cColA   := ""
    Local cColB   := ""
    Local cColC  := ""
    Local cColD    := ""
    Local cColE   := ""
    Local cColF   :=""
    Local cColG  := ""
    Local cColH    := ""

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
                    aLinha[5] := StrTran(aLinha[4], '"', '')
                    aLinha[4] := SUBSTR(StrTran(aLinha[3], '"', ''), 20)
                    aLinha[3] := SUBSTR(StrTran(aLinha[3], '"', ''), 1, 14)
                    aLinha[3] := StrTran(aLinha[3], '.', '')
                    If aLinha[3] == "1120010001" .and. alinha[4] <> "000000"
                cColA := PADR(aLinha[1],3)
                cColB := PADR(aLinha[2],1)
                cColC := PADR(aLinha[3],10)
                cColD := PADR(aLinha[4],10)
                               // cColE := PADR(aLinha[5],10)
                // //Retira , e . dos valores
                // aLinha[6] := StrTran(aLinha[6], ",", "")
                // aLinha[6] := StrTran(aLinha[6], ".", "")
                // cColF := PADR(aLinha[6],8)
                // cColG := PADR(aLinha[7],40)
                // cColH := PADR(aLinha[8],3)
                 
                AAdd( aArrayTxt, {cColA + " " + cColB + " " + cColC  + " " + cColD + " " +  cColE;
                 + " " + cColF + " " +  cColG + " " +  cColH})
                 EndIf
                 EndIf
            EndDo

            //Funcao array para TXT
            If ! Empty(aArrayTxt)
                zArrToTxt(aArrayTxt, lQuebr, cArqGera)
            Else
			    MsgStop("Array vazio nao carregou dados do CSV!", "Atenção")
		    EndIf
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

Static Function zArrToTxt(aAuxiliar, lQuebr, cArqGera)
    Local cTextoAux     := ""
    Local nLimite       := 63000 //Forçando o tamanho máximo a 63.000 bytes
    Local nLinha        := 0
    Local nNivel        := 0
    Default aAuxiliar   := {}
    Default lQuebr      := .T.
    Default cArqGera    := ""
     
    //Se tiver linhas para serem processadas
    If Len(aAuxiliar) > 0
        //Percorrendo o Array
        For nLinha := 1 To Len(aAuxiliar)
            fImprArray(aAuxiliar[nLinha][1], @cTextoAux, nNivel, lQuebr, nLimite, nLinha)
        Next
         
        //Se não tiver em branco, gera o arquivo
        If !Empty(cArqGera)
            MemoWrite(cArqGera, cTextoAux)
            MsgAlert("Arquivo Gerado com Sucesso!", "Conversão")

        EndIf
    EndIf
Return cTextoAux
 
/*---------------------------------------------------------------------*
 | Func:  fImprArray                                                   |
 | Desc:  Função que gera a linha do arquivo (recursivamente)          |
 *---------------------------------------------------------------------*/
 
Static Function fImprArray(xDadAtu, cTextoAux, nNivel, lQuebr, nLimite, nPosicao)
    Local cEspac := Space(nNivel)
        
    //Finaliza o laço
    If Len(cTextoAux) >= nLimite
        Return
    EndIf
     
        cTextoAux += cEspac+Alltrim(xDadAtu) + Iif(lQuebr, STR_PULA, '')

Return
