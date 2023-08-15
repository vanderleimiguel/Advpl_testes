#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include 'parmtype.ch'

/************************************************************************************************/
/** SIGAFAT - FATURAMENTO                                                                      **/
/** Ponto de entrada para gravar dados após a gravação da nota fiscal 	 			           **/
/** Autor: Renato Sever				                                                           **/
/** SMS SOLUÇÕES - CURITIBA                                                                    **/
/** Data: 02/09/2018	                                                                       **/
/** Ambiensys	- M460FIM                                                                      **/
/** Ultima Atualiação: 02/09/2018                                                              **/
/************************************************************************************************/
/** Data       | Responsável                    | Descrição                                    **/
/************************************************************************************************/
/** 02/09/2018 | Renato Sever				    | Criação da rotina/procedimento.              **/
/************************************************************************************************/
/** 04/09/2018 | Lucilene Mendes			    | Adicionada mensagem com o total líquido.     **/
/************************************************************************************************/
User Function M460FIM()
	Local _dEmissao		:= SF2->F2_EMISSAO
	Local _cNFiscal		:= SF2->F2_DOC
	Local _cSerie		:= SF2->F2_SERIE
	Local _cCliente		:= SF2->F2_CLIENTE
	Local _cLoja		:= SF2->F2_LOJA
	Local _nValPis		:= SF2->F2_VALPIS
	Local _nValCof		:= SF2->F2_VALCOFI
	Local _nValCss		:= SF2->F2_VALCSLL
	Local _nValIrr		:= SF2->F2_VALIRRF
	Local _nValInss		:= SF2->F2_VALINSS
	Local _nTotImp		:= _nValPis+_nValCof+_nValCss+_nValIrr+_nValInss
	Local _nTotBrut		:= SF2->F2_VALBRUT
	Local _cMsg			:= ''

	If _nValPis > 0
		_cMsg += 'Valor PIS: R$      '+	Transform(_nValPis, "@E 9,999.99")  + '  '
	EndIf
	If _nValCof > 0
		_cMsg += '| Valor COFINS: R$ '+	Transform( _nValCof , "@E 9,999.99")  + '  '
	EndIf
	If _nValCss > 0
		_cMsg += '| Valor CSLL: R$   '+	Transform(_nValCss, "@E 9,999.99")  + '  '
	EndIf
	If _nValIrr > 0
		_cMsg += '| Valor IRRF: R$   '+	Transform(_nValIrr, "@E 9,999.99")  + '  '
	EndIf
	If _nValInss > 0
		_cMsg += '| Valor INSS: R$    '+ Transform(_nValInss, "@E 9,999.99")  + '  '
	EndIf

	//Valor líquido da NF
	_cMsg += '| Valor Líquido à Pagar: R$ '+ Transform(_nTotBrut-_nTotImp, "@E 999,999,999.99")  + '  '

	//gravando mensagem no campo F3_OBSERV
	If !Alltrim(_cMsg) == ''
		DbSelectArea('SF3')
		SF3->(dbSetOrder(1))//F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM, 5, 2)
		SF3->(dbGoTop())
		If SF3->(dbSeek(xFilial('SF3') + dtos(_dEmissao) + _cNFiscal + _cSerie + _cCliente + _cLoja ) )
			RecLock("SF3",.F.)
			SF3->F3_OBSERV		:=  _cMsg
			SF3->(MsUnLock())
		EndIf
	EndIf

	//gravando data de execucao do servico
	DbSelectArea('SF2')
	RecLock("SF2",.F.)
		SF2->F2_DTESERV	:= SC5->C5_DTESERV
	SF2->(MsUnLock())

Return Nil
