# audit_extended_attributes
#
# Extended attributes are implemented as files in a "shadow" file system that
# is not generally visible via normal administration commands without special
# arguments.
# Attackers or malicious users could "hide" information, exploits, etc.
# in extended attribute areas. Since extended attributes are rarely used,
# it is important to find files with extended attributes set.
#.

audit_extended_attributes () {
  if [ "$os_name" = "SunOS" ]; then
    funct_verbose_message "Extended Attributes"
    if [ "$audit_mode" = 1 ]; then
      echo "Checking:  For files and directories with extended attributes [This might take a while]"
      for check_file in `find / \( -fstype nfs -o -fstype cachefs \
        -o -fstype autofs -o -fstype ctfs -o -fstype mntfs \
        -o -fstype objfs -o -fstype proc \) -prune \
        -o -xattr -print`; do
        total=`expr $total + 1`
        score=`expr $score - 1`
        echo "Warning:   File $check_file has extended attributes [$score]"
      done
    fi
  fi
}