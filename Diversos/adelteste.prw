//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} zTeste
Função de Teste
@type function
@author Terminal de Informação
@since 13/11/2016
@version 1.0
    @example
    u_zTeste()
/*/
 
User Function zTeste()
    Local aArea  := GetArea()
    Local aArray := {}
     
    //Adicionando elementos na matriz
    aAdd(aArray, "Daniel")
    aAdd(aArray, noAcento("João"))
    aAdd(aArray, "Gabriel")
    aAdd(aArray, "Fernando")
     
    //Exclui o segundo elemento do Array (Deixa o segundo elemento como Nil)
    aDel(aArray, 3)
     
    //Mostra o Tamanho do Array
    Alert("Tamanho do Array: "+cValToChar(Len(aArray))+", 2º elemento: "+cValToChar(aArray[2]))
     
    RestArea(aArea)
Return
