#!/usr/bin/env python

import base64
import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("LAUNCH TEMPLATE CREATION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
launch_temp_name = "launchTempTest1"
version_description = "My version 1"
ami_id = "ami-0c7217cdde317cfec"
instance_type = "t2.micro"
key_pair = "keyPairUniversal"
user_data_path = "G:/Meu Drive/4_PROJ/scripts/scripts_model/.default/aws/ec2_userData/httpd_stress"
user_data_file = "udFile.sh"
sg_name = "default"
instance_profile_name = "instanceProfileTest"
cluster_name = "clusterEC2Test1"

print("-----//-----//-----//-----//-----//-----//-----")
response = input("Deseja executar o código? (y/n) ")
if response.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o modelo de implantação de nome {launch_temp_name}")
    launch_templates = ec2_client.describe_launch_templates(
        Filters=[{'Name': 'launch-template-name', 'Values': [launch_temp_name]}]
    )['LaunchTemplates']

    if launch_templates:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Já existe o modelo de implantação de nome {launch_temp_name}")
        print(launch_templates[0]['LaunchTemplateName'])

        print("-----//-----//-----//-----//-----//-----//-----")
        response = input("Quer implementar uma nova versão? (y/n) ")
        if response.lower() == 'y':
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo a última versão do modelo de implantação de nome {launch_temp_name}")
            latest_version = int(launch_templates[0]['DefaultVersionNumber']) + 1
            version_number = str(latest_version)

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as versões do modelo de implantação de nome {launch_temp_name}")
            launch_template_versions = ec2_client.describe_launch_template_versions(
                LaunchTemplateName=launch_temp_name
            )['LaunchTemplateVersions']

            for version in launch_template_versions:
                print(f"{version['LaunchTemplateName']} {version['VersionNumber']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print("Extraindo o ID do security group")
            sg_id = ec2_client.describe_security_groups(GroupNames=[sg_name])['SecurityGroups'][0]['GroupId']

            # print("-----//-----//-----//-----//-----//-----//-----")
            # print("Extraindo a ARN do instance profile")
            # instance_profile_arn = boto3.client('iam').list_instance_profiles(InstanceProfileName=instance_profile_name)['InstanceProfiles'][0]['Arn']

            # print("-----//-----//-----//-----//-----//-----//-----")
            # print("Codificando o arquivo user data em Base64")
            # ud_file = "#!/bin/bash\necho ECS_CLUSTER={} >> /etc/ecs/ecs.config".format(cluster_name)
            # ud_file_base64 = base64.b64encode(ud_file.encode('utf-8')).decode('utf-8')


            print("-----//-----//-----//-----//-----//-----//-----")
            print("Codificando o arquivo user data em Base64")
            with open(f"{user_data_path}/{user_data_file}", 'rb') as file:
                ud_file_base64 = base64.b64encode(file.read()).decode('utf-8')

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Criando o launch template (modelo de implantação) de nome {launch_temp_name} na versão {version_number}")
            ec2_client.create_launch_template_version(
                LaunchTemplateName=launch_temp_name,
                VersionDescription=version_description,
                LaunchTemplateData={
                    "ImageId": ami_id,
                    "InstanceType": instance_type,
                    "KeyName": key_pair,
                    "UserData": ud_file_base64,
                    "SecurityGroupIds": [sg_id],
                    # "IamInstanceProfile": {
                    #     "Arn": instance_profile_arn
                    # },
                    "BlockDeviceMappings": [
                        {
                            "DeviceName": "/dev/xvda",
                            "Ebs": {
                                "VolumeSize": 8,
                                "VolumeType": "gp2"
                            }
                        }
                    ]
                }
            )

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando o modelo de implantação de nome {launch_temp_name} na versão {version_number}")
            launch_template_versions = ec2_client.describe_launch_template_versions(
                LaunchTemplateName=launch_temp_name
            )['LaunchTemplateVersions']

            latest_version = max(
                launch_template_versions,
                key=lambda x: int(x['VersionNumber'])
            )

            print(f"{latest_version['LaunchTemplateName']} {latest_version['VersionNumber']}")
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Definindo a versão como primeira do modelo de implantação de nome {launch_temp_name}")
        version_number = '1'

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os modelos de implantação existentes")
        launch_templates = ec2_client.describe_launch_templates()['LaunchTemplates']
        
        for template in launch_templates:
            print(f"{template['LaunchTemplateName']} {template['DefaultVersionNumber']}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Extraindo o ID do security group")
        sg_id = ec2_client.describe_security_groups(GroupNames=[sg_name])['SecurityGroups'][0]['GroupId']

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print("Extraindo a ARN do instance profile")
        # instance_profile_arn = boto3.client('iam').list_instance_profiles(InstanceProfileName=instance_profile_name)['InstanceProfiles'][0]['Arn']

        # print("-----//-----//-----//-----//-----//-----//-----")
        # print("Codificando o arquivo user data em Base64")
        # ud_file = "#!/bin/bash\necho ECS_CLUSTER={} >> /etc/ecs/ecs.config".format(cluster_name)
        # ud_file_base64 = base64.b64encode(ud_file.encode('utf-8')).decode('utf-8')

        print("-----//-----//-----//-----//-----//-----//-----")
        print("Codificando o arquivo user data em Base64")
        with open(f"{user_data_path}/{user_data_file}", 'rb') as file:
            ud_file_base64 = base64.b64encode(file.read()).decode('utf-8')

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o launch template (modelo de implantação) de nome {launch_temp_name} na versão {version_number}")
        ec2_client.create_launch_template(
            LaunchTemplateName=launch_temp_name,
            VersionDescription=version_description,
            LaunchTemplateData={
                "ImageId": ami_id,
                "InstanceType": instance_type,
                "KeyName": key_pair,
                "UserData": ud_file_base64,
                "SecurityGroupIds": [sg_id],
                # "IamInstanceProfile": {
                #     "Arn": instance_profile_arn
                # },
                "BlockDeviceMappings": [
                    {
                        "DeviceName": "/dev/xvda",
                        "Ebs": {
                            "VolumeSize": 8,
                            "VolumeType": "gp2"
                        }
                    }
                ]
            }
        )

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o modelo de implantação de nome {launch_temp_name} na versão {version_number}")
        launch_templates = ec2_client.describe_launch_templates(
            Filters=[{'Name': 'launch-template-name', 'Values': [launch_temp_name]}]
        )['LaunchTemplates']

        for template in launch_templates:
            print(f"{template['LaunchTemplateName']} - {template['DefaultVersionNumber']}")
else:
    print("Código não executado")




#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS EC2")
print("LAUNCH TEMPLATE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
launch_template_name = "launchTempTest1"
version_number = 1

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço EC2")
    ec2_client = boto3.client('ec2')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o modelo de implantação de nome {launch_template_name}")
    response = ec2_client.describe_launch_templates(
        Filters=[
            {
                'Name': 'launch-template-name',
                'Values': [launch_template_name]
            }
        ]
    )

    if len(response['LaunchTemplates']) > 0:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Listando todos os modelos de implantação existentes e sua versão padrão")
        response = ec2_client.describe_launch_templates()
        for template in response['LaunchTemplates']:
            print(f"{template['LaunchTemplateName']} - {template['DefaultVersionNumber']}")

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se existe o modelo de implantação de nome {launch_template_name} na versão {version_number}")
        response = ec2_client.describe_launch_template_versions(
            LaunchTemplateName=launch_template_name,
            Versions=[str(version_number)]
        )

        if len(response['LaunchTemplateVersions']) > 0:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as versões do modelo de implantação de nome {launch_template_name}")
            response = ec2_client.describe_launch_template_versions(
                LaunchTemplateName=launch_template_name
            )

            for template_version in response['LaunchTemplateVersions']:
                print(f"{template_version['LaunchTemplateName']} - {template_version['VersionNumber']}")

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Extraindo a versão padrão do modelo de implantação de nome {launch_template_name}")
            response = ec2_client.describe_launch_templates(
                Filters=[
                    {
                        'Name': 'launch-template-name',
                        'Values': [launch_template_name]
                    }
                ]
            )

            default_version = response['LaunchTemplates'][0]['DefaultVersionNumber']

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Verificando se a versão escolhida é a versão padrão do modelo de implantação de nome {launch_template_name}")
            if version_number == default_version:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo o modelo de implantação de nome {launch_template_name} por completo")
                ec2_client.delete_launch_template(LaunchTemplateName=launch_template_name)

                print("-----//-----//-----//-----//-----//-----//-----")
                print("Listando todos os modelos de implantação existentes")
                response = ec2_client.describe_launch_templates()
                for template in response['LaunchTemplates']:
                    print(f"{template['LaunchTemplateName']} - {template['DefaultVersionNumber']}")
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Removendo o modelo de implantação de nome {launch_template_name} na versão {version_number}")
                ec2_client.delete_launch_template_versions(
                    LaunchTemplateName=launch_template_name,
                    Versions=[str(version_number)]
                )

                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando todas as versões do modelo de implantação de nome {launch_template_name}")
                response = ec2_client.describe_launch_template_versions(
                    LaunchTemplateName=launch_template_name
                )
                for template_version in response['LaunchTemplateVersions']:
                    print(f"{template_version['LaunchTemplateName']} - {template_version['VersionNumber']}")
        else:
            print(f"Não existe o modelo de implantação de nome {launch_template_name} na versão {version_number}")
    else:
        print(f"Não existe o modelo de implantação de nome {launch_template_name}")
else:
    print("Código não executado")