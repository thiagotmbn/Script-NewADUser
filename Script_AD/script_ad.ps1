Write-Host "---------------------------------------------------Iniciando----------------------------------------------------------" -ForegroundColor Green
Write-Host ""

try{

#Caminho e importação de arquivo .csv
$caminhocsv = "C:\Script_AD\script_ad.csv"
$csv = Import-Csv -Path $caminhocsv -Delimiter ';'
Write-Host "Buscando dados do seguinte arquivo:'$caminhocsv' "
Write-Host ""

    #Criação de usuário
    function NewUser {
        param(
        [String]$Nome_F = $Nome_F.Trim(),
        [String]$Conta_F = $Conta_F.Trim(),
        [String]$Dominio_F = $Dominio_F.Trim(),
        [String]$Descricao_F = $Descricao_F.Trim(),
        [String]$Caminho_F = $Caminho_F.Trim()
        )

        New-ADUser `
            -Name $Nome_F `
            -UserPrincipalName $Dominio_F `
            -DisplayName $Nome_F `
            -SamAccountName $Conta_F `
            -Description $Descricao_F `
            -AccountPassword (ConvertTo-SecureString -AsPlainText 'Mudar@123' -force) `
            -Enabled $true `
            -ChangePasswordAtLogon $True `
            -Path $Caminho_F;

             write-host "Usuário '$Nome_F' criado com sucesso!" -foregroundcolor Green
             Write-Host "----------------------------------------------------------------------------------------------------------------------"
             Write-Host ""
             Write-Host "Nome: $Nome_F"
             Write-Host "Conta: $Conta_F"
             Write-Host "Senha temporaria: Mudar@123"
             Write-Host "Descricao: $Descricao_F"
             Write-Host "Status da conta: Ativa!"
             Write-Host ""
             Write-Host "----------------------------------------------------------------------------------------------------------------------"
             Write-Host ""
             Write-Host ""
    

             }

    #Teste de domínio
    function Testando_Dominio {
        
        param([string]$AD)
        $AD = $AD.Trim()
        $Floresta_AD= (get-adforest).Domains

        
        
            if($Floresta_AD -contains $AD) {
            
                return $true

            } else {
            
                return $false

            }


    }

    #Teste de Usuario já existente
    function Testando_User {
        
        [CmdletBinding()]
        param([String]$userad)
        $userad = $userad.Trim()

        try{
            
            get-aduser -identity $Conta -erroraction stop | Out-Null;
            return -not $true

        } catch {
        
            return -not $false
        
        }

    }

    #Teste de OU existente
    function Testando_OU {
        
        [CmdletBinding()]
        param([String]$OU)
        $OU = $OU.Trim()

        try{
        
            get-adorganizationalunit -identity $OU -erroraction stop | Out-Null
            return $true

        } catch {
        
            return $false
        
        }

    }

#Array de busca de informações em arquivo .csv
ForEach( $Lista in $csv) {

    $Nome = "$($Lista.FirstName) $($Lista.LastName)"
    $Conta = "$($Lista.Conta)"
    $Nome_AD= "$($Lista.Dominio)"
    $Dominio = "$($Lista.Conta)"+"@"+"$Nome_AD"
    $Descricao = "$($Lista.Descricao)"
    $Caminho = $($Lista.Caminho)

    

    #Resultado das funções, assim determinando a elegibilidade do usuario a ser criado
    $Teste_Dominio = Testando_Dominio -AD $Nome_AD
    $Teste_User = Testando_User -userad $Dominio
    $Teste_OU = Testando_OU -OU $Caminho
    $Variavel_Testes= ($Teste_User) -and (($Teste_OU) -and ($Teste_Dominio))
    
    #Criação de usuário, com validação prévia
    switch($Variavel_Testes){
        
        #Determina a criação do usuário
        $true{
        
        NewUser -Nome_F $Nome -Conta_F $Conta -Dominio_F $Dominio -Descricao_F $Descricao -Caminho_F $Caminho;
        break;
        
        }

        $false{
            
            #Determina que o usuário informado já existe
            if($Teste_User -eq $false){
                
                $Local = (Get-ADUser -Identity $Conta).DistinguishedName
                write-host "Usuário '$Nome' não pôde ser criado!" -foregroundcolor yellow 
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host "Erro: Usuário '$Nome' já existente!"
                Write-Host "Localização: '$Local'"
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host ""
                Write-Host ""
                break;
            
            #Determina domínio inválido
            } elseif($Teste_Dominio -eq $false) {

                write-host "Usuário '$Nome' não pôde ser criado!" -foregroundcolor yellow 
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host "Erro: Domínio inválido!"
                Write-Host "Domínio informado: '$Nome_AD'"
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host ""
                Write-Host ""
                break;
            
            #Determina caminho inválido
            } elseif($Teste_OU -eq $false) {

                write-host "Usuário '$Nome' não pôde ser criado!" -foregroundcolor yellow 
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host "Erro: Caminho inválido!"
                Write-Host "Caminho informado: '$Caminho'"
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host ""
                Write-Host ""
                break;

            #Determina informações inválidas 
            } else {
                
                write-host "Usuário '$Nome' não pôde ser criado!" -foregroundcolor yellow
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host "Erro: Unidade organizacional e/ou nome de usuario inválidos !"
                Write-Host "Usuário informado: '$Nome'."
                Write-Host "Caminho informado: '$Caminho'."                 
                Write-Host "----------------------------------------------------------------------------------------------------------------------"
                Write-Host ""
                Write-Host ""
                break;

            }

        }


        #Erro na criação do usuário
        default{
            
            Write-Host "Erro desconhecido!" -ForegroundColor Yellow
            Write-Host "----------------------------------------------------------------------------------------------------------------------"
            Write-Host ""
            Write-Host "Validações relacionadas ao arquivo de usuários será necessária:"
            Write-Host ""
            Write-Host "* Valide se arquivo .csv está delimitado corretamente!"
            Write-Host "* Valide se as informações do usuário foram inseridas corretamente em suas respectivas colunas!"
            Write-Host ""
            Write-Host "----------------------------------------------------------------------------------------------------------------------"
            break;

        }
    
    }

   }                
}

#Erro pré-execução
catch{
            
            Write-Host "Falha na execução!" -ForegroundColor yellow
            Write-Host "----------------------------------------------------------------------------------------------------------------------" -ForegroundColor red
            Write-Host ""
            Write-Host "* Valide se o script está sendo executado no equipamento correto, ele deverá ser executado no servidor AD!"
            Write-Host "* Valide se o seu usuário possui as permissões adequadas tanto para a criação de usuários quanto de uso ao PowerShell!"
            Write-Host "* Valide se o arquivo .csv se encontra no caminho correto e/ou com o nome correto!"
            Write-Host ""
            Write-Host "Nome correto: 'script_ad.csv'"
            Write-Host "Caminho correto: 'C:\Script_AD\script_ad.csv'"
            Write-Host ""
            Write-Host "----------------------------------------------------------------------------------------------------------------------" -ForegroundColor red

}                    

Write-Host "---------------------------------------------------Finalizado---------------------------------------------------------" -ForegroundColor Green

Write-Host ""
Read-Host "Pressione ENTER para sair..."