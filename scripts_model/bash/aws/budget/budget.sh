#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS BUDGET"
echo "BUDGET CREATION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
accountId="005354053245"
budgetName="Gastos acima de 4.0 dolares"
limitAmount=4.0
threshold=50
address="pedroheeger19@gmail.com"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o budget de nome $budgetName"
    if [ $(aws budgets describe-budgets --account-id $accountId --query "Budgets[?BudgetName=='${budgetName}'].BudgetName" --output text | wc -l) -gt 1 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Já existe o budget de nome $budgetName"
        aws budgets describe-budgets --account-id $accountId --query "Budgets[?BudgetName=='${budgetName}'].BudgetName" --output text
    else
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome de todos os budgets criados"
        aws budgets describe-budgets --account-id $accountId --query "Budgets[].BudgetName" --output text
    
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando o budget de nome $budgetName (Shorthand Syntax)"
        aws budgets create-budget --account-id $accountId --budget "BudgetName=$budgetName,BudgetLimit={Amount=$limitAmount,Unit=USD},TimeUnit=MONTHLY,BudgetType=COST"

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando o budget de nome $budgetName (JSON)"
        # aws budgets create-budget --account-id $accountId --budget "{
        #     \"BudgetName\":\"$budgetName\",
        #     \"BudgetLimit\":{
        #         \"Amount\":\"$limitAmount\",
        #         \"Unit\":\"USD\"
        #     },
        #     \"TimeUnit\":\"MONTHLY\",
        #     \"BudgetType\":\"COST\"
        # }"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Criando um alerta para o orçamento de nome $budgetName (Shorthand Syntax)"
        aws budgets create-notification --account-id $accountId --budget-name $budgetName --notification "NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=$threshold,ThresholdType=PERCENTAGE,NotificationState=ALARM" --subscribers "SubscriptionType=EMAIL,Address=$address"

        # echo "-----//-----//-----//-----//-----//-----//-----"
        # echo "Criando um alerta para o orçamento de nome $budgetName (JSON)"
        # aws budgets create-notification --account-id $accountId --budget-name $budgetName --notification "{ 
        #     \"NotificationType\":\"ACTUAL\",
        #     \"ComparisonOperator\":\"GREATER_THAN\",
        #     \"Threshold\":$threshold,
        #     \"ThresholdType\":\"PERCENTAGE\",
        #     \"NotificationState\":\"ALARM\"
        # }" --subscribers "[{
        #       \"SubscriptionType\":\"EMAIL\",
        #       \"Address\":\"$address\"
        # }]"

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome do budget criado"
        aws budgets describe-budgets --account-id $accountId --query "Budgets[?BudgetName=='${budgetName}'].BudgetName" --output text
    fi
else
    echo "Código não executado"
fi




#!/bin/bash

echo "***********************************************"
echo "SERVIÇO: AWS BUDGET"
echo "BUDGET EXCLUSION"

echo "-----//-----//-----//-----//-----//-----//-----"
echo "Definindo variáveis"
account_id="005354053245"
budget_name="Gastos acima de 4.0 dolares"
threshold=50
address="pedroheeger19@gmail.com"

echo "-----//-----//-----//-----//-----//-----//-----"
read -p "Deseja executar o código? (y/n) " resposta
if [ "$resposta" = "y" ] || [ "$resposta" = "Y" ]; then
    echo "-----//-----//-----//-----//-----//-----//-----"
    echo "Verificando se existe o budget de nome $budget_name"
    if [ $(aws budgets describe-budgets --account-id $account_id --query "Budgets[?BudgetName=='${budget_name}'].BudgetName" --output text | wc -l) -gt 0 ]; then
        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome de todos os budgets criados"
        aws budgets describe-budgets --account-id $account_id --query "Budgets[].BudgetName" --output text

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Verificando se existe alerta no budget de nome $budget_name"
        if [ $(aws budgets describe-notifications-for-budget --account-id $account_id --budget-name $budget_name --query "Notifications" --output text | wc -l) -gt 0 ]; then
            echo "-----//-----//-----//-----//-----//-----//-----"
            echo "Removendo o alerta do budget de nome $budget_name"
            aws budgets delete-notification --account-id $account_id --budget-name $budget_name --notification "NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=$threshold,ThresholdType=PERCENTAGE,NotificationState=ALARM"
        else
            echo "Não existe alerta para o budget de nome $budget_name"
        fi

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Removendo o budget de nome $budget_name"
        aws budgets delete-budget --account-id $account_id --budget-name $budget_name

        echo "-----//-----//-----//-----//-----//-----//-----"
        echo "Listando o nome de todos os budgets criados"
        aws budgets describe-budgets --account-id $account_id --query "Budgets[].BudgetName" --output text
    else
        echo "Não existe o budget de nome $budget_name"
    fi
else
    echo "Código não executado"
fi