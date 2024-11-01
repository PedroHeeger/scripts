import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("ACL BUCKET CHANGE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
# CanonicalUser = Usuário que criou o bucket, com controle total e acesso garantido independentemente de outras configurações.
# AuthenticatedUsers = Usuários com contas AWS que recebem permissões concedidas, permitindo ações limitadas no bucket.
# LogDelivery = Permissões para serviços da AWS depositarem logs diretamente no bucket, como CloudTrail ou S3 Server Access Logs.
# AllUsers = Acesso público que permite qualquer pessoa na internet interagir com o bucket (Everyone).

# Permissões originais
# canonical_user_permissions = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]
# authenticated_users_permissions = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]
# log_delivery_permissions = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]
# all_users_permissions = ["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"]

# Primeiro conjunto de permissões
canonical_user_permissions = ["FULL_CONTROL"]
authenticated_users_permissions = []
log_delivery_permissions = []
all_users_permissions = ["READ"]

# Segundo conjunto de permissões
# canonical_user_permissions = ["READ", "WRITE"]
# authenticated_users_permissions = ["WRITE"]
# log_delivery_permissions = ["WRITE"]
# all_users_permissions = ["FULL_CONTROL"]

# Terceiro conjunto de permissões
# canonical_user_permissions = ["READ_ACP", "WRITE_ACP"]
# authenticated_users_permissions = ["READ_ACP", "WRITE_ACP"]
# log_delivery_permissions = ["READ_ACP", "WRITE_ACP"]
# all_users_permissions = ["READ_ACP", "WRITE_ACP"]


print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n): ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket {bucket_name}")
    s3_client = boto3.client('s3')
    bucket_name = 'bucket-test1-ph'
    buckets = s3_client.list_buckets().get('Buckets', [])
    bucket_exists = any(bucket['Name'] == bucket_name for bucket in buckets)

    if bucket_exists:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Extraindo as permissões atuais dos grupos de destinatários da ACL sobre os objetos do bucket {bucket_name}")
        permissions = s3_client.get_bucket_acl(Bucket=bucket_name).get('Grants', [])
        
        # Processa permissões específicas
        canonical_user_current_permissions = [
            grant['Permission'] for grant in permissions if grant['Grantee'].get('Type') == 'CanonicalUser'
        ]
        authenticated_users_current_permissions = [
            grant['Permission'] for grant in permissions if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
        ]
        log_delivery_current_permissions = [
            grant['Permission'] for grant in permissions if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/s3/LogDelivery'
        ]
        all_users_current_permissions = [
            grant['Permission'] for grant in permissions if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers'
        ]

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando as permissões dos grupos de destinatários da ACL sobre os objetos do bucket {bucket_name} se estão conforme definidas nas variáveis") 
        cond1 = sorted(canonical_user_current_permissions) == sorted(canonical_user_permissions)
        cond2 = sorted(authenticated_users_current_permissions) == sorted(authenticated_users_permissions)
        cond3 = sorted(log_delivery_current_permissions) == sorted(log_delivery_permissions)
        cond4 = sorted(all_users_current_permissions) == sorted(all_users_permissions)

        if cond1 and cond2 and cond3 and cond4:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"As permissões dos grupos de destinatários da ACL do bucket {bucket_name} já estão configuradas")
            acl = s3_client.get_bucket_acl(Bucket=bucket_name)
            for grant in acl['Grants']:
                grantee_type = grant['Grantee']['Type']
                grantee_uri = grant['Grantee'].get('URI', '')
                permission = grant['Permission']
                print(f"Grantee: {grantee_type}, URI: {grantee_uri}, Permission: {permission}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões dos grupos de destinários da ACL sobre os objetos do bucket {bucket_name}")
            acl = s3_client.get_bucket_acl(Bucket=bucket_name)
            for grant in acl['Grants']:
                grantee_type = grant['Grantee']['Type']
                grantee_uri = grant['Grantee'].get('URI', '')
                permission = grant['Permission']
                print(f"Grantee: {grantee_type}, URI: {grantee_uri}, Permission: {permission}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket {bucket_name} é o BucketOwnerPreferred")
            ownership_controls = s3_client.get_bucket_ownership_controls(Bucket=bucket_name)
            condition = any(rule['ObjectOwnership'] == 'BucketOwnerPreferred' for rule in ownership_controls['OwnershipControls']['Rules'])
            if condition:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já foi configurado o proprietário dos objetos no bucket {bucket_name} para BucketOwnerPreferred")
                for rule in ownership_controls['OwnershipControls']['Rules']:
                    print(rule['ObjectOwnership'])
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o proprietário dos objetos no bucket {bucket_name}")
                for rule in ownership_controls['OwnershipControls']['Rules']:
                    print(rule['ObjectOwnership'])

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Alterando o proprietário dos objetos no bucket {bucket_name} para BucketOwnerPreferred")
                s3_client.put_bucket_ownership_controls(
                    Bucket=bucket_name,
                    OwnershipControls={
                        'Rules': [{'ObjectOwnership': 'BucketOwnerPreferred'}]
                    }
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o proprietário dos objetos no bucket {bucket_name}")
                ownership_controls = s3_client.get_bucket_ownership_controls(Bucket=bucket_name)
                for rule in ownership_controls['OwnershipControls']['Rules']:
                    print(rule['ObjectOwnership'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se as configurações de bloqueio de acesso público do bucket {bucket_name} estão bloqueando ou impedindo a configuração da ACL")
            public_access_block = s3_client.get_public_access_block(Bucket=bucket_name)
            condition = (public_access_block['PublicAccessBlockConfiguration']['BlockPublicAcls'] and
                        public_access_block['PublicAccessBlockConfiguration']['IgnorePublicAcls'] and
                        public_access_block['PublicAccessBlockConfiguration']['RestrictPublicBuckets'])
            
            if condition:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Alterando as configurações de bloqueio de acesso público do bucket {bucket_name} para permitir a configuração da ACL")
                s3_client.put_public_access_block(
                    Bucket=bucket_name,
                    PublicAccessBlockConfiguration={
                        'BlockPublicAcls': False,
                        'IgnorePublicAcls': False,
                        'RestrictPublicBuckets': False
                    }
                )
            else:
                print(f"As configurações de bloqueio de acesso público do bucket {bucket_name} não estão bloqueando ou impedindo a configuração da ACL")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o Id do grupo de destinatário CanonicalUser")
            id_canonical_user = acl['Owner']['ID']

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Montando os parâmetros do comando para configurar as permissões")
            full_control_grantees = []
            if "FULL_CONTROL" in canonical_user_permissions:
                full_control_grantees.append(f"id={id_canonical_user}")
            if "FULL_CONTROL" in authenticated_users_permissions:
                full_control_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "FULL_CONTROL" in log_delivery_permissions:
                full_control_grantees.append("uri=http://acs.amazonaws.com/groups/s3/LogDelivery")
            if "FULL_CONTROL" in all_users_permissions:
                full_control_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            full_control_param = ", ".join(full_control_grantees) if full_control_grantees else ""

            read_grantees = []
            if "READ" in canonical_user_permissions:
                read_grantees.append(f"id={id_canonical_user}")
            if "READ" in authenticated_users_permissions:
                read_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "READ" in log_delivery_permissions:
                read_grantees.append("uri=http://acs.amazonaws.com/groups/s3/LogDelivery")
            if "READ" in all_users_permissions:
                read_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            read_param = ", ".join(read_grantees) if read_grantees else ""

            write_grantees = []
            if "WRITE" in canonical_user_permissions:
                write_grantees.append(f"id={id_canonical_user}")
            if "WRITE" in authenticated_users_permissions:
                write_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "WRITE" in log_delivery_permissions:
                write_grantees.append("uri=http://acs.amazonaws.com/groups/s3/LogDelivery")
            if "WRITE" in all_users_permissions:
                write_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            write_param = ", ".join(write_grantees) if write_grantees else ""

            read_acp_grantees = []
            if "READ_ACP" in canonical_user_permissions:
                read_acp_grantees.append(f"id={id_canonical_user}")
            if "READ_ACP" in authenticated_users_permissions:
                read_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "READ_ACP" in log_delivery_permissions:
                read_acp_grantees.append("uri=http://acs.amazonaws.com/groups/s3/LogDelivery")
            if "READ_ACP" in all_users_permissions:
                read_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            read_acp_param = ", ".join(read_acp_grantees) if read_acp_grantees else ""

            write_acp_grantees = []
            if "WRITE_ACP" in canonical_user_permissions:
                write_acp_grantees.append(f"id={id_canonical_user}")
            if "WRITE_ACP" in authenticated_users_permissions:
                write_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers")
            if "WRITE_ACP" in log_delivery_permissions:
                write_acp_grantees.append("uri=http://acs.amazonaws.com/groups/s3/LogDelivery")
            if "WRITE_ACP" in all_users_permissions:
                write_acp_grantees.append("uri=http://acs.amazonaws.com/groups/global/AllUsers")
            write_acp_param = ", ".join(write_acp_grantees) if write_acp_grantees else ""

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Configurando as permissões dos grupos de destinatários da ACL sobre os objetos do bucket {bucket_name} conforme definidas nas variáveis")
            grant_params = {}
            if full_control_param:
                grant_params['GrantFullControl'] = full_control_param
            if read_param:
                grant_params['GrantRead'] = read_param
            if write_param:
                grant_params['GrantWrite'] = write_param
            if read_acp_param:
                grant_params['GrantReadACP'] = read_acp_param
            if write_acp_param:
                grant_params['GrantWriteACP'] = write_acp_param

            s3_client.put_bucket_acl(Bucket=bucket_name, **grant_params)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões dos grupos de destinatários da ACL sobre os objetos do bucket {bucket_name}")
            acl_response = s3_client.get_bucket_acl(Bucket=bucket_name)
            for grant in acl_response['Grants']:
                print(f"Grantee: {grant['Grantee']['Type']}, URI: {grant['Grantee'].get('URI', 'N/A')}, Permissions: {grant['Permission']}")
    else:
        print(f"Não existe o bucket {bucket_name}")
else:
    print("Código não executado")