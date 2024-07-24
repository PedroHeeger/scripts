import boto3
import os

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("OBJECT CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
object_name = "objTest.jpg"
file_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/python/aws/s3"
file_name = "objTest.jpg"
storage_class = "STANDARD"

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
        print(f"Verificando se existe o objeto de nome {object_name} no bucket {bucket_name}")
        objects = s3.list_objects(Bucket=bucket_name)
        object_keys = [obj['Key'] for obj in objects.get('Contents', [])]
        
        if object_name in object_keys:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Já existe o objeto de nome {object_name} no bucket {bucket_name}")
            print(object_name)
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a URL do objeto de nome {object_name}")
            print(f"https://{bucket_name}.s3.amazonaws.com/{object_name}")
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os objetos no bucket {bucket_name}")
            for obj in object_keys:
                print(obj)
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o objeto de nome {object_name} no bucket {bucket_name}")
            s3.put_object(
                Bucket=bucket_name,
                Key=object_name,
                Body=open(os.path.join(file_path, file_name), 'rb'),
                StorageClass=storage_class
            )
            
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o objeto de nome {object_name} no bucket {bucket_name}")
            objects = s3.list_objects(Bucket=bucket_name)
            object_keys = [obj['Key'] for obj in objects.get('Contents', [])]
            if object_name in object_keys:
                print(object_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a URL do objeto de nome {object_name}")
            print(f"https://{bucket_name}.s3.amazonaws.com/{object_name}")
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("OBJECT EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
object_name = "objTest.jpg"

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
        print(f"Verificando se existe o objeto de nome {object_name} no bucket {bucket_name}")
        objects = s3.list_objects(Bucket=bucket_name)
        object_keys = [obj['Key'] for obj in objects.get('Contents', [])]
        
        if object_name in object_keys:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os objetos no bucket {bucket_name}")
            for obj in object_keys:
                print(obj)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo o objeto de nome {object_name} no bucket {bucket_name}")
            s3.delete_object(Bucket=bucket_name, Key=object_name)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todos os objetos no bucket {bucket_name}")
            objects = s3.list_objects(Bucket=bucket_name)
            object_keys = [obj['Key'] for obj in objects.get('Contents', [])]
            for obj in object_keys:
                print(obj)
        else:
            print(f"Não existe o objeto de nome {object_name} no bucket {bucket_name}")
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")