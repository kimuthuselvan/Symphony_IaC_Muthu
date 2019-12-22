#!/usr/local/bin/python3.8

import ruamel.yaml
import os
import argparse
import sys


# Usage Help
#yaml2tfvars.py --buildfile xyz.yaml --templatefile xyz.TEMPLATE ==> Build for configuration (nothing but preparing the directory structure and terraform variable files)

parser = argparse.ArgumentParser(description='This is a aws account validator script.')
parser.add_argument('--buildfile', help='Build configuration for the given yaml file')
parser.add_argument('--templatefile', help='Template file creation for the given template file')
parser.add_argument('--load',help='Load the Yaml file')

# Check if the given directory is already exist in the given path, if it is not exist create it.
def createDirectory(path):
    try:
        if(os.path.exists(path)):
            pass
        else:
            os.mkdir(path)
    except OSError:
        print ("Creation of the directory %s failed" % path)

# Return the count of elements in the list
def getElementCount(element):
    count = 0
    if isinstance(element, list):
        count += len(element) 
    return count    

# Create a new file and write the config text in it.
def createNewFile(file_path):
    file_object = open(file_path, 'w+')
    return file_object

# Create aws profile file.
def createAwsProfile(new_template_file, template_file, region_name, resource_name):
    with open(template_file, "rt") as fin:
        with open(new_template_file, "wt") as fout:
            for line in fin:
                line = line.replace('$REGION_NAME', region_name)
                line = line.replace('$VPC_NAME', resource_name)
                fout.write(line)				
    fin.close()
    fout.close()
	
# Create Build for configuration.
def createBuildFile(yaml_file, template_file):
    # Load the yaml file data into dictionary
    aws_accounts = ruamel.yaml.round_trip_load(open(yaml_file), preserve_quotes=True)
    try:  
        #baseDirPath = os.environ["WORKSPACE"]
        baseDirPath = 'E:\Muthu'
    except KeyError: 
        print("Please set the environment variable WORKSPACE")
        sys.exit(1)
    createDirectory(baseDirPath)
    count = getElementCount(aws_accounts['Region'])
    buildCount = 0
	# Region node trace
    for i in range(count):
        regionName = aws_accounts['Region'][i]['Name']
        regionPath = baseDirPath + '/' + regionName
        createDirectory(regionPath)
        count = getElementCount(aws_accounts['Region'][i]['VPC'])
		# VPC node trace
        for j in range(count):
            vpcName = aws_accounts['Region'][i]['VPC'][j]['Name']
            vpcPath = regionPath + '/' + vpcName
            vpcConfigPath = vpcPath + '/' + "vpc.tfvars"
            vpcAwsProfilePath = vpcPath + '/' + "aws_profile"
            if(aws_accounts['Region'][i]['VPC'][j]['Deploy'] == True):
                try:            
                    createDirectory(vpcPath)
                    fileObject1 = createNewFile(vpcConfigPath)
                    fileObject1.write('region_name = "' + regionName + '"\n')
                    fileObject1.write('vpc_name = "' + vpcName + '"\n')
                    fileObject1.write('vpc_cidr = "' + str(aws_accounts['Region'][i]['VPC'][j]['CIDR']) + '"\n\n')
                    fileObject1.write('tag_name = "' + vpcName + '"\n')
                    fileObject1.write('tag_project = "Symphony"\n')
                    fileObject1.write('tag_organization = "Advantasure Inc."\n')
                    fileObject1.write('tag_clietn = "AHS"\n\n')
                    fileObject1.write('tfstate_backend = "' + 'symphony-ahs-backend-tfstate-' + regionName + '"\n')
                    fileObject1.write('tfstate_path = "' + 'tfstate/Networking/' + vpcName + '/vpc.tfvars' + '"\n')                
                    fileObject1.close()
                    createAwsProfile(vpcAwsProfilePath, template_file, regionName, vpcName)
                    print("INFO: Generating VPC: " + vpcName + " configuration ... Done")
                    print(vpcConfigPath)
                    buildCount += 1
                except:
                    print("ERROR: Generating VPC: " + vpcName + " configuration ... Failed")
                aws_accounts['Region'][i]['VPC'][j]['Deploy'] = False
                count = getElementCount(aws_accounts['Region'][i]['VPC'][j]['Subnet'])
				# Subnet node trace
                for k in range(count):
                    subnetName = aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Name']
                    subnetPath = vpcPath + '/' + subnetName
                    subnetConfigPath = subnetPath + '/' + "subnet.tfvars"
                    subnetAwsProfilePath = subnetPath + '/' + "aws_profile"
                    if(str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Deploy']).casefold() == str(True).casefold()):
                        try:
                            createDirectory(subnetPath)
                            fileObject3 = createNewFile(subnetConfigPath)
                            fileObject3.write('region_name = "' + regionName + '"\n')
                            fileObject3.write('vpc_name = "' + vpcName + '"\n')
                            fileObject3.write('subnet_name = "' + subnetName + '"\n')
                            fileObject3.write('subnet_cidr = "' + str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['CIDR']) + '"\n\n')
                            fileObject3.write('tag_name = "' + subnetName + '"\n')
                            fileObject3.write('tag_project = "Symphony"\n')
                            fileObject3.write('tag_organization = "Advantasure Inc."\n')
                            fileObject3.write('tag_clietn = "AHS"\n\n')
                            fileObject3.write('tfstate_backend = "' + 'symphony-ahs-backend-tfstate-' + regionName + '"\n')
                            fileObject3.write('tfstate_path = "' + 'tfstate/Networking/' + vpcName + '/' + subnetName + '/subnet.tfvars' + '"\n')
                            fileObject3.close()
                            createAwsProfile(subnetAwsProfilePath, template_file, regionName, subnetName)
                            print("INFO: Generating Subnet: " + subnetName + " configuration ... Done")
                            print(subnetConfigPath)
                        except:
                            print("ERROR: Generating Subnet: " + subnetName + " configuration ... Failed")
                        aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Deploy'] = False
                        
    if(buildCount == 0):
        print('Build configurations are in "false" status')
    return aws_accounts								

#Update the Build flag in the Original Yaml file
def updateYamlFile(aws_updated, file_path):
    with open(file_path, 'w') as yaml_file:
        ruamel.yaml.round_trip_dump(aws_updated, yaml_file)

# Execution starts from here.
def main():
    args = parser.parse_args()
    if(args.buildfile and args.templatefile):
        #Build for configuration (Preparing the directory structure and terraform variable files) 
        buildfile = args.buildfile
        templatefile = args.templatefile
        try:
            aws_updated = createBuildFile(buildfile, templatefile)
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