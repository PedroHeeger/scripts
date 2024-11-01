#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("ACL OBJECT CHANGE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
object_name = "objTest.jpg"
# CanonicalUser = Usuário que criou o bucket, com controle total e acesso garantido independentemente de outras configurações.
# AuthenticatedUsers = Usuários com contas AWS que recebem permissões concedidas, permitindo ações limitadas no bucket.
# AllUsers = Acesso público que permite qualquer pessoa na internet interagir com o bucket (Everyone).

# Permissões originais
# canonical_user_permissions = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]
# authenticated_users_permissions = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]
# all_users_permissions = ["READ", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]

# Primeiro conjunto de permissões
canonical_user_permissions = ["FULL_CONTROL"]
authenticated_users_permissions = []
all_users_permissions = ["READ"]

# Segundo conjunto de permissões
# canonical_user_permissions = ["FULL_CONTROL"]
# authenticated_users_permissions = ["READ"]
# all_users_permissions = ["READ"]

# Terceiro conjunto de permissões
# canonical_user_permissions = ["READ_ACP", "WRITE_ACP"]
# authenticated_users_permissions = ["READ_ACP", "WRITE_ACP"]
# all_users_permissions = ["READ_ACP", "WRITE_ACP"]

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    try:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o bucket {bucket_name}")
        s3_client = boto3.client('s3', region_name=region)
        s3_client.head_bucket(Bucket=bucket_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo as permissões atuais dos grupos de destinatários da ACL do objeto {object_name}")   
        acl_response = s3_client.get_object_acl(Bucket=bucket_name, Key=object_name)
        grants = acl_response['Grants']
        
        canonical_user_currently_permissions = [g['Permission'] for g in grants if g['Grantee']['Type'] == 'CanonicalUser']
        authenticated_users_currently_permissions = [g['Permission'] for g in grants if g['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers']
        all_users_currently_permissions = [g['Permission'] for g in grants if g['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando as permissões dos grupos de destinatários da ACL do objeto {object_name} se estão conforme definidas nas variáveis")         
        canonical_user_cond = (sorted(canonical_user_currently_permissions) == sorted(canonical_user_permissions))
        authenticated_users_cond = (sorted(authenticated_users_currently_permissions) == sorted(authenticated_users_permissions))
        all_users_cond = (sorted(all_users_currently_permissions) == sorted(all_users_permissions))

        if canonical_user_cond and authenticated_users_cond and all_users_cond:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"As permissões dos grupos de destinatários da ACL objeto {object_name} já estão configuradas")
            for grant in acl_response['Grants']:
                grantee_type = grant['Grantee']['Type']
                grantee_uri = grant['Grantee'].get('URI', '')
                permission = grant['Permission']
                print(f"Grantee: {grantee_type}, URI: {grantee_uri}, Permission: {permission}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões dos grupos de destinatários da ACL do objeto {object_name}")
            for grant in acl_response['Grants']:
                grantee_type = grant['Grantee']['Type']
                grantee_uri = grant['Grantee'].get('URI', '')
                permission = grant['Permission']
                print(f"Grantee: {grantee_type}, URI: {grantee_uri}, Permission: {permission}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o Id do grupo de destinatário CanonicalUser")
            id_canonical_user = acl_response['Owner']['ID']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Montando os parâmetros do comando para configurar as permissões")
            full_control_grantees = []
            if "FULL_CONTROL" in canonical_user_permissions:
                full_control_grantees.append(f"id={id_canonical_user}")
            if "FULL_CONTROL" in authenticated_users_permissions:
                full_control_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "FULL_CONTROL" in all_users_permissions:
                full_control_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            full_control_param = ", ".join(full_control_grantees) if full_control_grantees else ""

            read_grantees = []
            if "READ" in canonical_user_permissions:
                read_grantees.append(f"id={id_canonical_user}")
            if "READ" in authenticated_users_permissions:
                read_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "READ" in all_users_permissions:
                read_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            read_param = ", ".join(read_grantees) if read_grantees else ""

            read_acp_grantees = []
            if "READ_ACP" in canonical_user_permissions:
                read_acp_grantees.append(f"id={id_canonical_user}")
            if "READ_ACP" in authenticated_users_permissions:
                read_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "READ_ACP" in all_users_permissions:
                read_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            read_acp_param = ", ".join(read_acp_grantees) if read_acp_grantees else ""

            write_acp_grantees = []
            if "WRITE_ACP" in canonical_user_permissions:
                write_acp_grantees.append(f"id={id_canonical_user}")
            if "WRITE_ACP" in authenticated_users_permissions:
                write_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "WRITE_ACP" in all_users_permissions:
                write_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            write_acp_param = ", ".join(write_acp_grantees) if write_acp_grantees else ""
                
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Configurando as permissões dos grupos de destinatários da ACL do objeto {object_name} conforme definidas nas variáveis")
            grant_params = {}
            if full_control_param:
                grant_params['GrantFullControl'] = full_control_param
            if read_param:
                grant_params['GrantRead'] = read_param
            if read_acp_param:
                grant_params['GrantReadACP'] = read_acp_param
            if write_acp_param:
                grant_params['GrantWriteACP'] = write_acp_param

            s3_client.put_object_acl(Bucket=bucket_name, Key=object_name, **grant_params)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões dos grupos de destinatários da ACL do objeto {object_name}")
            acl_response = s3_client.get_object_acl(Bucket=bucket_name, Key=object_name)
            for grant in acl_response['Grants']:
                grantee_type = grant['Grantee']['Type']
                grantee_uri = grant['Grantee'].get('URI', '')
                permission = grant['Permission']
                print(f"Grantee: {grantee_type}, URI: {grantee_uri}, Permission: {permission}")

    except boto3.exceptions.botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == '404':
            print(f"Não existe o bucket {bucket_name}")
        else:
            print(f"Necessário verificar as seguintes configurações do bucket {bucket_name}: bloqueio de acesso público do bucket, proprietário dos objetos (Object Ownership) e as permissões dos grupos de destinatários da ACL do bucket. Alguma dessas configurações podem estar impedindo a configuração da ACL nos objetos.")
else:
    print("Código não executado")