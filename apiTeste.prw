#INCLUDE "TOTVS.CH"
#include "restful.ch"

user function APITeste




return

	WSRESTFUL SpaAPI DESCRIPTION "Teste API"

		WSDATA count AS INTEGER
		WSDATA startIndex AS INTEGER

		WSMETHOD GET; //metodo get
		DESCRIPTION "Exemplo de retorno de entidade(s)";  //descrição
		WSSYNTAX "/SpaAPI || /SpaAPI?code={valueCode}&state={valueState}"; //sintax exemplo do que tem que receber no parametro
		PATH "/SpaAPI"; //rota do get
		PRODUCES APPLICATION_JSON

		WSMETHOD POST; //metodo post
		DESCRIPTION "Exemplo de inclusao de entidade";
			WSSYNTAX "/SpaAPI";
			PATH "/SpaAPI";
			PRODUCES APPLICATION_JSON


	END WSRESTFUL

WSMETHOD GET WSRECEIVE startIndex, count WSSERVICE SpaAPI

	Local lGet := .T.
	Local cCode := ""
	Local cGetUf := ""
	Local cGetLoc  := ""
	Local cGetBai := ""
	Local cGetLog := ""
    Local cCep := ""


	jQueryString := oRest:getQueryRequest()

	if ( jQueryString <> Nil )

		cCode := jQueryString[ 'code' ]
        cCep := jQueryString[ 'cep' ]
	endif

	cResult := HTTPQuote('https://viacep.com.br/ws/'+AllTrim(cCep)+'/json/', "GET", "", , , aHeader, @cHeaderRet)

	cGetUf  := DecodeUTF8(oResult:uf)
	cGetLoc  := DecodeUTF8(oResult:localidade)
	cGetBai  := DecodeUTF8(oResult:bairro)
	cGetLog  := DecodeUTF8(oResult:logradouro)

	//resposta do get
	::SetResponse(;
		'{'+CRLF +;
		'"name ": "SpaAPI"' + CRLF +;
		'"codigo ": '+cCode + CRLF +;
		'"Estado ": '+cGetUf + CRLF +;
		'"Localidade ": '+cGetLoc + CRLF +;
		'"Bairro ": '+cGetBai + CRLF +;
		'"Logradouro ": '+cGetLog + CRLF +;
		' }')



return lGet


WSMETHOD POST WSSERVICE SpaAPI

	Local lPost := .T.

return lPost
