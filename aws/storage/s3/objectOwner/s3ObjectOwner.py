import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("OBJECT OWNERSHIP CHANGE")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
object_ownership = "BucketOwnerEnforced"  # O proprietário do bucket detém automaticamente a propriedade de todos os objetos, independentemente de quem os criou. Bloqueia todas as ACLs, e o bucket tem controle total sobre os objetos.
# object_ownership = "BucketOwnerPreferred"  # O proprietário do bucket se torna automaticamente o proprietário dos objetos, a menos que o objeto tenha uma ACL específica que defina outro proprietário.
# object_ownership = "ObjectWriter"          # O usuário que faz o upload do objeto é o proprietário, mantendo a propriedade dos objetos que eles próprios criaram.

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o códigon? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket {bucket_name}")
    s3_client = boto3.client('s3', region_name=region)
    buckets = s3_client.list_buckets()
    bucket_exists = any(bucket['Name'] == bucket_name for bucket in buckets['Buckets'])

    if bucket_exists:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se o controle de propriedade dos objetos do bucket {bucket_name} é {object_ownership}")
        ownership_controls = s3_client.get_bucket_ownership_controls(Bucket=bucket_name)
        current_ownership = ownership_controls['OwnershipControls']['Rules'][0]['ObjectOwnership']
        
        if current_ownership == object_ownership:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já foi configurado o proprietário dos objetos no bucket {bucket_name} para {object_ownership}")
            print(current_ownership)
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o proprietário dos objetos no bucket {bucket_name}")
            print(current_ownership)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Alterando o proprietário dos objetos no bucket {bucket_name} para {object_ownership}")
            s3_client.put_bucket_ownership_controls(
                Bucket=bucket_name,
                OwnershipControls={'Rules': [{'ObjectOwnership': object_ownership}]}
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            ownership_controls = s3_client.get_bucket_ownership_controls(Bucket=bucket_name)
            print("Novo proprietário dos objetos:", ownership_controls['OwnershipControls']['Rules'][0]['ObjectOwnership'])
    else:
        print(f"Não existe o bucket {bucket_name}")
else:
    print("Código não executado")