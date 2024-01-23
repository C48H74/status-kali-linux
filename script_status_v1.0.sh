#!/bin/bash

# Caminho para o arquivo de relatório
RELATORIO="/relatorio.txt"

# Função para imprimir a barra de progresso
imprimir_barra_progresso() {
    local progresso="$1"
    local largura_barra=50
    local preenchimento='='
    local vazio=' '

    # Calcula a quantidade de preenchimento
    local preenchido=$(($largura_barra * $progresso / 100))
    local vazio=$((largura_barra - preenchido))

    # Imprime a barra de progresso com cor
    printf "\033[1;34m["  # Cor azul claro
    printf "\033[1;36m%${preenchido}s" | tr ' ' "$preenchimento"  # Cor azul ciano
    printf "\033[1;31m%${vazio}s" | tr ' ' "$vazio"  # Cor vermelha
    printf "\033[1;34m] %d%%\033[0m\r" "$progresso"  # Restaura cor e adiciona percentual
}

# Função para executar comando e imprimir status
executar_comando() {
    local comando="$1"
    local mensagem="$2"

    echo -n "Executando: $mensagem..."
    eval $comando
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m[OK]\033[0m"  # Cor verde para OK
    else
        echo -e "\033[1;31m[FALHA]\033[0m"  # Cor vermelha para FALHA
    fi
}

# Adiciona marcador de início do relatório
echo -e "\033[1;33m=== Início do Relatório ===\033[0m" > $RELATORIO  # Cor amarela

# Adiciona informações do sistema ao relatório
echo -e "\n\033[1;33m=== Informações do Sistema ===\033[0m" >> $RELATORIO
uname -a >> $RELATORIO
lsb_release -a >> $RELATORIO
echo -e "\n=============================" >> $RELATORIO

# Adiciona informações de utilização de CPU e memória ao relatório
echo -e "\n\033[1;33m=== Utilização de CPU ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "20"
executar_comando "top -n 1 -b" "Utilização de CPU" >> $RELATORIO
echo -e "\n=========================" >> $RELATORIO

echo -e "\n\033[1;33m=== Utilização de Memória ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "40"
executar_comando "free -h" "Utilização de Memória" >> $RELATORIO
echo -e "\n=============================" >> $RELATORIO

# Adiciona informações de espaço em disco ao relatório
echo -e "\n\033[1;33m=== Espaço em Disco ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "60"
executar_comando "df -h" "Espaço em Disco" >> $RELATORIO
echo -e "\n========================" >> $RELATORIO

# Adiciona a lista de processos ao relatório
echo -e "\n\033[1;33m=== Lista de Processos ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "80"
executar_comando "ps aux" "Lista de Processos" >> $RELATORIO
echo -e "\n===========================" >> $RELATORIO

# Adiciona informações de rede ao relatório
echo -e "\n\033[1;33m=== Conexões de Rede ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "90"
executar_comando "netstat -tuln" "Conexões de Rede" >> $RELATORIO
echo -e "\n=========================" >> $RELATORIO

echo -e "\n\033[1;33m=== Interfaces de Rede ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "92"
executar_comando "ifconfig -a" "Interfaces de Rede" >> $RELATORIO
echo -e "\n===========================" >> $RELATORIO

echo -e "\n\033[1;33m=== Estatísticas de Rede ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "94"
executar_comando "sar -n DEV 1 3" "Estatísticas de Rede" >> $RELATORIO
echo -e "\n===========================" >> $RELATORIO

# Adiciona informações de logs ao relatório
echo -e "\n\033[1;33m=== Log do Sistema ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "96"
executar_comando "dmesg | tail" "Log do Sistema" >> $RELATORIO
echo -e "\n======================" >> $RELATORIO

echo -e "\n\033[1;33m=== Log de Autenticação ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "97"
executar_comando "cat /var/log/auth.log" "Log de Autenticação" >> $RELATORIO
echo -e "\n===========================" >> $RELATORIO

echo -e "\n\033[1;33m=== Log do Sistema ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "98"
executar_comando "tail /var/log/syslog" "Log do Sistema" >> $RELATORIO
echo -e "\n=======================" >> $RELATORIO

# Adiciona informações sobre serviços ao relatório
echo -e "\n\033[1;33m=== Serviços em Execução ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "99"
executar_comando "systemctl list-units --type=service" "Serviços em Execução" >> $RELATORIO
echo -e "\n=============================" >> $RELATORIO

# Adiciona informações de status de inicialização ao relatório
echo -e "\n\033[1;33m=== Status de Inicialização ===\033[0m" >> $RELATORIO
imprimir_barra_progresso "100"
executar_comando "systemctl list-jobs" "Status de Inicialização" >> $RELATORIO
echo -e "\n===============================" >> $RELATORIO

# Adiciona marcador de fim do relatório e linha do tempo de execução
echo -e "\n\033[1;33m=== Fim do Relatório ===\033[0m" >> $RELATORIO
echo -e "\n\033[1;33mLinha do tempo de execução:\033[0m" >> $RELATORIO
date >> $RELATORIO

# Adiciona resumo dos comandos executados ao final do relatório
echo -e "\n\033[1;33m=== Resumo dos Comandos Executados ===\033[0m" >> $RELATORIO
grep -E "\[OK\]|\[FALHA\]" $RELATORIO | sed 's/Executando: //g' >> $RELATORIO

# Exibe o resumo na tela
echo -e "\n\033[1;33mResumo dos Comandos Executados:\033[0m"
grep -E "\[OK\]|\[FALHA\]" $RELATORIO | sed 's/Executando: //g'

# Imprime mensagem resumida indicando que o relatório foi gerado
echo -e "\n\033[1;32mRelatório gerado com sucesso em:\033[0m $RELATORIO"

