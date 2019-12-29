#!/usr/local/bin/python3.8

import ruamel.yaml
from string import Template
import os
import argparse
import sys

# Usage Help
#yaml2tfvars.py --buildfile xyz.yaml --templatefile xyz.TEMPLATE ==> Build for configuration (nothing but preparing the directory structure and terraform variable files)

parser = argparse.ArgumentParser(description='This is a aws account validator script.')
parser.add_argument('--yamlfile', help='Build configuration for the given yaml file')
parser.add_argument('--templatefile', help='Template file creation for the given template file')
parser.add_argument('--outputfolder', help='Destination folder for the given template file')
parser.add_argument('--load',help='Load the Yaml file')

# Return the count of elements in the list
def getElementCount(element):
    count = 0
    if isinstance(element, list):
        count += len(element) 
    return count  
# Check if the given directory is already exist in the given path, if it is not exist create it.
def createDirectory(path):
    try:
        if(os.path.exists(path)):
            pass
        else:
            os.mkdir(path)
    except OSError:
        print ("Creation of the directory %s failed" % path)
def createBuildFile(yaml_file, templatefiles, output_folder):
    #yaml_file = "Symphony_AHS_AWS_Network_Network.yaml"
    aws_accounts = ruamel.yaml.round_trip_load(open(yaml_file), preserve_quotes=True)
    count = getElementCount(aws_accounts['Region'])
    #templatefiles = ['aws_vpc.tfvars.TEMPLATE','aws_subnet.tfvars.TEMPLATE']
    output_template_path = ""
    #output_folder = "tmp"
    filenamewithoutext = os.path.basename(yaml_file).split(".")[0]
    filenamearr = filenamewithoutext.split("_")
    project = filenamearr[0]
    client = filenamearr[1]
    provider = filenamearr[2]
    service = filenamearr[3]
    resource_type = filenamearr[4]
    createDirectory(output_folder)
    reg_keys = {}
    buildCount = 0
    for i in range(count):
        regionPath = output_folder + '/' + aws_accounts['Region'][i]['Name']
        createDirectory(regionPath) 
        service_path = regionPath + '/' + service
        createDirectory(service_path)
        resource_type_path = service_path +  '/' + resource_type
        createDirectory(resource_type_path)
        for reg_elm in aws_accounts['Region'][i]:
            if(reg_elm.lower() != "vpc"):
                region_keys = "\'REGION_"+reg_elm.upper()+"\':\'"+ str(aws_accounts['Region'][i][reg_elm])+"\',"
                reg_keys["REGION_"+reg_elm.upper()] =  str(aws_accounts['Region'][i][reg_elm])
        count = getElementCount(aws_accounts['Region'][i]['VPC'])
    		# VPC node trace
        for j in range(count):
            vpc_keys ={}
            vpcName = str(aws_accounts['Region'][i]['VPC'][j]['Name'])
            vpc_dirPath = resource_type_path +"/"+ vpcName
            if(str(aws_accounts['Region'][i]['VPC'][j]['Deploy']).casefold() == str(True).casefold() and str(aws_accounts['Region'][i]['VPC'][j]['Terraform']).lower() == "Deploy".lower()):
                try:
                    buildCount += 1
                    createDirectory(vpc_dirPath)
                    for vpc_elem in aws_accounts['Region'][i]['VPC'][j]:
                        if(vpc_elem.lower() != "subnet"):
                            #vpc_keys1 = '\"VPC_'+vpc_elem.upper()+"\":\""+ str(aws_accounts['Region'][i]['VPC'][j][vpc_elem])+"\","
                            vpc_keys["VPC_"+vpc_elem.upper()] =  str(aws_accounts['Region'][i]['VPC'][j][vpc_elem])
                    vpc_filenames = []
                    for tmp_file in templatefiles:
                        with open(tmp_file, "rt") as fin:
                            src = fin.read()
                            src = Template(src).safe_substitute(vpc_keys)
                            src = Template(src).safe_substitute(reg_keys)
                            output_template_path = os.path.splitext(os.path.basename(tmp_file))[0]
                            vpc_template_path = vpc_dirPath +"/"+ output_template_path
                            #print("filename vpc==",vpc_template_path)
                            with open(vpc_template_path, "wt") as fout:
                                fout.write(src)
                            fout.close()
                            vpc_filenames.append(vpc_template_path)
                        fin.close()
                    print("\nINFO: Generating VPC: " + vpcName + " configuration ... Done")
                    for filename in vpc_filenames:
                        print(filename)
                except:
                    print("ERROR: Generating VPC: " + vpcName + " configuration ... Failed")
                aws_accounts['Region'][i]['VPC'][j]['Deploy'] = False
    					#tfvar
            else:
                createDirectory(vpc_dirPath)
                for vpc_elem in aws_accounts['Region'][i]['VPC'][j]:
                    if(vpc_elem.lower().strip() == "name"):
                        vpc_keys["VPC_"+vpc_elem.upper()] =  str(aws_accounts['Region'][i]['VPC'][j][vpc_elem])
            count = getElementCount(aws_accounts['Region'][i]['VPC'][j]['Subnet'])
    				# Subnet node trace
            for k in range(count):
                subnet_keys = {}
                subnetName =  str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Name'])
                sub_dirPath = vpc_dirPath +"/"+ subnetName
                if(str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Deploy']).casefold() == str(True).casefold() and str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Terraform']).lower() == "Deploy".lower()):
                    try:
                        createDirectory(sub_dirPath)
                        for sub_elem in  aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]:
                            subnet_keys["SUBNET_"+sub_elem.upper()] =  str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k][sub_elem])

                        sub_filenames = []
                        for tmp_file in templatefiles:
                            with open(tmp_file, "rt") as fin:
                                src = fin.read()
                                src = Template(src).safe_substitute(vpc_keys)
                                src = Template(src).safe_substitute(reg_keys)
                                src = Template(src).safe_substitute(subnet_keys)
                                output_template_path = os.path.splitext(os.path.basename(tmp_file))[0]
                                subnet_template_path = sub_dirPath +"/"+ output_template_path
                                with open(subnet_template_path, "wt") as fout:
                                    fout.write(src)
                                fout.close()
                                sub_filenames.append(subnet_template_path)
                            fin.close()
                        
                        print("\nINFO: Generating Subnet: " + subnetName + " configuration ... Done")
                        for filename in sub_filenames:
                            print(filename)
                        
                    except:
                        print("ERROR: Generating Subnet: " + subnetName + " configuration ... Failed")
                    aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Deploy'] = False
    if(buildCount == 0):
        print('INFO:Build configurations are in "false" status')
    return aws_accounts
#Update the Build flag in the Original Yaml file
def updateYamlFile(aws_updated, file_path):
    with open(file_path, 'w') as yaml_file:
        ruamel.yaml.round_trip_dump(aws_updated, yaml_file)

# Execution starts from here.
def main():
    args = parser.parse_args()
    if(args.yamlfile and args.templatefile):
        #Build for configuration (Preparing the directory structure and terraform variable files) 
        buildfile = args.yamlfile
        template_file = args.templatefile.split(',')
        output_folder = args.outputfolder
        try:
            aws_updated = createBuildFile(buildfile, template_file, output_folder)
            updateYamlFile(aws_updated, buildfile)
        except IOError as e:
            print("I/O error({0}): {1}".format(e.errno, e.strerror))
        except:
            print("Unexpected error:", sys.exc_info()[0])
    elif(args.load):
        file = open(args.load, "r")
        if file.mode == "r":
            contents = file.read()
            print(contents)
    else:
        print("Please give the proper input parameter")
        parser.print_usage()
        print()

if __name__== "__main__":
    main()
