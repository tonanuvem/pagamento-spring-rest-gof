# https://docs.aws.amazon.com/pt_br/elasticbeanstalk/latest/dg/iam-servicerole.html
sh config_credenciais.sh
echo ""
echo " Configurando ..."
docker run -ti --rm --name awscli -v $PWD/files/:/root/.aws -v $PWD/iam/:/fiap --entrypoint /bin/sh -d tonanuvem/kubectl-aws-cli
#docker run -ti --rm --name kubectl -v $PWD/files/:/root/.aws --entrypoint /bin/sh -d tonanuvem/kubectl-aws-cli

EXEC="docker exec -ti awscli"

docker exec -ti awscli aws sts get-caller-identity
echo ""

# antes de iniciar, deve ser criada pela console a função "eksFiapClusterRole" e inserir as políticas "AWSElasticBeanstalkWebTier" "AWSElasticBeanstalkMulticontainerDocker" "AWSElasticBeanstalkWorkerTier"
docker exec -ti awscli aws iam create-role --role-name elasticbeanFiapRole --assume-role-policy-document file://elasticbeanRole.json
docker exec -ti awscli aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier --role-name elasticbeanFiapRole
docker exec -ti awscli aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker --role-name elasticbeanFiapRole
docker exec -ti awscli aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier --role-name elasticbeanFiapRole
#docker exec -ti awscli aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkEnhancedHealth --role-name elasticbeanFiapRole
docker exec -ti awscli aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy --role-name elasticbeanFiapRole

#aws iam get-role --role-name elasticbeanFiapRole

echo "Digite seu Primeiro Nome:" && read NOME
echo "Digite seu Ultimo Sobrenome:" && read SOBRENOME

aws elasticbeanstalk check-dns-availability --cname-prefix $NOME$SOBRENOME

eb create pagamento-env --service-role elasticbeanFiapRole -c $NOME$SOBRENOME


#docker exec -ti awscli /bin/sh 
docker stop awscli
