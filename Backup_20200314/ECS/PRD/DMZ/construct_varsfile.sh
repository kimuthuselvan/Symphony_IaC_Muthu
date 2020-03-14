#!/usr/bin/sh

######
task_def_location="task-definitions/"
template_varfile="terraform.tfvars_template"
actual_varfile="terraform.tfvars"
temp_file=$(mktemp)
######

count=0
for condition_def in `ls task-definitions/*.condition`
do
  if [ $(grep listener_rule $condition_def | grep default|wc -l) -ge 1 ]
  then
    last_file="$condition_def"
  else
    echo "  {" >> ${temp_file}
    cat $condition_def | sed 's/^/    /g' >> ${temp_file}
    echo "  }," >> ${temp_file}
  fi
  count=$(expr ${count} + 1)
done
echo "  {" >> ${temp_file}
cat $last_file | sed 's/^/    /g' >> ${temp_file}
echo "  }" >> ${temp_file}

cat ${temp_file}
sed "/container_def/r ${temp_file}" ${template_varfile} > ${actual_varfile}
sed -i "/container_def/i container_default_task = $(expr ${count} - 1)" ${actual_varfile}
rm -f ${temp_file}
