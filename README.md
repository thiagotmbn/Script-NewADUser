# Script-NewADUser
Criar novos usuários em lote no Active Directory através de lista .csv e script powershell

1.Colocar a pasta "Script_AD" diretamente no disco "C:", caso esteja compactada, lembrar de descompactar no local orientado;

2.Edite o arquivo .csv com as informações dos usuários a serem criados, em suas respectivas colunas;

3.Execute o arquivo .ps1 com o PowerShell;

OBS: 

* Lembre-se que o seu usuário deverá ter as permissões adequadas dentro do domínio !

* Caso não utilize o arquivo .csv disponibilizado neste compilado, validar o delimitador utilizado do arquivo a ser usado além das nomenclaturas utilizadas nas colunas !

* Caso deseje alterar o delimitador para ",", basta apagar o seguinte atributo na linha 8 do arquivo .ps1: <-Delimiter ';'>, ele é o delimitador do arquivo .csv presente neste compilado ! 
