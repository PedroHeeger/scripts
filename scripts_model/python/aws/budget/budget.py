#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS BUDGET")
print("BUDGET CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
account_id = "001727357081"
budget_name = "Gastos acima de 2.5 dolares"
limit_amount = 2.5
threshold = 50
address = "pedroheeger19@outlook.com"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um objeto de recurso para o serviço Budget")
    budgets_client = boto3.client('budgets')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o budget de nome {budget_name}")
    response = budgets_client.describe_budgets(AccountId=account_id)
    budgets = response.get('Budgets', [])
    
    if any(budget['BudgetName'] == budget_name for budget in budgets):
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o budget de nome {budget_name}")
        print(budget_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de todos os budgets criados")
        all_budget_names = [budget['BudgetName'] for budget in budgets]
        print('\n'.join(all_budget_names))
    
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o budget de nome {budget_name}")
        budgets_client.create_budget(
            AccountId=account_id,
            Budget={
                'BudgetName': budget_name,
                'BudgetLimit': {
                    'Amount': str(limit_amount),
                    'Unit': 'USD'
                },
                'TimeUnit': 'MONTHLY',
                'BudgetType': 'COST'
            }
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando um alerta para o orçamento de nome {budget_name}")
        budgets_client.create_notification(
            AccountId=account_id,
            BudgetName=budget_name,
            Notification={
                'NotificationType': 'ACTUAL',
                'ComparisonOperator': 'GREATER_THAN',
                'Threshold': threshold,
                'ThresholdType': 'PERCENTAGE',
                'NotificationState': 'ALARM'
            },
            Subscribers=[
                {
                    'SubscriptionType': 'EMAIL',
                    'Address': address
                }
            ]
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome do budget criado")
        print(budget_name)
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS BUDGET")
print("BUDGET EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
account_id = "001727357081"
budget_name = "Gastos acima de 2.5 dolares"
threshold = 50
address = "pedroheeger19@outlook.com"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um objeto de recurso para o serviço Budget")
    budgets_client = boto3.client('budgets')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o budget de nome {budget_name}")
    response = budgets_client.describe_budgets(AccountId=account_id)
    budgets = response.get('Budgets', [])

    if any(budget['BudgetName'] == budget_name for budget in budgets):
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de todos os budgets criados")
        all_budget_names = [budget['BudgetName'] for budget in budgets]
        print('\n'.join(all_budget_names))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe alerta no budget de nome {budget_name}")
        notifications = budgets_client.describe_notifications_for_budget(AccountId=account_id, BudgetName=budget_name)['Notifications']
        if notifications:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o alerta do budget de nome {budget_name}")
            for notification in notifications:
                budgets_client.delete_notification(AccountId=account_id, BudgetName=budget_name, Notification={
                    'NotificationType': notification['NotificationType'],
                    'ComparisonOperator': notification['ComparisonOperator'],
                    'Threshold': notification['Threshold'],
                    'ThresholdType': notification['ThresholdType'],
                    'NotificationState': notification['NotificationState']
                })
        else:
            print(f"Não existe alerta para o budget de nome {budget_name}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o budget de nome {budget_name}")
        budgets_client.delete_budget(AccountId=account_id, BudgetName=budget_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando o nome de todos os budgets criados")
        all_budget_names_after_deletion = [budget['BudgetName'] for budget in budgets_client.describe_budgets(AccountId=account_id)['Budgets']]
        print('\n'.join(all_budget_names_after_deletion))
    else:
        print(f"Não existe o budget de nome {budget_name}")
else:
    print("Código não executado")