# funct_check_perms
#
# Code to check permissions on a file
# If running in audit mode it will check permissions and report
# If running in lockdown mode it will fix permissions if they
# don't match those passed to routine
# Takes:
# check_file:   Name of file
# check_perms:  Octal of file permissions, eg 755
# check_owner:  Owner of file
# check_group:  Group ownership of file
#.

funct_check_perms () {
  check_file=$1
  check_perms=$2
  check_owner=$3
  check_group=$4
  if [ "$id_check" = "0" ]; then
    find_command="find"
  else
    find_command="sudo find"
  fi
  if [ "$audit_mode" != 2 ]; then
    echo "Checking:  File permissions on $check_file"
  fi
  total=`expr $total + 1`
  if [ ! -f "$check_file" ] && [ ! -d "$check_file" ]; then
    if [ "$audit_mode" != 2 ]; then
      secure=`expr $secure + 1`
      echo "Notice:    File $check_file does not exist [$score]"
    fi
    return
  fi
  if [ "$check_owner" != "" ]; then
    check_result=`$find_command $check_file -perm $check_perms -user $check_owner -group $check_group`
  else
    check_result=`$find_command $check_file -perm $check_perms`
  fi
  log_file="fileperms.log"
  if [ "$check_result" != "$check_file" ]; then
    if [ "$audit_mode" = 1 ]; then
      insecure=`expr $insecure + 1`
      echo "Warning:   File $check_file has incorrect permissions [$insecure Warnings]"
      funct_verbose_message "" fix
      funct_verbose_message "chmod $check_perms $check_file" fix
      if [ "$check_owner" != "" ]; then
        funct_verbose_message "chown $check_owner:$check_group $check_file" fix
      fi
      funct_verbose_message "" fix
    fi
    if [ "$audit_mode" = 0 ]; then
      log_file="$work_dir/$log_file"
      if [ "$os_name" = "SunOS" ]; then
        file_perms=`truss -vstat -tstat ls -ld $check_file 2>&1 |grep 'm=' |tail -1 |awk '{print $3}' |cut -f2 -d'=' |cut -c4-7`
      else
        file_perms=`stat -c %a $check_file`
      fi
      file_owner=`ls -l $check_file |awk '{print $3","$4}'`
      echo "$check_file,$file_perms,$file_owner" >> $log_file
      echo "Setting:   File $check_file to have correct permissions [$score]"
      chmod $check_perms $check_file
      if [ "$check_owner" != "" ]; then
        chown $check_owner:$check_group $check_file
      fi
    fi
  else
    if [ "$audit_mode" = 1 ]; then
      secure=`expr $secure + 1`
      echo "Secure:    File $check_file has correct permissions [$secure Passes]"
    fi
  fi
  if [ "$audit_mode" = 2 ]; then
    restore_file="$restore_dir/$log_file"
    if [ -f "$restore_file" ]; then
      restore_check=`cat $restore_file |grep "$check_file" |cut -f1 -d","`
      if [ "$restore_check" = "$check_file" ]; then
        restore_info=`cat $restore_file |grep "$check_file"`
        restore_perms=`echo "$restore_info" |cut -f2 -d","`
        restore_owner=`echo "$restore_info" |cut -f3 -d","`
        restore_group=`echo "$restore_info" |cut -f4 -d","`
        echo "Restoring: File $check_file to previous permissions"
        chmod $restore_perms $check_file
        if [ "$check_owner" != "" ]; then
          chown $restore_owner:$restore_group $check_file
        fi
      fi
    fi
  fi
}
