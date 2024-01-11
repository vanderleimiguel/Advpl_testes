#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.CH"

User Function Model2()

	Private cAlias 		:= "ZZ1"
	Private nOpcx 		:= 0
	Private cNomCli 	:= ""
	Private cCodCli 	:= ""
	Private cCadastro	:= "Cursos Concluidos do Cliente"
	Private aRotina 	:= {}

	aRotina := {{ "Visualizar"		,"U_Visual", 0 , 2},;
		{ "Incluir"			,"U_Inclui", 0 , 3},;
		{ "Alterar"			,"U_Altera", 0 , 4},;
		{ "Excluir"			,"U_Deleta", 0 , 5},;
		{ "Integrar na Loja","U_Integrar", 0 , 6}}

	dbSelectArea(cAlias)

	mBrowse(6,1,22,75,cAlias, , , , , ,)

Return Nil

User function Inclui()

	nOpcx := 3
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)

	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == cAlias)
		If Alltrim(x3_campo)=="ZZ1_COD" .or. Alltrim(x3_campo)=="ZZ1_LOJA";
				.or. Alltrim(x3_campo)=="ZZ1_NOME" .or. Alltrim(x3_campo)=="ZZ1_PUPILA"

			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM(x3_titulo),x3_campo,;
				x3_picture,x3_tamanho,x3_decimal,;
				,x3_usado,;
				x3_tipo, x3_arquivo, x3_context } )
		endif
		dbSkip()
	End

	aCols:=Array(1,nUsado+1)
	dbSelectArea("Sx3")
	dbSeek(cAlias)
	nUsado:=0
	While !Eof() .And. (x3_arquivo == cAlias)
		If Alltrim(x3_campo)=="ZZ1_COD" .or. Alltrim(x3_campo)=="ZZ1_LOJA";
				.or. Alltrim(x3_campo)=="ZZ1_NOME" .or. Alltrim(x3_campo)=="ZZ1_PUPILA"
			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			IF nOpcx == 3
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				Elseif x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				Elseif x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				Elseif x3_tipo == "M"
					aCOLS[1][nUsado] := ""
				Else
					aCOLS[1][nUsado] := .F.
				Endif
			Endif

		Endif
		dbSkip()
	End
	aCOLS[1][nUsado+1] := .F.

	cCodCli  :=Space(6)
	cLojaCli :=Space(2)
	cNomCli  :=Space(40)
	cPupila  :=Space(1)
	
	aC:={}
	AADD(aC,{"cCodCli" 	,{15,10} ,"Cod. do Cliente","@!",,"SA1_DC",})
	AADD(aC,{"cLojaCli" ,{15,100},"Loja","@!",,,})
	AADD(aC,{"cNomCli"  ,{15,170},"Nome do Cliente","@!",,,})
	AADD(aC,{"cPupila"  ,{15,460},"Classe Pupila","@!",,,})

	aR:={}
	aCGD:={44,5,118,315}
	nLinGetD:=0
	cTitulo:="Cursos Concluidos do Cliente"
	cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"

	lRet :=	Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,,,.T.)

	If lRet
		nGrav := 3
		Mod2Grv( nGrav )
		MsUnLock()
	endif
Return


User Function Altera()

	Local _ni
	Local nUsado:=0
	nOpcx := 3
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)

	aHeader:={}
	While !Eof().And.(x3_arquivo== cAlias)
		If Alltrim(x3_campo)=="ZZ1_COD" .or. Alltrim(x3_campo)=="ZZ1_LOJA";
				.or. Alltrim(x3_campo)=="ZZ1_NOME" .or. Alltrim(x3_campo)=="ZZ1_PUPILA"

			dbSkip()
			Loop
		Endif
		If X3USO(x3_usado).And.cNivel>=x3_nivel
			nUsado:=nUsado+1

			Aadd(aHeader,{	TRIM(x3_titulo),;
				x3_campo,;
				x3_picture,;
				x3_tamanho,;
				x3_decimal,;
				x3_valid,;
				x3_usado,;
				x3_tipo,;
				x3_arquivo,;
				x3_context } )
		Endif
		dbSkip()
	Enddo

	// Cria grid
	aCols:={}
	dbSelectArea(cAlias)
	dbSetOrder(1)

	AADD(aCols,Array(nUsado+1))

	For _ni:=1 to nUsado
		aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	aCols[Len(aCols),nUsado+1]:=.F.

	cCodCli  := ZZ1->ZZ1_COD
	cLojaCli := ZZ1->ZZ1_LOJA
	cNomCli  := ZZ1->ZZ1_NOME
	cPupila  := ZZ1->ZZ1_PUPILA

	aC:={}
	AADD(aC,{"cCodCli" 	,{15,10} ,"Cod. do Cliente","@!",,"SA1_DC",})
	AADD(aC,{"cLojaCli" ,{15,100},"Loja","@!",,,})
	AADD(aC,{"cNomCli"  ,{15,170},"Nome do Cliente","@!",,,})
	AADD(aC,{"cPupila"  ,{15,460},"Classe Pupila","@!",,,})

	aR:={}
	nLinGetD:=0
	aCGD:={44,5,118,315}
	cTitulo:="Cursos Concluidos do Cliente"
	cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"

	lRet :=	Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,,,.T.)

	If lRet
		nGrav := 4
		Mod2Grv( nGrav )
		MsUnLock()
	endif
Return

User Function Visual()

	Local _ni
	Local nUsado:=0
	nOpcx := 2
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)

	aHeader:={}
	While !Eof().And.(x3_arquivo== cAlias)
		If Alltrim(x3_campo)=="ZZ1_COD" .or. Alltrim(x3_campo)=="ZZ1_LOJA";
				.or. Alltrim(x3_campo)=="ZZ1_NOME" .or. Alltrim(x3_campo)=="ZZ1_PUPILA"

			dbSkip()
			Loop
		Endif
		If X3USO(x3_usado).And.cNivel>=x3_nivel
			nUsado:=nUsado+1

			Aadd(aHeader,{	TRIM(x3_titulo),;
				x3_campo,;
				x3_picture,;
				x3_tamanho,;
				x3_decimal,;
				x3_valid,;
				x3_usado,;
				x3_tipo,;
				x3_arquivo,;
				x3_context } )
		Endif
		dbSkip()
	Enddo

	// Cria grid
	aCols:={}
	dbSelectArea(cAlias)
	dbSetOrder(1)

	AADD(aCols,Array(nUsado+1))

	For _ni:=1 to nUsado
		aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	
	cCodCli  := ZZ1->ZZ1_COD
	cLojaCli := ZZ1->ZZ1_LOJA
	cNomCli  := ZZ1->ZZ1_NOME
	cPupila  := ZZ1->ZZ1_PUPILA

	aC:={}
	AADD(aC,{"cCodCli" 	,{15,10} ,"Cod. do Cliente","@!",,"SA1_DC",})
	AADD(aC,{"cLojaCli" ,{15,100},"Loja","@!",,,})
	AADD(aC,{"cNomCli"  ,{15,170},"Nome do Cliente","@!",,,})
	AADD(aC,{"cPupila"  ,{15,460},"Classe Pupila","@!",,,})


	aR:={}
	aCGD:={44,5,118,315}
	nLinGetD:=0
	cTitulo:="Cursos Concluidos do Cliente"
	cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"

	lRet :=	Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,,,.T.)

Return

User Function Deleta()

	If .not. MsgYesNo( 'Deseja deletar curso selecionado?', 'Deletar curso do cliente' )
		Return
	Endif

	nGrav := 5
	Mod2Grv( nGrav )
	ConfirmSX8()

Return


Static function Mod2Grv(_nGrav)

	Local nX := 0
	Local nI := 0

// Grava os itens
	If _nGrav == 3

		dbSelectArea(cAlias)
		dbSetOrder(1)

		For nX := 1 To Len( aCOLS )
			If !aCOLS[ nX, Len( aCOLS[nX] )]
				RecLock( cAlias, .T. )
				For nI := 1 To Len( aHeader )
					FieldPut( FieldPos( Trim( aHeader[nI, 2] ) ),aCOLS[nX,nI] )
				Next nI
				ZZ1->ZZ1_COD := cCodCli
				ZZ1->ZZ1_NOME := cNomCli
				ZZ1->ZZ1_LOJA := cLojaCli
				ZZ1->ZZ1_PUPILA := cPupila
				MsUnLock()
			Endif
		Next nX
	Endif

// Se for alteração
	If _nGrav == 4

		dbSelectArea(cAlias)
		dbSetOrder(1)
		RecLock(cAlias, .F.)
		dbDelete()
		MsUnLock()

		For nX := 1 To Len( aCOLS )
			If !aCOLS[ nX, Len( aCOLS[nX] )]
				RecLock( cAlias, .T. )
				For nI := 1 To Len( aHeader )
					FieldPut( FieldPos( Trim( aHeader[nI, 2] ) ),aCOLS[nX,nI] )
				Next nI
				ZZ1->ZZ1_COD := cCodCli
				ZZ1->ZZ1_NOME := cNomCli
				ZZ1->ZZ1_LOJA := cLojaCli
				ZZ1->ZZ1_PUPILA := cPupila
				MsUnLock()
			Endif
		Next nX

	ENDIF


// Deleta os Itens
	If _nGrav == 5

		dbSelectArea(cAlias)
		dbSetOrder(1)
		RecLock(cAlias, .F.)
		dbDelete()
		MsUnLock()
		dbSkip()

	Endif

return

User Function Pupila()

	Local cRet

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)

	cRet := ZZ1->ZZ1_PUPILA

	cAlias->(dbCloseArea())

return cRet

User Function Integrar()



return
