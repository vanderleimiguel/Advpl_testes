#include "Protheus.ch"
#include "FwMvcDef.ch"

//User Function Principal
User Function MVCCAD()
    Local oBrowse   := FwLoadBrw("MVCCAD")

    oBrowse:Activate()

Return

//Responsavel por Criar o Browse(Tela Inicial)
Static Function BrowseDef()
    Local oBrowse   := FwmBrowse():New()

    oBrowse:SetAlias("SZ9") //Alias da tabela do cadastro
    oBrowse:SetDescription("Tela MVC - Modelo 1 - Cadastro Tabela SZ9") //Titulo da tela

    //Adicionar legenda
    oBrowse:AddLegend("SZ9->Z9_STATUS == '1'","GREEN"   , "Cadastro Ativo")
    oBrowse:AddLegend("SZ9->Z9_STATUS == '2'","RED"     , "Cadastro Inativo")

    // oBrowse:SetOnlyFields({"Z9_CODIGO", "Z9_NOME", "Z9_ESTCIV", "Z9_STATUS"}) //Campos que serao mostrados no browse
    oBrowse:SetOnlyFields({"Z9_CODIGO", "Z9_NOME", "Z9_ESTCIV"}) //Campos que serao mostrados no browse
    oBrowse:DisableDetails() //Desabilita detalhes no rodape

    oBrowse:Activate()

Return oBrowse

//Este é o que seria chamado de controle
Static Function MenuDef()
    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.MVCCAD' OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir'    ACTION 'VIEWDEF.MVCCAD' OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar'    ACTION 'VIEWDEF.MVCCAD' OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir'    ACTION 'VIEWDEF.MVCCAD' OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Copiar'     ACTION 'VIEWDEF.MVCCAD' OPERATION 9 ACCESS 0
    ADD OPTION aMenu TITLE 'Imprimir'   ACTION 'VIEWDEF.MVCCAD' OPERATION 8 ACCESS 0
    ADD OPTION aMenu TITLE 'Legenda'    ACTION 'U_SZ9Leg'       OPERATION 6 ACCESS 0
    ADD OPTION aMenu TITLE 'Sobre'      ACTION 'U_SZ9Sob'       OPERATION 6 ACCESS 0

    /*
    1 - Pesquisar
    2 - Visualizar
    3 - Incluir
    4 - Alterar
    5 - Excluir
    6 - Outras funções
    7 - 
    8 - Imprimir
    9 - Copiar
    */

Return aMenu

//Camada do Modelo de dados
Static Function ModelDef()
    Local oModel        := NIL
    Local oStructSZ9    := FwFormStruct(1, "SZ9") //Trazer a estrutura da tabela

    oModel  := MPFormModel():New("MVCCADM",/*PreValid*/,/*PosValid*/,/*Commit*/,/*Cancel*/)
    oModel:AddFields("FORMSZ9",,oStructSZ9) //Formulario de insercao de dados
    oModel:SetPrimaryKey({"Z9_FILIAL","Z9_CODIGO"})
    oModel:SetDescription("Modelo de dados MVCCAD")
    oModel:GetModel("FORMSZ9"):SetDescription("Formulario de Cadastro SZ9")

Return oModel

//Camada de visao, controla o que é exibido em tela
Static Function ViewDef()
    Local oView         := NIL
    Local oModel        := FwLoadModel("MVCCAD")
    Local oStructSZ9    := FwFormStruct(2, "SZ9") //Trazer a estrutura da tabela

    oView   := FwFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEWSZ9", oStructSZ9, "FORMSZ9" )
    oView:CreateHorizontalBox("TELASZ9",100)
    oView:EnableTitleView("VIEWSZ9", "VISUALIZACAO DOS PROTHEUZEIROS")
    oView:SetCloseOnOk({|| .T.})
    oView:SetOwnerView("VIEWSZ9", "TELASZ9")

Return oView

//Outras Opcoes
User Function SZ9LEG()
    Local aLegenda  := {}

    aAdd(aLegenda,{"BR_VERDE"   , "Ativo"})
    aAdd(aLegenda,{"BR_VERMELHO", "Inativo"})
    
    BrwLegenda("Legenda","Ativos/Inativos", aLegenda)
Return aLegenda

User Function SZ9Sob()
    Local cSobre    := ""

    cSobre  := "-<b>Minha Primeira tela em MVC Modelo 1<br> Este Fonte foi desenvolvido por Vanderlei Miguel"
    MsgInfo(cSobre)

Return
