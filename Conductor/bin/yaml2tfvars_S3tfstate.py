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
def createAwsProfileFile(profile, template_file, s3Path, region_name, resource_name):
    for template in template_file:
        if profile in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path = s3Path + '/' + output_template_file
            print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$S3BUCKET_NAME', resource_name)
                        fout.write(line)                    
            break
    fin.close()
    fout.close()

def createAwsS3TemplateFile(resource, template_file, s3Path, region_name, resource_name):
    for template in template_file:
        if resource in template:
            output_template_file = os.path.splitext(os.path.basename(template))[0]
            output_template_path =  s3Path + '/' + output_template_file
            print(output_template_path)
            with open(template, "rt") as fin:
                with open(output_template_path, "wt") as fout:
                    for line in fin:
                        line = line.replace('$REGION_NAME', region_name)
                        line = line.replace('$S3BUCKET_NAME', resource_name)
                        #line = line.replace('$VPC_CIDR', cidr)
                        fout.write(line)                    
            break
    fin.close()
    fout.close()


# Create Build for configuration.
def createBuildFile(yaml_file, template_file, output_folder):
    # Load the yaml file data into dictionary
    aws_accounts = ruamel.yaml.round_trip_load(open(yaml_file), preserve_quotes=True)
    print("filename=",os.path.basename(yaml_file).split(".")[0])
    filenamearr = os.path.basename(yaml_file).split("_")
    project = filenamearr[0]
    client = filenamearr[1]
    provider = filenamearr[2]
    service = filenamearr[3]
    resource_type = filenamearr[4]
    print("after split filename=",yaml_file.split("_"))
    try:  
        baseDirPath = os.environ["WORKSPACE"]
        #baseDirPath = 'E:\Muthu'
    except KeyError: 
        print("Please set the environment variable WORKSPACE")
        sys.exit(1)
    createDirectory(output_folder)
    prj_path = output_folder + '/' + project
    createDirectory(prj_path)
    clint_path = prj_path + '/' + client
    createDirectory(clint_path)
    provider_path = clint_path + '/' + provider
    createDirectory(provider_path)
    count = getElementCount(aws_accounts['Region'])
    buildCount = 0
    # Region node trace
    for i in range(count):
        regionName = aws_accounts['Region'][i]['Name']
        regionPath = provider_path + '/' + regionName
        createDirectory(regionPath)
        service_path = regionPath + '/' + service
        resource_type_path = service_path +  '/' + resource_type
        count = getElementCount(aws_accounts['Region'][i]['S3tfstate'])
     # S3tfstate node trace
        for j in range(count):
            resource = 's3'
            profile = 'profile'
            s3Name = aws_accounts['Region'][i]['S3tfstate'][j]['Name']
            s3Name = s3Name.replace("{Region.Name}", regionName)
            s3Path = resource_type_path + '/' + s3Name
            if(str(aws_accounts['Region'][i]['S3tfstate'][j]['Deploy']).casefold() == str(True).casefold() and str(aws_accounts['Region'][i]['S3tfstate'][j]['Terraform']).lower() == "Deploy".lower()):
                try:            
                    createDirectory(s3Path)
                    createAwsProfileFile(profile, template_file, s3Path, regionName, s3Name)
                    createAwsS3TemplateFile(resource, template_file, s3Path, regionName, s3Name)
                    print("INFO: Generating S3: " + s3Name + " configuration ... Done")
                    buildCount += 1
                except:
                    print("ERROR: Generating S3: " + s3Name + " configuration ... Failed")
                aws_accounts['Region'][i]['S3tfstate'][j]['Deploy'] = False
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