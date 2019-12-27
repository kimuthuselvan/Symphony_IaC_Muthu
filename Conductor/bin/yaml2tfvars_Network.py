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
parser.add_argument('--outputfolder', help='Destination folder for the given template file')
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
def createAwsProfileFile(profile, template_file, vpcPath, region_name, resource_name):
    for template in template_file:
        if profile in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path = vpcPath + '/' + output_template_file
            #print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$VPC_NAME', resource_name)
                        fout.write(line)
            break
    fin.close()
    fout.close()
    return output_template_path

def createAwsVpcTemplateFile(resource, template_file, vpcPath, region_name, resource_name, cidr):
    for template in template_file:
        if resource in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path = vpcPath + '/' + output_template_file
           # print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$VPC_NAME', resource_name)
                        line = line.replace('$VPC_CIDR', cidr)
                        fout.write(line)
            break
    fin.close()
    fout.close()
    return output_template_path

def createAwsSubnetTemplateFile(resource, template_file, subnetPath, region_name, vpc_name, subnet_name, cidr, subnet_az):
    for template in template_file:
        if resource in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path = subnetPath + '/' + output_template_file
           # print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$VPC_NAME', vpc_name)
                        line = line.replace('$SUBNET_NAME', subnet_name)
                        line = line.replace('$SUBNET_CIDR', cidr)
                        line = line.replace('$SUBNET_AZ', subnet_az)
                        fout.write(line)
            break
    fin.close()
    fout.close()
    return output_template_path
	
# Create Build for configuration.
def createBuildFile(yaml_file, template_file, output_folder):
    # Load the yaml file data into dictionary
    aws_accounts = ruamel.yaml.round_trip_load(open(yaml_file), preserve_quotes=True)
    print("INFO:filename=",os.path.basename(yaml_file).split(".")[0])
    filenamewithoutext = os.path.basename(yaml_file).split(".")[0]
    filenamearr = filenamewithoutext.split("_")
    project = filenamearr[0]
    client = filenamearr[1]
    provider = filenamearr[2]
    service = filenamearr[3]
    resource_type = filenamearr[4]
    try:  
        baseDirPath = os.environ["WORKSPACE"]
        #baseDirPath = 'E:\Muthu'
    except KeyError: 
        print("Please set the environment variable WORKSPACE")
        sys.exit(1)
    createDirectory(output_folder)
    count = getElementCount(aws_accounts['Region'])
    buildCount = 0
	# Region node trace
    for i in range(count):
        regionName = aws_accounts['Region'][i]['Name']
        regionPath = output_folder + '/' + regionName
        createDirectory(regionPath)
        service_path = regionPath + '/' + service
        createDirectory(service_path)
        resource_type_path = service_path +  '/' + resource_type
        createDirectory(resource_type_path)
        count = getElementCount(aws_accounts['Region'][i]['VPC'])
		# VPC node trace
        for j in range(count):
            resource = 'vpc'
            profile = 'profile'
            vpcName = aws_accounts['Region'][i]['VPC'][j]['Name']
            vpcPath = regionPath + '/' + vpcName
            vpc_cidr = str(aws_accounts['Region'][i]['VPC'][j]['CIDR'])
            if(str(aws_accounts['Region'][i]['VPC'][j]['Deploy']).casefold() == str(True).casefold() and str(aws_accounts['Region'][i]['VPC'][j]['Terraform']).lower() == "Deploy".lower()):
                try:            
                    createDirectory(vpcPath)
                    awsprofilepath = createAwsProfileFile(profile, template_file, vpcPath, regionName, vpcName)
                    vpcprofilepath = createAwsVpcTemplateFile(resource, template_file, vpcPath, regionName, vpcName, vpc_cidr)
                    if(awsprofilepath !="" and vpcprofilepath !=""):
                       print("INFO: Generating VPC: " + vpcName + " configuration ... Done")
                       buildCount += 1
                       print(awsprofilepath)
                       print(vpcprofilepath)                    
                except:
                    print("ERROR: Generating VPC: " + vpcName + " configuration ... Failed")
                aws_accounts['Region'][i]['VPC'][j]['Deploy'] = False
                count = getElementCount(aws_accounts['Region'][i]['VPC'][j]['Subnet'])
				# Subnet node trace
                for k in range(count):
                    resource = 'subnet'
                    subnetName = aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Name']
                    subnetPath = vpcPath + '/' + subnetName
                    subnet_cidr = str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['CIDR'])
                    subnet_az = str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['AvailabilityZone'])
                    subnet_az = subnet_az.replace('({{Region.Name}}', regionName)
                    subnet_az = subnet_az.replace(')', '')
                    if(str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Deploy']).casefold() == str(True).casefold() and str(aws_accounts['Region'][i]['VPC'][j]['Subnet'][k]['Terraform']).lower() == "Deploy".lower()):
                        try:
                            createDirectory(subnetPath)
                            awsprofilepath = createAwsProfileFile(profile, template_file, subnetPath, regionName, subnetName)
                            subnetprofilepath = createAwsSubnetTemplateFile(resource, template_file, subnetPath, regionName, vpcName, subnetName, subnet_cidr, subnet_az)
                            if(awsprofilepath !="" and vpcprofilepath !=""):
                               print("INFO: Generating Subnet: " + subnetName + " configuration ... Done")
                               print(awsprofilepath)
                               print(subnetprofilepath)
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
