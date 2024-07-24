import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("ACL BUCKET CHANGE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket de nome {bucket_name}")
    s3 = boto3.client('s3', region_name=region)
    buckets = s3.list_buckets()
    bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
    if bucket_name in bucket_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name} (Acesso Público)")

        acl = s3.get_bucket_acl(Bucket=bucket_name)
        grants = acl['Grants']
        public_read = any(
            grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers' and grant['Permission'] == 'READ'
            for grant in grants
        )

        if public_read:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name} (Acesso Público)")
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões que a entidade everyone da ACL possuí no bucket de nome {bucket_name}")
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket de nome {bucket_name} é o BucketOwnerPreferred")
            ownership_controls = s3.get_bucket_ownership_controls(Bucket=bucket_name)
            rules = ownership_controls.get('OwnershipControls', {}).get('Rules', [])
            bucket_owner_preferred = any(
                rule.get('ObjectOwnership') == 'BucketOwnerPreferred'
                for rule in rules
            )

            if bucket_owner_preferred:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já foi configurado o proprietário dos objetos no bucket de nome {bucket_name} para BucketOwnerPreferred")
                ownerships = [rule.get('ObjectOwnership') for rule in rules]
                print(ownerships)
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o proprietário dos objetos no bucket de nome {bucket_name}")
                ownerships = [rule.get('ObjectOwnership') for rule in rules]
                print(ownerships)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Alterando o proprietário dos objetos no bucket de nome {bucket_name} para BucketOwnerPreferred")
                s3.put_bucket_ownership_controls(
                    Bucket=bucket_name,
                    OwnershipControls={
                        'Rules': [
                            {'ObjectOwnership': 'BucketOwnerPreferred'}
                        ]
                    }
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o proprietário dos objetos no bucket de nome {bucket_name}")
                ownership_controls = s3.get_bucket_ownership_controls(Bucket=bucket_name)
                rules = ownership_controls.get('OwnershipControls', {}).get('Rules', [])
                ownerships = [rule.get('ObjectOwnership') for rule in rules]
                print(ownerships)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Concedendo permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name}")
            s3.put_bucket_acl(Bucket=bucket_name, ACL='public-read')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a configuração de permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name} (Acesso Público)")
            acl = s3.get_bucket_acl(Bucket=bucket_name)
            grants = acl['Grants']
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("ACL BUCKET CHANGE DEFAULT")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket de nome {bucket_name}")
    s3 = boto3.client('s3', region_name=region)
    buckets = s3.list_buckets()
    bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
    if bucket_name in bucket_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name} (Acesso Público)")
        acl = s3.get_bucket_acl(Bucket=bucket_name)
        grants = acl['Grants']
        public_read = any(
            grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers' and grant['Permission'] == 'READ'
            for grant in grants
        )

        if public_read:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões que a entidade everyone da ACL possuí no bucket de nome {bucket_name}")
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Restringindo as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name}")
            s3.put_bucket_acl(Bucket=bucket_name, ACL='private')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se o controle de propriedade dos objetos (Object Ownership) do bucket de nome {bucket_name} é o BucketOwnerPreferred")
            ownership_controls = s3.get_bucket_ownership_controls(Bucket=bucket_name)
            rules = ownership_controls.get('OwnershipControls', {}).get('Rules', [])
            bucket_owner_preferred = any(
                rule.get('ObjectOwnership') == 'BucketOwnerPreferred'
                for rule in rules
            )

            if bucket_owner_preferred:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o proprietário dos objetos no bucket de nome {bucket_name}")
                ownerships = [rule.get('ObjectOwnership') for rule in rules]
                print(ownerships)

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Alterando o proprietário dos objetos no bucket de nome {bucket_name} para BucketOwnerEnforced")
                s3.put_bucket_ownership_controls(
                    Bucket=bucket_name,
                    OwnershipControls={
                        'Rules': [
                            {'ObjectOwnership': 'BucketOwnerEnforced'}
                        ]
                    }
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando o proprietário dos objetos no bucket de nome {bucket_name}")
                ownership_controls = s3.get_bucket_ownership_controls(Bucket=bucket_name)
                rules = ownership_controls.get('OwnershipControls', {}).get('Rules', [])
                ownerships = [rule.get('ObjectOwnership') for rule in rules]
                print(ownerships)
            else:
                print(f"Não foi configurado o proprietário dos objetos no bucket de nome {bucket_name} para BucketOwnerPreferred")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões que a entidade everyone da ACL possuí no bucket de nome {bucket_name}")
            acl = s3.get_bucket_acl(Bucket=bucket_name)
            grants = acl['Grants']
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)
        else:
            print(f"Não foi configurado as permissões de leitura para entidade everyone da ACL sobre os objetos do bucket de nome {bucket_name} (Acesso Público)")
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")