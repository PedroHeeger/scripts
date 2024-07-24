import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("ACL OBJECT CHANGE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
object_name = "objTest1.txt"

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
        print(f"Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")

        acl = s3.get_object_acl(Bucket=bucket_name, Key=object_name)
        grants = acl['Grants']
        public_read = any(
            grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers' and grant['Permission'] == 'READ'
            for grant in grants
        )

        if public_read:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já foi configurado as permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões que a entidade everyone da ACL possuí no objeto de nome {object_name}")
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Concedendo permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")
            s3.put_object_acl(Bucket=bucket_name, Key=object_name, ACL='public-read')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a configuração de permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")
            acl = s3.get_object_acl(Bucket=bucket_name, Key=object_name)
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
print("ACL OBJECT CHANGE DEFAULT")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
object_name = "objTest1.txt"

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
        print(f"Verificando se foi configurado as permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")

        acl = s3.get_object_acl(Bucket=bucket_name, Key=object_name)
        grants = acl['Grants']
        public_read = any(
            grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers' and grant['Permission'] == 'READ'
            for grant in grants
        )

        if public_read:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões que a entidade everyone da ACL possuí no objeto de nome {object_name}")
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Restringindo permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")
            s3.put_object_acl(Bucket=bucket_name, Key=object_name, ACL='private')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as permissões que a entidade everyone da ACL possuí no objeto de nome {object_name}")
            acl = s3.get_object_acl(Bucket=bucket_name, Key=object_name)
            grants = acl['Grants']
            permissions = [grant['Permission'] for grant in grants if grant['Grantee'].get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers']
            print(permissions)
        else:
            print(f"Não foi configurado permissões de leitura para entidade everyone da ACL sobre o objeto de nome {object_name} (Acesso Público)")
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")