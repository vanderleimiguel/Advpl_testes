#INCLUDE	"Protheus.ch"
#INCLUDE	"RWMake.ch"

User Function MNTC5102()
	Local aBotoes := {}

	If MsgYesNo("Chamada do Ponto de Entrada MNTC5102."+CRLF+"Deseja adicionar botões ao menu?","P.E. MNTC5102")
		aAdd(aBotoes, {"Meu Botão","U_MinhaLeg", 0, 3})
        aAdd(aBotoes, {"Meu Botão2","U_MinhaLeg", 0, 1})
		SetBrwChgAll(.F.)
	EndIf

Return aBotoes

User Function MinhaLeg()
	Local aLegenda := {}

	aAdd(aLegenda, {"BR_AMARELO", "Liberada"} ) //Liberada
	BrwLegenda("Ponto de Entrada MNTC5102","Legenda P.E. MNTC5102",aLegenda)
Return .T.
