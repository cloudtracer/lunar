# audit_ipsec
#
# Turn off IPSEC
#.

audit_ipsec () {
  if [ "$os_name" = "SunOS" ]; then
    if [ "$os_version" = "10" ] || [ "$os_version" = "11" ]; then
      funct_verbose_message "IPSEC Services"
      service_name="svc:/network/ipsec/manual-key:default"
      funct_service $service_name disabled
      service_name="svc:/network/ipsec/ike:default"
      funct_service $service_name disabled
      service_name="svc:/network/ipsec/ipsecalgs:default"
      funct_service $service_name disabled
      service_name="svc:/network/ipsec/policy:default"
      funct_service $service_name disabled
    fi
  fi
}
