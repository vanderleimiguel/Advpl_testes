#INCLUDE "TOTVS.CH"
#include "restful.ch"

user function SpaCli

return

	WSRESTFUL SpaTeste DESCRIPTION "SPA Teste"

		WSDATA count AS INTEGER
		WSDATA startIndex AS INTEGER

		WSMETHOD GET; //metodo get
		DESCRIPTION "Exemplo de retorno de entidade(s)";  //descrição
		WSSYNTAX "/cliteste || /cliente?cpf={valueCode}"; //sintax exemplo do que tem que receber no parametro
		PATH "/cliteste"; //rota do get
		PRODUCES APPLICATION_JSON

	END WSRESTFUL

WSMETHOD GET WSRECEIVE startIndex, count WSSERVICE SpaTeste

	Local lGet 		:= .T.
	Local cCpf 		:= ""
	Local cIdCli 	:= ""
	Local cNomeCli 	:= ""
	Local cTel 		:= ""
	Local cEmail 	:= ""
	Local cRestri 	:= ""
	Local cPupila 	:= ""

	jQueryString := oRest:getQueryRequest()

	if ( jQueryString <> Nil )

		cCpf := jQueryString[ 'cpf' ]

	endif

	dbSelectArea("ZZ1")
	ZZ1->(DbSetOrder(1))
	ZZ1->(dbgotop())
	if ZZ1->(DbSeek(FWxFilial(cAlias) + ZZ1->ZZ1_COD))
		cIdCli 		:= ZZ1->COD
		cNomeCli 	:= ""
		cCpf 		:= ""
		cTel 		:= ""
		cEmail 		:= ""
		cRestri 	:= ""
		cPupila 	:= ""

	endIf

	//resposta do get
	::SetResponse(;
		'{'+CRLF +;
		'"idCliente ": '+cIdCli + CRLF +;
		'"nome ": '+cNomeCli + CRLF +;
		'"documento ": '+cCpf + CRLF +;
		'"telefone ": '+cTel + CRLF +;
		'"email ": '+cEmail + CRLF +;
		'"statusRestricao ": '+cRestri + CRLF +;
		'"pupila ": '+cPupila + CRLF +;
		' }')

return lGet
