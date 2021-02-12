#!/bin/bash
#Author: Kicky


#Color schemas
Color_Off='\033[0m'       # Text Reset
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow

ARGS=`echo $#`
ISARGS=`echo $*`

if [[ $ARGS < 1 ]]; then
         echo "Usage: install [-i <input file>] [-x <xml-file>]"
         echo "   -i  | --infile      -  input file containing the details of network (space separated)"
         echo "   -x  | --xml         -  metadata xml file received from IT team"
         exit
fi
  
#fetch user preferences
while [ "$1" != "" ]; 
do
   case $1 in
    -i | --infile )
        shift
        if [[  "$1" != "" && "$1" != "-h" && "$1" != "-x" ]];
          then
            input_file="$1"
        else
           echo "Usage: install [-i <input file>] [-x <xml-file>]"
           echo -e $Yellow" input file missing after the -i argument"$Color_Off
           exit
        fi
        ;;
    -x | --xml )
        shift
        if [[  "$1" != "" && "$1" != "-h" && "$1" != "-i" ]];
          then
            xml_file="$1"
        else
           echo "Usage: install [-i <input file>] [-x <xml-file>]"
           echo -e $Yellow" input file missing after the -x argument"$Color_Off
           exit
        fi
        ;;
    -h | --help ) 
         echo "Usage: install [-i <input file>] [-x <xml-file>]"
         echo "   -i  | --infile      -  input file containing the details of network (space separated)"
         echo "   -x  | --xml         -  metadata xml file received from IT team"
         exit
      ;;
    * ) 
         echo "Invalid option: $1"
         echo "Usage: install [-i <input file>] [-x <xml-file>]"
         echo "   -i  | --infile      -  input file containing the details of network (space separated) "
         echo "   -x  | --xml         -  metadata xml file received from IT team"
        exit
       ;;
  esac
  shift
done

details=`cat $input_file`
read -r acc_name map_key vpc_id vpc_cidr eip pri1 pri2 pri3 pri4 pub1 pub2 pub3 pub4 <<<$(echo $details)

construct_tfvars()
{
  ./construct-tfvars.sh -f $1
}

modify_provider()
{
  ./modify-provider.sh $acc_name
}

construct_setup_command()
{
  ./construct_setup_command.sh $map_key
}

if [[ $ISARGS = *-i*-x* ]] || [[ $ISARGS = *-x*-i* ]]; then
  construct_tfvars $input_file 
  modify_provider
  command_text=`construct_setup_command` 
  pushd ../terraform > /dev/null
  rm -rf .terraform
  echo $command_text
  echo $xml_file
  terraform init || echo "terraform initialization failed"
  terraform plan -var "auth-command=$command_text" -var "saml-metadata=$xml_file" || echo "terraform plan failed"
  terraform apply -var "auth-command=$command_text" -var "saml-metadata=$xml_file" && cp provider.tf-orig provider.tf
else
  echo -e $Red"Manadataory arguments -f missing"$Color_Off
  exit 1
fi
