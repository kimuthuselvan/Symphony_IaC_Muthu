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
def createAwsProfileFile(profile, template_file, output_folder, ec2Path, region_name, resource_name):
    for template in template_file:
        if profile in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path = output_folder + '/' + ec2Path + '/' + output_template_file
            print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$EC2_NAME', resource_name)
                        fout.write(line)
            break
    fin.close()
    fout.close()

def createAwsEC2TemplateFile(resource, template_file, output_folder, ec2Path, region_name, resource_name,amiid,instance_type,vpcname,subnetname):
    for template in template_file:
        if resource in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path = output_folder + '/' + ec2Path + '/' + output_template_file
            print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$EC2_NAME', resource_name)
                        line = line.replace('$AMI_ID', amiid)
                        line = line.replace('$INSTANCE_TYPE', instance_type)
                        line = line.replace('$KEYPAIR_NAME', resource_name)
                        line = line.replace('$VPC_NAME', vpcname)
                        line = line.replace('$SUBNET_NAME', subnetname)
                        fout.write(line)
            break
    fin.close()
    fout.close()


# Create Build for configuration.
def createBuildFile(yaml_file, template_file, output_folder):
    # Load the yaml file data into dictionary
    aws_accounts = ruamel.yaml.round_trip_load(open(yaml_file), preserve_quotes=True)
    try:  
        baseDirPath = os.environ["WORKSPACE"]
        #baseDirPath = 'E:\Muthu'
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
        count = getElementCount(aws_accounts['Region'][i]['EC2'])
     # EC2 node trace
        for j in range(count):
            resource = 'ec2'
            profile = 'profile'
            ec2Name = aws_accounts['Region'][i]['EC2'][j]['Name']
            ec2Path = regionPath + '/' + ec2Name
            if(str(aws_accounts['Region'][i]['EC2'][j]['Deploy']).casefold() == str(True).casefold()):
                try:            
                    createDirectory(ec2Path)
                    createAwsProfileFile(profile, template_file, output_folder, ec2Path, regionName, ec2Name)
                    amiid = str(aws_accounts['Region'][i]['EC2'][j]['AMIID'])
                    instance_type = str(aws_accounts['Region'][i]['EC2'][j]['InstanceType'])                    
                    vpcname = str(aws_accounts['Region'][i]['EC2'][j]['VPCName'])
                    subnetname = str(aws_accounts['Region'][i]['EC2'][j]['SubnetName'])
                    createAwsEC2TemplateFile(resource, template_file, output_folder, ec2Path, regionName, ec2Name, amiid, instance_type, vpcname, subnetname)
                    print("INFO: Generating EC2: " + ec2Name + " configuration ... Done")
                    buildCount += 1
                except:
                    print("ERROR: Generating EC2: " + ec2Name + " configuration ... Failed")
                aws_accounts['Region'][i]['EC2'][j]['Deploy'] = False
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